# PCA is spatially balanced and uses STL only for low-frequency preprocessing

## Context

Lake records are spatially clustered. Lake-equal PCA would give dense regions more influence over the covariance structure simply because they contain more lakes.

## Choice

Centre annual STL trajectories on the 1981–1990 mean, aggregate them within occupied equal-area cells, and fit PCA to one trajectory per cell. Project lake scores onto those fixed cell-PCA axes. Use monthly STL with `nt=99` only for the low-frequency PCA representation.

## Alternatives and evidence

Lake-equal PCA and alternative smoothing branches were evaluated. Equal-area aggregation explicitly aligns the PCA target with spatial representation; the retained structure is assessed across grids and leave-one-continent-out refits.

## Consequences and reversibility

PC scores describe continuous spatial trajectory structure, not natural lake classes or physical mechanisms. A different grid or preprocessing rule must be treated as a sensitivity branch until it passes the same stability checks.

## Links

[Analysis contract](../../../../docs/analysis-contract.qmd) · [Trajectory decomposition draft](../../../explorations/warming-temporal-pathways/draft/03-warming-pattern-decomposition.llms.md) · [PCA stability investigation](../../../explorations/warming-temporal-pathways/investigations/pca-stability-contract.llms.md)

Back to top
