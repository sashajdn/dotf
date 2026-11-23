"""Focused offline checks for the AMP command's boundaries."""

import contextlib
import io
import json
from pathlib import Path
import runpy
import subprocess
import unittest
from unittest.mock import Mock, patch


ROOT = Path(__file__).resolve().parents[1]
query = runpy.run_path(str(ROOT / "scripts" / "prometheus-query.py"))
scope = query["main"].__globals__


class PrometheusQueryTest(unittest.TestCase):
    def setUp(self):
        self.map_text = (ROOT / "tests" / "routes.md").read_text()
        self.routes = query["load_routes"](ROOT / "tests" / "routes.md")
        self.account, self.workspace = self.routes["development-core"]
        self.credentials = {
            "AccessKeyId": "TESTKEY", "SecretAccessKey": "TESTSECRET", "SessionToken": "TESTTOKEN"
        }

    def test_route_table_fails_closed(self):
        self.assertEqual(len(self.routes), 9)
        self.assertEqual(self.routes["production-node-shadow"], self.routes["production-core"])
        shadow = next(line for line in self.map_text.splitlines() if line.startswith(
            "| production | 608464618807 | bpx-production-shadow"
        ))
        for replacement in ("", shadow + "\n" + shadow, shadow.replace("bpx-production-shadow", "shadow")):
            with self.subTest(replacement=replacement):
                path = Mock()
                path.read_text.return_value = self.map_text.replace(shadow, replacement)
                with self.assertRaises(query["QueryError"]):
                    query["load_routes"](path)

    def test_invalid_requests_do_not_get_credentials(self):
        common = ["--environment", "development", "--profile", "test",
                  "--map", str(ROOT / "tests" / "routes.md")]
        window = ["--start", "2026-11-01T00:00:00Z", "--end", "2026-11-01T02:00:00Z"]
        for operation in ["remote_write", "alertmanager", "DELETE", "POST"]:
            with self.subTest(operation=operation), patch.object(subprocess, "run") as transport:
                with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                    query["main"](common + [operation])
                transport.assert_not_called()
        rejected = [
            (["series", "--cluster", "production-core", "up", *window], "Cluster is absent"),
            (["range", "up", *window, "--step", "15"], "241 evaluations"),
            (["range", "up", *window[:-1], "2026-11-01T07:00:00Z", "--step", "120"], "six hours"),
        ]
        for args, message in rejected:
            with self.subTest(args=args), patch.object(subprocess, "run") as transport:
                with contextlib.redirect_stderr(io.StringIO()) as error:
                    self.assertEqual(query["main"](common + args), 1)
                self.assertIn(message, error.getvalue())
                transport.assert_not_called()

    def test_identity_and_workspace_are_verified_in_order(self):
        identity = {"Account": self.account, "Arn": (
            f"arn:aws:sts::{self.account}:assumed-role/DevelopmentCoreEdit/test"
        )}
        description = {"workspace": {
            "arn": f"arn:aws:aps:ap-northeast-1:{self.account}:workspace/{self.workspace}",
            "workspaceId": self.workspace, "status": {"statusCode": "ACTIVE"},
        }}
        for responses, expected_error in [
            ([self.credentials, {"Account": "000000000000", "Arn": "arn:aws:iam::000000000000:user/edit"}],
             "selected Exchange core account"),
            ([self.credentials, identity, {"workspace": {}}], "workspace failed"),
            ([self.credentials, identity, {"workspace": []}], "workspace failed"),
            ([self.credentials, identity, description], None),
        ]:
            aws = Mock(side_effect=responses)
            with patch.dict(scope, {"aws_json": aws}):
                if expected_error:
                    with self.assertRaisesRegex(query["QueryError"], expected_error):
                        query["verified_credentials"]("test", self.account, self.workspace)
                else:
                    self.assertEqual(query["verified_credentials"]("test", self.account, self.workspace),
                                     self.credentials)
            self.assertEqual([call.args[0][0] for call in aws.call_args_list],
                             ["configure", "sts", "amp"][:len(responses)])

        with patch.object(subprocess, "run", return_value=subprocess.CompletedProcess([], 0, b"[]")):
            with self.assertRaisesRegex(query["QueryError"], "AWS query identity"):
                query["aws_json"](("sts", "get-caller-identity"), env={}, failure="AWS query identity")

    def test_signed_get_has_fixed_path_and_no_credentials_in_arguments(self):
        payload = b'{"status":"success","data":["cluster"]}\n200'
        with patch.object(subprocess, "run", return_value=subprocess.CompletedProcess([], 0, payload)) as curl:
            result = query["request_data"](self.workspace, "labels", {"match[]": "up"}, self.credentials)
        self.assertEqual(result, ["cluster"])
        args = curl.call_args.args[0]
        self.assertEqual(args[args.index("--request") + 1], "GET")
        self.assertEqual(args[args.index("--aws-sigv4") + 1], "aws:amz:ap-northeast-1:aps")
        self.assertTrue(args[-1].startswith(
            f"https://aps-workspaces.ap-northeast-1.amazonaws.com/workspaces/{self.workspace}/api/v1/labels?"
        ))
        for value in self.credentials.values():
            self.assertNotIn(value, " ".join(args))
            self.assertIn(value.encode(), curl.call_args.kwargs["input"])

        instant = b'{"status":"success","data":{"resultType":"vector","result":[1]}}\n200'
        with patch.object(subprocess, "run", return_value=subprocess.CompletedProcess([], 0, instant)) as curl:
            query["request_data"](self.workspace, "instant", {"query": "sum by (cluster) (up)"}, self.credentials)
        self.assertIn("query=sum%20by%20%28cluster%29%20%28up%29", curl.call_args.args[0][-1])

    def test_read_failures_are_bounded(self):
        oversized = json.dumps({"status": "success", "data": list(range(101))}).encode()
        for code, response, message in [
            (0, b"\n403", "denied"),
            (0, b'{"status":"success","data":[]}\n200', "No matching data"),
            (0, oversized + b"\n200", "too many"),
            (63, b"", "byte limit"),
        ]:
            with self.subTest(message=message), patch.object(
                subprocess, "run", return_value=subprocess.CompletedProcess([], code, response)
            ):
                with self.assertRaisesRegex(query["QueryError"], message):
                    query["request_data"](self.workspace, "series", {}, self.credentials)


if __name__ == "__main__":
    unittest.main()
