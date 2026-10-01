# Code Execution with MCP

- **Title:** Code execution with MCP: Building more efficient agents
- **Authors:** Adam Jones, Conor Kelly (Anthropic)
- **Year:** Nov 4, 2025
- **Link:** https://www.anthropic.com/engineering/code-execution-with-mcp
- **Status:** read in full

**One-line TL;DR:** Present MCP servers as a **file tree of typed code APIs** and let the agent write code that calls them. Tools load on demand and data is filtered in the sandbox, cutting tokens dramatically.

**Problem:** With hundreds or thousands of MCP tools, (1) tool definitions flood context and (2) intermediate results pass through the model, sometimes twice (e.g. a meeting transcript copied from Drive to Salesforce).

**Method:** `servers/<server>/<tool>.ts` wrappers; the agent `ls`es and reads only the needed tool files (or uses a `search_tools` tool with detail levels); it writes TypeScript that chains calls, filters data, loops, and handles errors; PII can be tokenized by the MCP client; working code can be saved as reusable functions or skills.

**Key results:** Example workflow **150,000 → 2,000 tokens (−98.7%)**. Cloudflare reports similar findings ("Code Mode").

**Why it matters for harness/RSI:** **Code as the universal action space**, so orchestration moves from harness to model. Saved functions become an agent-grown toolbox: "evolving the scaffolding that it needs to work most effectively."

**Limitations:** Requires a secure sandbox (resource limits, monitoring); more operational complexity; the single 98.7% number is from one illustrative example.

**My questions:** When does direct tool calling beat code mode (e.g. for weaker coders, or when per-call approval is needed)? How do you audit agent-written orchestration code for safety?
