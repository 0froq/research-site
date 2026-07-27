# Figure export staging area

Generated image files in this directory are intentionally ignored by Git.
Create them from the Quarto project root with:

```bash
bash scripts/export-manuscript-figures.sh
```

The script renders the ten retained main-text figures at 600 dpi, prints
per-page progress, then verifies the pixel dimensions and embedded DPI of each
staged PNG. It only reads existing curated outputs during rendering; it does
not run Julia producers or recompute the `nt = 99` STL pipeline.

This staging output is suitable for visual and raster-resolution review. Before
submission, convert or re-export each numbered panel to the journal's accepted
production format and verify font embedding, final dimensions, color profile
and source-data correspondence. The SVG route currently requires a working R
Cairo/X11 device on the export host.

## Current local QC

The first staging pass completed on 2026-07-27. All ten retained panels are
RGB PNGs with 600 dpi metadata. Figure-01 and Figure-02 are 4,800 × 2,400 px;
Figures 03, 04 and 10 are 7,200 × 2,700 px; Figure-05 is 7,200 × 5,400 px;
Figure-06 is 7,200 × 5,400 px; Figure-07 is 7,200 × 4,800 px; Figure-08 is
7,200 × 5,400 px; and Figure-09 is 7,200 × 6,600 px. This checks raster
resolution, not final journal-format compliance.
