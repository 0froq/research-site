# Research dialogue protocol

This protocol distinguishes brainstorming, analysis review, decisions, and durable records in the warming-temporal-pathways exploration.

## Conversation modes

| Prompt label | Output | Durable record |
|----|----|----|
| `brainstorm:` | Competing hypotheses, variables, predictions, and falsifiers. | None until a hypothesis is selected. |
| `analysis design:` | Data contract, response/predictor definitions, confounders, diagnostics, and failure conditions. | Investigation or implementation plan after approval. |
| `audit:` | Evidence boundary, unit/provenance checks, code/data risks, and claims that exceed the analysis. | Log only if it changes a decision. |
| `decision:` | A concise chosen rule plus rejected alternatives and rationale. | Decision record and, if cross-layer, analysis contract / AGENTS. |
| `reading brief:` | Selected papers with evidence-bounded summaries. | Reading queue; paper note only after review. |

## Hypothesis card

``` text
Claim: what process may explain what observed pattern?
Prediction: what data pattern would support it?
Falsifier: what result would weaken it?
Required data: what is missing from current producers?
Alternatives: what other processes yield the same pattern?
Claim boundary: descriptive association / pathway consistency / causal claim
```

## Record locations

- `explorations/<slug>/log/`: dated work history and changed research state.
- `explorations/<slug>/investigations/`: durable methodological discussion and diagnostic protocols.
- `explorations/<slug>/decisions/`: high-impact, reusable choices.
- `docs/analysis-contract.qmd`: canonical quantities, parameter choices, and exclusions.
- `notes/papers/`: user-reviewed, source-centric paper notes.
- `notes/reading-queue.md`: candidate and reviewed-literature status.

Back to top
