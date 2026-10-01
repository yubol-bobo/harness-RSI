# Quantifying Infrastructure Noise in Agentic Coding Evals

- **Title:** Quantifying infrastructure noise in agentic coding evals
- **Authors:** Gian Segato (Anthropic)
- **Year:** Feb 5, 2026
- **Link:** https://www.anthropic.com/engineering/infrastructure-noise
- **Status:** read in full

**One-line TL;DR:** Container resource configuration alone moves Terminal-Bench 2.0 scores by up to **6 pp**, so leaderboard gaps **under 3 pp** deserve skepticism unless eval configs match.

**Problem:** Agentic evals run in live environments, so the runtime is part of the test. Scores didn't match the official leaderboard, and up to 6% of tasks failed from pod errors.

**Method:** Same model, harness and task set; six resource configs from strict 1× (guarantee = kill limit) to uncapped; crossover on SWE-bench (227 problems × 10 samples, RAM up to 5×).

**Key results:**
- Infra error rate **5.8% (1×) → 2.1% (3×) → 0.5% (uncapped)**; 1× → 3× is significant (p<0.001).
- Success within noise from 1× to 3× (p=0.40). Above 3×, success rises faster than errors fall. **+6 pp total (p<0.01)** uncapped vs 1×.
- Beyond ~3×, extra resources *change what is measured* (heavy-dependency strategies such as installing pandas/sklearn for `bn-fit-modify` become viable).
- SWE-bench: +1.54 pp at 5× RAM.
- Anecdotally, pass rates vary with time of day (API latency).
- Recommendation: specify both guaranteed allocation and kill threshold per task; calibrate the band so floor and ceiling scores fall within noise.

**Why it matters for harness/RSI:** Any harness-evolution result on TB2 (AHE, Meta-Harness, Self-Harness) has to be read against this noise floor. The environment is part of the "harness" broadly construed.

**Limitations:** Mostly Claude models; time-of-day effects unquantified.

**My questions:** Do harness-evolution papers report infra configs and multiple runs? Could an evolving harness "learn" to exploit generous resources, i.e. reward hacking through the environment?
