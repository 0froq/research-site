---
title: "Paper notes"
---

Paper notes are source-centric records. They remain meaningful when no
exploration is linked: each preserves source facts, relevant locations,
citation-ready claims, method or mechanism evidence, limits, and a next action.

New notes should use this front matter and body structure:

```md
---
title: 'citekey: Full Title'
created: YYYY-MM-DD
last_modified: YYYY-MM-DD
---

:::{.callout-note collapse="true"}
## Abstract

{abstract}
:::

:::{.column-margin}
Citation key
: citekey (@citekey)

Title
: Full Title

Author
: Last, First and Last, First ...

Journal, year
: Journal Name, YYYY
:::

## Source scope

## One-sentence contribution

## Reusable claims

## Method relevance

## Limts and disagreement

## Open questions / re-read triggers
```

The `::{.callout-note collapse="true"}` block wraps a collapsed abstract and
keeps the page compact. The `::{.column-margin}` block places citation
metadata in the margin on wide viewports, using a Quarto definition list.

Minimum sections for a newly reviewed paper are: **Source scope**,
**One-sentence contribution**, **Reusable claims**, **Method relevance**,
**Limits and disagreement**, and **Open questions / re-read triggers**.

