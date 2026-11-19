---
name: eng-shared
description: Build shared understanding of an engineering system or proposed change through a concise technical RFC and task-sized visuals, usually a locally served webpage. Use standalone for architecture learning or from eng-task before implementation.
---

# Engineering shared understanding

Create the shortest RFC and visual model that let a capable engineer who lacks this system's context trace the current flow, see the failure, challenge the proposed change, and understand its operational effect. The local webpage is the default artifact for a substantive system or cross-service task; a small local edit may need only a brief explanation. Honor a user's request for a webpage even when the change is small.

## Ground the account in evidence

- Read applicable instructions, code, schemas, tests, deployment configuration, and history. Distinguish verified facts, inferences, and open questions. Link claims to the few relevant source locations; do not invent components or guarantees.
- Trace one representative execution from trigger to final effect. Identify the caller and exact endpoint or schedule, services and persistence layers, authoritative inputs, state changes, checks, retries, and operator actions. Show only components on this path.
- For sensitive changes, show the trust boundary and the point where authority is enforced. For scheduled or batch jobs, show data provenance, completeness or cursor rules, and what happens on partial failure. Include relevant table fields and short code snippets when they make the flow concrete.

## Write a ground-up RFC

Start with a one-screen TL;DR that answers what happens today and why it matters. If a change is proposed, state what is wrong or unknown, what changes, and why that changes the outcome. Assume the engineer has no context for this particular flow. Define each domain term before relying on it, then build from services and data flow toward the invariant.

Make the page read as a concise engineering RFC, not a dashboard or slide deck. Give it a title and decision status. Keep the applicable parts of the main narrative in this order:

1. **Context and current system:** what the system does, a full service/data-flow diagram, and one representative end-to-end run. Show the human action, endpoint or schedule, reads, writes, and final effect.
2. **Problem or decision, when relevant:** a direct problem statement and the smallest counterexample or design tension. State the invariant and point to the state or code that matters.
3. **Proposed system, when relevant:** a second diagram or a clearly marked change to the first, followed by the few checks or state transitions that enforce the invariant. Explain why the counterexample now fails and what legitimate work still succeeds.
4. **Alternatives, rollout, and open questions, when relevant:** a compact comparison of credible options, why each was kept or dropped, migration or cutover needs, and questions that genuinely require the engineer's answer.

Put schemas, code excerpts, edge cases, and secondary flows next to the claim they support or in a short appendix. Do not replace the problem and design argument with card summaries or turn the main RFC into a code dump.

## Make the local website teach the system

- Default to a running local webpage for a new service, cross-service migration, substantive funds or authorization flow, or substantial state machine. Put the primary systems diagram immediately after the TL;DR. Add interactive steps, before/after toggles, timelines, animations, GIFs, or short video only when they make temporal behavior or a failure mode easier to grasp.
- Draw a real systems diagram with SVG, Mermaid, Canvas, or Excalidraw-like vector shapes and connected edges. A row of cards with arrow characters or a storage "side path" in prose is not a diagram. Show relevant actors, services, stores, queues, and external systems as distinct nodes. Draw directed, labeled edges for calls, data, reads, writes, and acknowledgments; show trust or ownership boundaries when they explain the design.
- The diagram must let a reader follow one representative input from its trigger through every consequential hop to the final effect, with no invisible jumps. Show validation as a separate path when it queries other stores or APIs. Split a dense graph into an overview and one sequence or checks diagram instead of shrinking it into illegibility.
- Use a restrained RFC style: clear typography, neutral background, limited accent color, generous whitespace, and simple Excalidraw-like shapes. Put a short takeaway beside each diagram and make definitions, relevant table fields, snippets, assumptions, and alternatives available on demand. Avoid dashboard chrome, decorative motion, stock imagery, marketing copy, and unexplained jargon.
- Bind the server to `127.0.0.1`, verify a GET returns the expected page, and share the URL immediately. Do not make headless-browser inspection a prerequisite for the link. Run visual or interaction checks afterward when they address a concrete risk, with an isolated temporary browser profile; follow any tool or sandbox approval requirement. Keep the server and artifact available while the engineer reviews and corrects it. An attractive diagram is not evidence that its code-path claims are correct.

Use this skill to explain and converge on understanding. Do not start implementation in a standalone explanation task. When called from `$eng-task`, return the agreed model, open decisions, and any approval boundary to that workflow.
