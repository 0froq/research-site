# Reading Queue

This page tracks candidate readings for the warming-acceleration exploration. It is not a paper-note archive. A candidate becomes a `notes/papers/*.qmd` note only after the user reviews and accepts its brief.

> 本页是候选文献队列，不是正式笔记库。只有在用户审核 brief 并接受后，文献才进入 `notes/papers/`。

## Review protocol

| State | Meaning | Allowed action |
|----|----|----|
| candidate | Bibliographic match; not yet read or summarised. | Queue it with a question and relevance rationale. |
| briefed | A two-paper reading brief has been prepared in conversation. | User accepts, rejects, or requests deeper reading. |
| accepted | User confirms the paper should become a durable note. | Create one `notes/papers/<citation-key>.qmd` note from the reviewed brief. |
| rejected | Not useful for the present research question. | Keep only a one-line reason in this queue; do not create a paper note. |

> `candidate → briefed → accepted/rejected`。未经审核，不创建 paper note，也不把模型摘要伪装成你的阅读笔记。

## Daily brief routine

There is no autonomous push scheduler in this workspace. On any day, start a brief by asking for `今日文献 brief` or `reading brief: <topic>`. The response should contain at most two papers:

1.  why each paper was selected for the current analysis question;
2.  a short evidence-bounded summary after reading the available primary text;
3.  concrete implications, limitations, and whether it merits a user-authored paper note.

The first queue topic is **seasonal LSWT, ice duration, and potential cold-inflow signatures**. Candidate selection should favour studies that can constrain the diagnostic in [Seasonal and Ice Diagnostics](../explorations/warming-acceleration/prose/seasonal-ice-diagnostics.llms.md), not generic climate-hiatus papers.

> 当前队列主题是季节 LSWT、冰期与潜在冷入流指纹。优先选择能约束诊断设计的研究，而非泛泛的 hiatus 文献。

## Current candidates

| Citation | State | Why it is queued |
|----|----|----|
| Anderson et al. ([2021](#ref-anderson2021)) | candidate | Tests how a shortened winter and altered overturn/stratification change seasonal lake thermal structure; useful for separating ice-season pathways from a warm-season inflow hypothesis. |
| Woolway and Merchant ([2017](#ref-woolway2017a)) | candidate | Examines amplified interannual summer LSWT responses in cold, deep lakes; useful for interpreting a JJA diagnostic without presuming glacier meltwater. |

> 两篇均只是候选，尚未形成摘要或正式 paper note。它们分别约束冰期路径与冷深湖夏季响应的替代解释。

Back to top

## References

Anderson, Eric J., Craig A. Stow, Andrew D. Gronewold, et al. 2021. “Seasonal Overturn and Stratification Changes Drive Deep-Water Warming in One of Earth’s Largest Lakes.” *Nature Communications* 12 (1): 1688. <https://doi.org/10.1038/s41467-021-21971-1>.

Woolway, R. Iestyn, and Christopher J. Merchant. 2017. “Amplified Surface Temperature Response of Cold, Deep Lakes to Inter-Annual Air Temperature Variability.” *Scientific Reports* 7 (1): 4130. <https://doi.org/10.1038/s41598-017-04058-0>.
