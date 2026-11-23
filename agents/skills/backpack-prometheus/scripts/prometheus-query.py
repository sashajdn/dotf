"""Bounded, GET-only queries against the Backpack Exchange AMP workspaces."""

import argparse
from datetime import datetime, timedelta, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import quote, urlencode


REGION = "ap-northeast-1"
HOST = f"aps-workspaces.{REGION}.amazonaws.com"
MAP = Path.home() / "eng" / "backpack" / "map" / "META.md"
HEADING = "## Exchange Prometheus routes"
HEADER = "| Environment | AWS account | EKS cluster | Prometheus cluster label | AMP workspace | Evidence path |"
WORKSPACE_ID = r"ws-[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}"
CLUSTERS = {
    "development": {"core", "node-1", "node-2", "node-3"},
    "production": {"core", "node-1", "node-2", "node-3", "node-shadow"},
}
ROUTES = {"labels": "labels", "series": "series", "instant": "query", "range": "query_range"}
MAX_BYTES = 256 * 1024
MAX_RESULTS = 100


class QueryError(Exception):
    pass


def load_routes(path):
    document = path.read_text(encoding="utf-8")
    lines = document.splitlines()
    if lines.count(HEADING) != 1 or lines.count(HEADER) != 1:
        raise QueryError("Missing or duplicate Exchange Prometheus route table.")
    section = document.split(HEADING + "\n", 1)[1].split("\n## ", 1)[0]
    tables = [line for line in section.splitlines() if line.lstrip().startswith("|")]
    if tables[:2] != [HEADER, "| --- | --- | --- | --- | --- | --- |"]:
        raise QueryError("Malformed Exchange Prometheus route table header.")

    routes = {}
    for row in tables[2:]:
        parts = row.split(" | ")
        if len(parts) != 6 or not row.startswith("| ") or not row.endswith(" |"):
            raise QueryError("Malformed Exchange Prometheus route row.")
        env, account, eks, label, workspace, evidence = (
            parts[0][2:], *parts[1:-1], parts[-1][:-2]
        )
        cluster = label.removeprefix(env + "-")
        eks_suffix = "shadow" if cluster == "node-shadow" else cluster
        if (
            env not in CLUSTERS
            or cluster not in CLUSTERS[env]
            or label != f"{env}-{cluster}"
            or eks != f"bpx-{env}-{eks_suffix}"
            or not re.fullmatch(r"[0-9]{12}", account)
            or not re.fullmatch(WORKSPACE_ID, workspace)
            or evidence != (
                "repos/ops-kube/exchange/values/kube-prometheus-stack/"
                f"{label}/values.yaml.gotmpl"
            )
            or label in routes
        ):
            raise QueryError("Invalid, mismatched, or duplicate Exchange Prometheus route.")
        routes[label] = (account, workspace)
    for env, clusters in CLUSTERS.items():
        expected = {f"{env}-{cluster}" for cluster in clusters}
        actual = {label for label in routes if label.startswith(env + "-")}
        if actual != expected or len({routes[label][1] for label in actual}) != 1:
            raise QueryError("Missing or ambiguous Exchange Prometheus environment routes.")
    if routes["production-core"][1] == routes["development-core"][1]:
        raise QueryError("Exchange environments must use distinct AMP workspaces.")
    if (
        routes["production-core"][0] == routes["development-core"][0]
        or routes["production-node-shadow"][0] != routes["production-core"][0]
    ):
        raise QueryError("Mismatched Exchange core or shadow account.")
    return routes


def utc_time(value):
    if not re.fullmatch(r"\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ", value):
        raise argparse.ArgumentTypeError("use a UTC timestamp such as 2026-11-23T12:00:00Z")
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as error:
        raise argparse.ArgumentTypeError("invalid UTC timestamp") from error


