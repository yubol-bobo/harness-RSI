# Reflections on Trusting Trust, Revisited: Contaminating Self-Modifying AI Coding Agents with Poisoned Benchmarks

- **Authors:** Franziska Roesner, Tadayoshi Kohno
- **Year:** 2026 (arXiv 2609.17817, Sep 2026)
- **Venue:** arXiv preprint
- **Link:** https://arxiv.org/abs/2609.17817

## TL;DR
Ken Thompson's compiler backdoor, reborn: poisoned self-improvement benchmarks make DGM, SICA and Hyperagents evolve persistent insecure behaviour on clean held-out tasks.

## Key results (search-snippet level)
With Hyperagents + Sonnet 4.5, a 5-task poisoned benchmark → agents disabled HTTPS certificate verification on **30/30** neutral code-writing attempts (0 with clean benchmarks); contamination often persisted after further evolution on clean benchmarks.

## Why it matters for RSI
The evaluator is an attack surface; benchmark supply chain must be trusted. A critique (community issue) argues the vulnerability lives in persisted scaffolding rather than true self-propagation **[secondary]**.

## Connections
DGM objective hacking, misevolution (arXiv 2509.26354), Self-Harness/AHE read-only verifiers.

## Questions
Can lineage audits or differential testing detect such inherited behaviours automatically?
