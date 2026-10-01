# Karpathy's autoresearch

- **Who / when:** Andrej Karpathy, open-source repo `karpathy/autoresearch`, released **~7 Mar 2026** (per secondary coverage) [date unverified].
- **One-line:** the minimal auto-research "ratchet". An agent edits an LLM training script, trains for **5 minutes**, and keeps the change **only if validation bits-per-byte (val_bpb) improves** (git commit). Otherwise it reverts.

## Mechanism
- A fixed-time training budget makes experiments comparable (~12 per hour on one GPU).
- One scalar objective (**val_bpb**). Git history is the monotone archive.
- The agent (a coding LLM) reads results and proposes the next edit. A `program.md`-style instruction file acts as the "research org" prompt [detail unverified].

## Reported results (secondary sources, [unverified])
- One overnight run: 126 experiments, loss 0.9979 → 0.9697.
- Two days on a depth-12 model: ~700 autonomous changes, ~20 additive improvements that **transferred to larger models**. Stacked, they cut the nanochat "Time to GPT-2" leaderboard from **2.02 h to 1.80 h (~11%)**.
- Very fast community adoption (tens of thousands of GitHub stars).

## Why it matters
- The hill-climbing baseline for auto-research. It shows how far a **trivially simple harness plus a good executable metric** can go. Compare AlphaEvolve (population + evaluator) and DGM (archive + self-modification).
- It belongs in awesome-rsi's "Automated Search / AI R&D" tools section.

## Caveats
- Greedy acceptance means no exploration or diversity, so it gets stuck in local optima.
- Short-proxy overfitting: does a 5-minute win hold at full scale? (Partial evidence says some do.)
- Noise: single-run comparisons can accept lucky seeds. Repeated runs or significance thresholds would help.
- The improver does not improve itself, so this is not recursive by awesome-rsi's definition.

## Harness-design view (added by the harness-foundations pass; see notes/01 §15)
- Three files: `program.md` (human-written goals, rules, off-limits areas, failure handling: the "harness prompt"), `train.py` (~630-line GPT training script, the **only** file the agent edits), `prepare.py` (fixed data and tokenizer pipeline, FineWeb-Edu + BPE). Per secondary write-ups.
- Harness lessons: a **small explicit editable surface** (like AlphaEvolve's EVOLVE-BLOCKs and AHE's read-only verifier), a **fixed external evaluator plus a fixed compute budget**, **git as memory and rollback** (as in Anthropic's long-running-agent harness), and the human moving "up the stack" to edit `program.md` (Weng §7). Weng cites it as the clean example of Pattern 1 (workflow automation).
