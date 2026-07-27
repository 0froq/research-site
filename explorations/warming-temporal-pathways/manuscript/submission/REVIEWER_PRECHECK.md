# Pre-submission reviewer check — 2026-07-27

Internal review record; it is excluded from the rendered manuscript. This is a
bounded reviewer-style assessment of the current Quarto manuscript, figures,
methods and local data/code inventory. It is not an editorial decision.

## Review setup

- **Input scope:** the full manuscript source, main and supplementary figure
  architecture, active methods, bibliography and availability inventory.
- **Assessment boundary:** no independent audit of the GLAST product, raw
  satellite observations, external code archive, data deposit, author list or
  institutional approvals was possible from the local manuscript.
- **Shared claim:** reconstructed 1981--2020 LSWT records show a temporal
  geography in which comparable net warming can have contrasting local-rate
  histories; spatially balanced PCA identifies a robust leading low-frequency
  background and a bounded secondary timing plane. Climate-index fields are a
  descriptive follow-up target, not attribution.

## Reviewer 1 — scientific contribution and claim boundaries

**Assessment.** The manuscript has a coherent descriptive contribution: it
separates net LSWT displacement from its within-period timing at substantially
larger global coverage than prior comparison studies. The manuscript is most
compelling as a global-change and limnology resource paper with an explicit
spatial estimand, not as a circulation-mechanism paper.

**Strengths.** The primary metric is raw annual LSWT; the PCA is clearly
restricted to low-frequency covariance; PC2--PC3 rank exchange is reported
rather than hidden; and Results 06 is correctly bounded.

- **Concern ID: R1-M1 — novelty-positioning**
  - **Claim pointer:** Introduction, “What this study resolves”; Discussion,
    opening section.
  - **Evidence pointer:** continuous 31-endpoint local-rate histories and the
    comparison with 155-lake period analysis.
  - **Concern:** the manuscript needs a final literature-led check that no
    directly comparable global analysis already combines moving Sen histories,
    spatially balanced PCA and robustness bounds. The current comparison set is
    plausible but deliberately small.
  - **Resolution test:** complete paper notes for the closest global LSWT
    trajectory/comparison studies and state the direct method contrast in one
    precise sentence.
  - **Status:** open literature gate.

- **Concern ID: R1-M2 — scope-of-inference**
  - **Claim pointer:** Discussion, “Climate associations locate a research
    target”; Conclusion, NAO/AO paragraph.
  - **Evidence pointer:** Results 06 and supplementary association atlas.
  - **Concern:** the wording is already cautious, but any title, abstract,
    cover letter or press-facing summary must retain “association screen” and
    omit “teleconnection driver” or “circulation mechanism”.
  - **Resolution test:** apply the terminology ledger to all submission-facing
    metadata.
  - **Status:** controlled by editorial check.

## Reviewer 2 — statistical and spatial design

**Assessment.** The analysis defines its two estimands unusually clearly:
lake-equal distributions and covariance among represented equal-area cells.
The rolling-window dependence, PCA sign ambiguity and secondary-plane
instability are explicitly reported.

**Strengths.** The primary slopes are effect sizes, not significance-filtered
records; hatching is restricted to a stated descriptive use; and leave-one-
continent/decade and representation checks match the stated PCA claims.

- **Concern ID: R2-M1 — reconstruction uncertainty**
  - **Claim pointer:** Methods, “Data and scope”; Discussion, “Scope and
    limitations”.
  - **Evidence pointer:** GLAST is described as a calibrated reconstruction,
    but uncertainty is not propagated into long-term slopes or PCA geometry.
  - **Concern:** readers should not infer in-situ-level certainty from the
    maps or individual-lake examples.
  - **Resolution test:** retain and, at final submission, strengthen the
    sentence that claims concern reconstructed surface conditions; cite the
    product validation and state whether a product-uncertainty ensemble is
    unavailable or outside the product design.
  - **Status:** wording present; source-product audit still open.

- **Concern ID: R2-M2 — secondary-plane transportability**
  - **Claim pointer:** Results 05; Discussion, “Robustness defines what can be
    carried forward”; Conclusion, PC2--PC3 paragraph.
  - **Evidence pointer:** weakest omissions are North America, Europe and
    record-end blocks.
  - **Concern:** PC2 and PC3 cannot be reported as independently transferable
    global modes.
  - **Resolution test:** report only the joint PC2--PC3 plane or
    rotation-invariant magnitude wherever the result is compared across
    perturbations.
  - **Status:** resolved in main text; retain during copy-editing.

## Reviewer 3 — reproducibility, figures and accessibility

**Assessment.** The rendered argument has a clean nine-figure main-text
architecture and the companion tables preserve numerical auditability. The
source-level definitions are unusually traceable through the analysis
contract.

**Strengths.** Captions specify aggregation units and interpretive limits;
main text no longer treats diagnostics as independent display items; Chinese
blocks guide supervisor review without entering a submission export.

- **Concern ID: R3-M1 — public data and code deposit**
  - **Claim pointer:** submission availability package.
  - **Evidence pointer:** `DATA_CODE_AVAILABILITY.md` contains unresolved
    repository, DOI, release and licence fields.
  - **Concern:** this is a formal submission blocker, not a prose issue.
  - **Resolution test:** create the data record and tagged code releases;
    include panel-level source data, manifests, versions and exact GLAST/
    HydroLAKES access information; then replace all placeholders verbatim.
  - **Status:** open external-author action.

- **Concern ID: R3-M2 — submission graphics package**
  - **Claim pointer:** all main and supplementary figures.
  - **Evidence pointer:** figures render correctly in Quarto, but an
    editorial-vector/TIFF export manifest has not been produced.
  - **Concern:** rendered PNG/HTML previews are not a journal submission
    graphics package.
  - **Resolution test:** export the final numbered panels at journal-specified
    dimensions and verify embedded fonts, panel lettering, vector/raster
    resolution and source-data mapping.
  - **Status:** open production gate.

## Cross-review synthesis

**Consensus strengths:** the paper has a coherent descriptive claim, preserves
the raw-data/PCA distinction, documents the unstable secondary structure, and
keeps climate associations below attribution. Its main audience includes lake
and global-change scientists, spatial statisticians and researchers designing
ecological or heat-budget comparisons.

**Consensus risks:** the contribution must remain positioned as a descriptive
global trajectory framework; independent source-product uncertainty and public
reproduction deposits are not yet proven. These are not grounds to remove
Results 01--05, but they set the conditions for submission wording and
materials.

**Readiness posture:** scientifically reviewable draft; not yet administratively
submittable until the literature, deposit and production gates above are closed.

The associated statistical-design and author-input record is maintained in
`REPORTING_SUMMARY_DRAFT.md`.
