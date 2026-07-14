# Research Dialogue Protocol

This is the operating protocol for brainstorming, analysis review, decisions, and durable records in the warming-acceleration exploration.

> 本页规定共同头脑风暴、分析审核、决策与记录的工作方式。

## Conversation modes

| Prompt label | Output | Durable record |
|----|----|----|
| `brainstorm:` | Competing hypotheses, variables, predictions, and falsifiers. | None until a hypothesis is selected. |
| `analysis design:` | Data contract, response/predictor definitions, confounders, diagnostics, and failure conditions. | Prose diagnostic or implementation plan after approval. |
| `audit:` | Evidence boundary, unit/provenance checks, code/data risks, and claims that exceed the analysis. | Log only if it changes a decision. |
| `decision:` | A concise chosen rule plus rejected alternatives and rationale. | `log/YYYY-MM-DD.qmd` and, if cross-layer, Analysis Contract / AGENTS. |
| `reading brief:` | Up to two selected papers with evidence-bounded summaries. | Reading Queue; paper note only after user acceptance. |

> 先在对话中讨论，再决定哪些内容成为 durable record。日志记录决策与证据状态，不记录未经筛选的长篇推演。

## Hypothesis card

Every mechanism-oriented idea should first fit this card:

``` text
Claim: what process may explain what observed pattern?
Prediction: what data pattern would support it?
Falsifier: what result would weaken it?
Required data: what is missing from current producers?
Alternatives: what other processes yield the same pattern?
Claim boundary: descriptive association / pathway consistency / causal claim
```

The glacier-meltwater idea is an example: its JJA prediction is testable now, but its hydrological-connection premise requires additional catchment data.

## Record locations

- `explorations/warming-acceleration/log/`: dated decisions, completed work, and changed research state.
- `explorations/warming-acceleration/prose/`: durable methodological discussion and diagnostic protocols.
- `docs/analysis-contract.qmd`: canonical quantities, parameter choices, and exclusions.
- `notes/papers/`: only user-reviewed per-paper notes.
- `notes/reading-queue.qmd`: candidate and reviewed literature status.

Back to top