def arguments(argv):
    parser = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
    parser.add_argument("--environment", required=True, choices=CLUSTERS)
    parser.add_argument("--profile", required=True, help="existing local AWS profile in the selected core account")
    parser.add_argument("--map", type=Path, default=MAP, help="Backpack map/META.md route source")
    operations = parser.add_subparsers(dest="operation", required=True)
    for operation in ROUTES:
        command = operations.add_parser(operation, allow_abbrev=False)
        if operation in {"labels", "series"}:
            command.add_argument("--cluster", required=True, help="Prometheus cluster label")
        if operation in {"instant", "range"}:
            command.add_argument("promql")
        else:
            command.add_argument("metric", help="exact Prometheus metric name")
        if operation == "instant":
            command.add_argument("--time", required=True, type=utc_time)
        else:
            command.add_argument("--start", required=True, type=utc_time)
            command.add_argument("--end", required=True, type=utc_time)
        if operation == "range":
            command.add_argument("--step", required=True, type=int, help="seconds")
    return parser.parse_args(argv)


def query_params(args):
    if args.operation in {"labels", "series"}:
        if not re.fullmatch(r"[A-Za-z_:][A-Za-z0-9_:]{0,199}", args.metric):
            raise QueryError("Supply one exact Prometheus metric name.")
        params = {"match[]": f'{args.metric}{{cluster="{args.cluster}"}}'}
    else:
        if not args.promql.strip() or len(args.promql.encode()) > 2048:
            raise QueryError("Supply PromQL between 1 and 2048 bytes.")
        params = {"query": args.promql, "timeout": "8s"}
    now = datetime.now(timezone.utc)
    if args.operation == "instant":
        if args.time > now:
            raise QueryError("Evaluation time must be in the past.")
        params["time"] = int(args.time.timestamp())
    else:
        duration = (args.end - args.start).total_seconds()
        if args.end > now or not 0 < duration <= timedelta(hours=6).total_seconds():
            raise QueryError("Use a past UTC window of at most six hours.")
        params.update(start=int(args.start.timestamp()), end=int(args.end.timestamp()))
        if args.operation == "range":
            if args.step < 15 or duration // args.step + 1 > 241:
                raise QueryError("Use a step of at least 15 seconds and at most 241 evaluations.")
            params["step"] = args.step
    return params


def aws_json(operation, *, env, options=(), failure):
    command = [
        "aws", "--no-cli-pager", "--no-cli-auto-prompt", "--output", "json",
        "--region", REGION, "--cli-connect-timeout", "4", "--cli-read-timeout", "6",
        *operation, *options,
    ]
    try:
        result = subprocess.run(command, env=env, capture_output=True, timeout=15, check=True)
        payload = json.loads(result.stdout)
        if not isinstance(payload, dict):
            raise ValueError("unexpected AWS response")
        return payload
    except (OSError, subprocess.SubprocessError, ValueError):
        raise QueryError(failure) from None


def verified_credentials(profile, account, workspace):
    profile_env = {key: value for key, value in os.environ.items() if not key.startswith("AWS_")}
    profile_env["AWS_IGNORE_CONFIGURED_ENDPOINT_URLS"] = "true"
    credentials = aws_json(
        ("configure", "export-credentials"),
        env=profile_env,
        options=("--profile", profile, "--format", "process"),
        failure="Could not resolve the selected local AWS profile.",
    )
    fields = {"AccessKeyId": "AWS_ACCESS_KEY_ID", "SecretAccessKey": "AWS_SECRET_ACCESS_KEY",
              "SessionToken": "AWS_SESSION_TOKEN"}
    if not isinstance(credentials, dict) or any(
        not isinstance(credentials.get(key), str)
        or not re.fullmatch(r"[A-Za-z0-9/+=_-]{1,8192}", credentials[key])
        for key in fields
    ):
        raise QueryError("The AWS profile must provide temporary credentials.")

    isolated = {
        "PATH": os.environ.get("PATH", os.defpath),
        "AWS_CONFIG_FILE": os.devnull,
        "AWS_SHARED_CREDENTIALS_FILE": os.devnull,
        "AWS_EC2_METADATA_DISABLED": "true",
        "AWS_MAX_ATTEMPTS": "1",
        **{variable: credentials[key] for key, variable in fields.items()},
    }
    identity = aws_json(
        ("sts", "get-caller-identity"), env=isolated,
        failure="Unable to verify the AWS query identity.",
    )
    if identity.get("Account") != account:
        raise QueryError("AWS profile is not in the selected Exchange core account.")
    description = aws_json(
        ("amp", "describe-workspace"), env=isolated,
        options=("--workspace-id", workspace),
        failure="The query role cannot describe the selected AMP workspace.",
    ).get("workspace", {})
    if not isinstance(description, dict):
        raise QueryError("The selected AMP workspace failed identity or status verification.")
    expected_arn = f"arn:aws:aps:{REGION}:{account}:workspace/{workspace}"
    if (
        description.get("arn") != expected_arn
        or description.get("workspaceId") != workspace
        or description.get("status", {}).get("statusCode") != "ACTIVE"
    ):
        raise QueryError("The selected AMP workspace failed identity or status verification.")
    return credentials


