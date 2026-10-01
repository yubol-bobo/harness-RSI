# AI Control: Improving Safety Despite Intentional Subversion

- **Authors:** Ryan Greenblatt, Buck Shlegeris, Kshitij Sachan, Fabien Roger (Redwood Research)
- **Year:** 2023 arXiv; ICML 2024 (oral)
- **Link:** https://arxiv.org/abs/2312.06942

## TL;DR
Instead of assuming the model is aligned, design **protocols that remain safe even if the strong model is actively trying to cause a bad outcome**, and test them with red-team "control evaluations".

## Method
- **Setting (APPS backdooring):** an untrusted strong model (GPT-4) solves programming problems; the red team makes it try to insert **backdoors** (code that passes tests but fails on a secret input). Resources: a **trusted weaker model** (GPT-3.5) and a **limited budget of trusted high-quality labor** (proxy for human auditors).
- **Protocols:**
  - *Trusted monitoring:* GPT-3.5 rates suspiciousness; most suspicious outputs are audited.
  - *Trusted editing:* above a suspiciousness threshold, GPT-3.5 edits out suspicious parts before submission.
  - *Untrusted monitoring:* another GPT-4 instance checks for backdoors, with measures to prevent collusion between the instances.
- **Control evaluation:** red team vs. blue team; measure safety (probability no backdoor is ever submitted) vs. usefulness.

## Results (verified at abstract level)
- Trusted editing and untrusted monitoring substantially improved the safety–usefulness trade-off over simple baselines (e.g., only using the trusted model, or only auditing a random sample).

## Relevance to harness / RSI
- An automated AI researcher or a self-editing harness is an **untrusted agent with write access to the system that builds its successor**. Control gives a concrete toolkit: frozen trusted monitor reviewing every self-edit, human audit budget aimed at trust-boundary changes, resampling suspicious edits, anti-collusion for self-monitoring.
- Follow-up: *Ctrl-Z* (Bhatt et al. 2025) extends control to multi-step agents via resampling.
- See [note 08](../08-safety-and-theory-of-rsi.md) §5.

## Questions to prepare
- Why is "safety under intentional subversion" a useful worst case even if models are probably not scheming?
- How does the protocol degrade as the gap between trusted and untrusted models widens (as it would in RSI)?
- How do you prevent collusion when the monitor is another copy of the same model?
