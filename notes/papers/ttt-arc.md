# The Surprising Effectiveness of Test-Time Training for Abstract Reasoning

- **Authors:** Ekin Akyürek, Mehul Damani, Adam Zweiger, Linlu Qiu, Han Guo, Jyothish Pari, Yoon Kim, Jacob Andreas (MIT) **[author list partly unverified]**
- **Year / Venue:** 2024 (arXiv) / ICML 2025 **[venue unverified]**
- **Link:** https://arxiv.org/abs/2411.07279

**TL;DR:** Per-task temporary LoRA training on augmented demonstrations at inference dramatically improves ARC.

**Method:** (1) initial fine-tuning on similar tasks; (2) auxiliary task format + augmentations (leave-one-out, geometric transforms); (3) per-instance training; plus augmented inference / voting.

**Key results (verified):** Up to 6× accuracy over the base fine-tuned model; 8B model reaches 53% on ARC public validation (nearly +25% over prior public neural SOTA); ensembled with program synthesis 61.9% **[unverified]**.

**Why it matters for RSI:** Weight updates as part of inference; precursor to SEAL and TTT-Discover.

**Limitations:** Per-instance compute; relies on augmentation structure specific to ARC.

**Connections:** TTT (Sun 2020), SEAL, TTRL, TTT-Discover.

**Questions:** When does TTT beat long-context ICL?