def request_data(workspace, operation, params, credentials):
    url = f"https://{HOST}/workspaces/{workspace}/api/v1/{ROUTES[operation]}?{urlencode(params, quote_via=quote)}"
    config = (
        f'user = "{credentials["AccessKeyId"]}:{credentials["SecretAccessKey"]}"\n'
        f'header = "X-Amz-Security-Token: {credentials["SessionToken"]}"\n'
    )
    try:
        result = subprocess.run(
            [
                "curl", "--disable", "--config", "-", "--silent", "--request", "GET",
                "--proto", "=https", "--noproxy", "*",
                "--aws-sigv4", f"aws:amz:{REGION}:aps",
                "--connect-timeout", "4", "--max-time", "12",
                "--max-filesize", str(MAX_BYTES), "--write-out", "\n%{http_code}", url,
            ],
            input=config.encode(), capture_output=True, timeout=15,
            env={"PATH": os.environ.get("PATH", os.defpath)},
        )
    except (OSError, subprocess.SubprocessError):
        raise QueryError("AMP request failed or timed out.") from None
    if result.returncode == 63:
        raise QueryError("AMP response exceeds the byte limit. Narrow the query.")
    if result.returncode:
        raise QueryError("AMP request failed or timed out.")
    raw, _, status = result.stdout.rpartition(b"\n")
    if status in {b"401", b"403"}:
        raise QueryError("AMP denied this read for the selected AWS profile.")
    if status != b"200":
        raise QueryError("AMP did not return a successful read. Check query syntax and bounds.")
    if len(raw) > MAX_BYTES:
        raise QueryError("AMP response exceeds the byte limit. Narrow the query.")
    try:
        payload = json.loads(raw)
    except ValueError:
        raise QueryError("AMP returned invalid JSON.") from None
    if not isinstance(payload, dict) or payload.get("status") != "success":
        raise QueryError("AMP did not return a successful read.")
    data = payload.get("data")
    results = data.get("result") if isinstance(data, dict) else data
    if not isinstance(results, list):
        raise QueryError("AMP returned an unexpected result shape.")
    if len(results) > MAX_RESULTS:
        raise QueryError("AMP returned too many results. Narrow the query or aggregate.")
    if not results:
        raise QueryError("No matching data. Check the UTC window, scrape health, and remote-write filtering.")
    return data


def main(argv=None):
    args = arguments(argv)
    try:
        routes = load_routes(args.map)
        account, workspace = routes[f"{args.environment}-core"]
        cluster = getattr(args, "cluster", None)
        if cluster is not None and (
            not cluster.startswith(args.environment + "-") or cluster not in routes
        ):
            raise QueryError("Cluster is absent from the selected Exchange environment.")
        params = query_params(args)
        credentials = verified_credentials(args.profile, account, workspace)
        data = request_data(workspace, args.operation, params, credentials)
        print(json.dumps({
            "environment": args.environment,
            "workspace": workspace,
            "operation": args.operation,
            "parameters": params,
            "data": data,
        }, separators=(",", ":")))
    except (OSError, UnicodeError):
        print("error: unable to read the Exchange Prometheus map", file=sys.stderr)
        return 1
    except QueryError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
