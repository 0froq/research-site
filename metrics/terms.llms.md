# Terms

## Global warming hiatus

The period roughly 1998–2012 during which the rate of global mean surface temperature increase slowed relative to the preceding and following decades. Attributed to a combination of ocean heat uptake, internal variability (PDO negative phase), volcanic aerosols, and incomplete radiative forcing accounting (Medhaug et al. 2017, Nature).

Not a pause in warming — total heat content continued to rise — but a slowdown in the rate of surface temperature increase.

## Regime shift

An abrupt, persistent change in the statistical properties (typically the mean) of a time series. Detected by algorithms such as STARS. Not the same as a trend change; a regime shift implies a relatively sudden transition between two quasi-stable states.

## Long-term warming speed

For the warming-acceleration exploration, the canonical quantity is the Theil–Sen slope of raw annual GLAST reconstructed LSWT, presented as its 40-year-equivalent change (\\^\circ\\C / 40 yr). This is a rescaled long-term trend estimate, not a raw 40-year temperature difference.

## Annual warming speed

The trailing-10-year Theil–Sen slope of raw annual reconstructed LSWT, indexed to its endpoint year. Its unit is \\^\circ\\C yr\\^{-1}\\ and it is the primary local warming-speed representation.

## Acceleration

The long-term Sen trend of the valid trailing-10-year local warming-speed sequence. It is termed *warming-speed change* (\\10^{-3}\\ \\^\circ\\C yr\\^{-2}\\): an operational trajectory statistic, not a resolved instantaneous physical acceleration.

## Rolling seasonal and extreme-temperature rate

For each raw annual, DJF, MAM, JJA, SON, maximum 30-day, and minimum 30-day temperature series, the local rate is the trailing-10-year Theil–Sen slope indexed to its endpoint year. These aligned sequences describe whether a lake’s annual local rate co-varies with seasonal or extreme-temperature dynamics. They are not additive components of the annual Theil–Sen slope.

## Seasonal thermal-asymmetry rate

For each year, calculate `warm_cold_contrast = JJA - DJF`, four-season `seasonal_range`, and four-season `seasonal_sd`. The local rate for each is its trailing-10-year Theil–Sen slope indexed to the endpoint year, in °C yr⁻¹. Positive contrast/range rate means warm-season temperature rises relative to cold-season temperature; negative rate means the observed annual thermal cycle contracts. These diagnose relative seasonal asymmetry, not additive seasonal contributions. Frozen `0.0 °C` states remain finite, so their thermal interpretation does not replace seasonal ice-day diagnostics.

## Rolling ice-duration state

Trailing 10-year arithmetic mean of annual ice days, indexed to the same endpoint years as rolling temperature rates. Its within-lake correlation with annual local warming rate is a descriptive alignment statistic; overlapping windows preclude ordinary independent-sample correlation inference. A finite `0.0 °C` frozen-state value is not missing. The producer records endpoint overlap and a correlation-defined flag separately, so a constant rate sequence is not misread as a data gap.

## Seasonal ice-loss rate

For each DJF, MAM, JJA, and SON ice-day series, calculate its trailing-10-year Theil–Sen slope and multiply by \\-1\\. Units are ice days yr⁻¹, so a positive value means seasonal ice duration is shortening. This supports a descriptive comparison of annual local warming rate with contemporaneous seasonal ice loss; it is not evidence that ice loss caused temperature change.

## Direct annual ice-loss rate

The negated trailing-10-year Theil–Sen slope of annual ice days, in ice days yr⁻¹. Positive means total annual ice duration is shortening; negative means it is lengthening. Comparing this direct quantity with the signs of JJA and SON ice-loss rates distinguishes joint seasonal loss from opposed seasonal change. Opposed signs are consistent with calendar redistribution of ice days but do not establish freeze-up or break-up timing without monthly or daily transition dates.

## Sign-conditioned seasonal alignment

For a lake, calculate the annual-rate/seasonal-rate Spearman alignment on all finite endpoints, then repeat using only endpoints with positive annual local rate and only endpoints with negative annual local rate. Each branch requires at least eight finite pairs and a non-constant rank sequence. These are conditional co-variation profiles for warming and cooling states, not seasonal contribution fractions or causal-effect estimates.

Back to top
