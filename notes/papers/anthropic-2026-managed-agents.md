# Scaling Managed Agents: Decoupling the Brain from the Hands

- **Title:** Scaling Managed Agents: Decoupling the brain from the hands
- **Authors:** Lance Martin, Gabe Cemaj, Michael Cohen (Anthropic)
- **Year:** Apr 8, 2026
- **Link:** https://www.anthropic.com/engineering/managed-agents
- **Status:** read in full

**One-line TL;DR:** Harnesses go stale, so build a **meta-harness** of stable OS-like interfaces: **session** (append-only event log), **harness** (stateless loop, the "brain"), **sandbox** (the "hands", reached via `execute(name, input) → string`). Each part can fail or be swapped independently.

**Problem:** A single container holding harness, session and sandbox became a "pet": failures lost sessions, debugging required shelling into containers with user data, credentials sat next to untrusted generated code, and VPC integration was hard.

**Method:** Harness leaves the container. Sandboxes are cattle (`provision({resources})`). Harness recovery via `wake(sessionId)`, `getSession(id)`, `emitEvent(id, event)`. Credentials never in the sandbox (git token wired at init; MCP OAuth via vault + proxy). **"The session is not Claude's context window"**: `getEvents()` gives re-readable positional slices, while the harness applies arbitrary context transforms.

**Key results:** **p50 TTFT −~60%, p95 −>90%** (containers provisioned only when needed). Enables many brains and many hands, and brains passing hands to each other.

**Why it matters for harness/RSI:** It makes Weng's OS analogy concrete. It separates *recoverable storage* from *context policy*, so future harness and context-engineering strategies (including automatically discovered ones) can be swapped in without changing infrastructure. Security boundaries live outside the harness.

**Limitations:** A product-engineering post; no task-quality evals; implementation details are proprietary.

**My questions:** What's the right interface for harness self-modification in such a system: hot-swapping harness versions mid-session? How do you version harnesses against long-lived sessions (cf. rainbow deploys)?
