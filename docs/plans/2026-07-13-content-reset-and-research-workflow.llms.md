# Content Reset and Research Workflow Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Establish evidence-bounded next analyses for seasonal ice and cooling hypotheses while preserving only user-reviewed literature notes.

**Architecture:** Put the glacier/ice question in a prose diagnostic protocol rather than treating it as a result. Keep per-paper notes as the only literature record, with a review queue and a structured conversation-to-log workflow for new ideas and decisions.

**Tech Stack:** Quarto, Markdown, existing Julia/R producer contracts.

------------------------------------------------------------------------

### Task 1: Define the seasonal-ice diagnostic

**Files:**

- Create: `explorations/warming-acceleration/prose/seasonal-ice-diagnostics.qmd`

**Step 1:** State the glacial-meltwater explanation as a falsifiable hypothesis, not an attribution claim.

**Step 2:** Specify full-period and late-period response definitions, JJA contrast tests, ice-duration contrasts, and required glacier-catchment evidence.

**Step 3:** List alternative explanations and the conditions required before a mechanism claim.

### Task 2: Preserve note provenance

**Files:**

- Delete: `notes/paper-collection.qmd`
- Delete: `notes/points/lake-warming-hiatus-mechanisms.qmd`
- Modify: `notes/index.qmd`
- Modify: `_quarto.yml`

**Step 1:** Remove the two non-user-reviewed aggregation notes and all navigation to them.

**Step 2:** Retain `notes/papers/*.qmd` as the user-reviewed note corpus.

### Task 3: Create review and discussion records

**Files:**

- Create: `notes/reading-queue.qmd`
- Create: `notes/research-dialogue.qmd`

**Step 1:** Define the candidate → briefed → accepted/rejected reading workflow and prohibition on creating paper notes before user approval.

**Step 2:** Define a lightweight hypothesis, decision, and log-recording protocol for collaborative analysis discussions.

### Task 4: Update research history and validate

**Files:**

- Modify: `explorations/warming-acceleration/log/2026-07-12.qmd`
- Create: `explorations/warming-acceleration/log/2026-07-13.qmd`

**Step 1:** Correct the obsolete Chapter 2 pathname in the prior log.

**Step 2:** Record the raw-annual metric decision, PCA boundary, retired STARS workflow, helper refactor, and seasonal-ice diagnostic next step.

**Step 3:** Render all new/edited QMD documentation and check navigation links.

Back to top
