# Candidate Results tables

These tables are candidate supplementary material. They report descriptive sample composition and PCA stability. They do not contain trend-significance, formal group tests, or temporal-block-omission inference because those analyses have not yet been defined and run.

> 本页是候选补充表，报告描述性样本组成和 PCA 稳健性。不含趋势显著性、正式组间检验或时间块遗漏推断，因为这些分析尚未定义并运行。

## Lake warming by continent

| Continent     | n        | median | mean | q25  | q75  | positive_pct |
|---------------|----------|--------|------|------|------|--------------|
| North America | 49632.00 | 0.17   | 0.19 | 0.10 | 0.27 | 94.93        |
| Europe        | 35149.00 | 0.26   | 0.28 | 0.09 | 0.40 | 90.08        |
| Asia          | 3980.00  | 0.12   | 0.12 | 0.06 | 0.18 | 90.20        |
| South America | 2406.00  | 0.10   | 0.09 | 0.05 | 0.15 | 89.19        |
| Africa        | 712.00   | 0.12   | 0.13 | 0.08 | 0.16 | 99.86        |
| Oceania       | 366.00   | 0.16   | 0.14 | 0.11 | 0.19 | 93.99        |

## PCA variance spectrum

| pc    | explained_pct | cumulative_pct |
|-------|---------------|----------------|
| 1.00  | 52.90         | 52.90          |
| 2.00  | 12.92         | 65.83          |
| 3.00  | 8.55          | 74.37          |
| 4.00  | 5.69          | 80.06          |
| 5.00  | 4.56          | 84.62          |
| 6.00  | 3.64          | 88.26          |
| 7.00  | 3.51          | 91.78          |
| 8.00  | 2.37          | 94.15          |
| 9.00  | 1.55          | 95.70          |
| 10.00 | 1.23          | 96.94          |

## LOCO subspace stability

| omitted_continent | subspace | min_cosine | max_angle_deg | mean_angle_deg | occupied_cells |
|----|----|----|----|----|----|
| Europe | PC2-PC3 | 0.80 | 36.91 | 23.79 | 468.00 |
| Europe | PC4-PC5 | 0.84 | 33.06 | 24.13 | 468.00 |
| North America | PC2-PC3 | 0.70 | 45.42 | 24.90 | 445.00 |
| North America | PC4-PC5 | 0.71 | 44.94 | 31.74 | 445.00 |
| Asia | PC2-PC3 | 0.99 | 9.70 | 6.19 | 455.00 |
| Asia | PC4-PC5 | 0.98 | 11.04 | 8.10 | 455.00 |
| Africa | PC2-PC3 | 0.99 | 6.27 | 3.81 | 492.00 |
| Africa | PC4-PC5 | 0.98 | 10.93 | 7.44 | 492.00 |
| South America | PC2-PC3 | 1.00 | 4.96 | 3.11 | 503.00 |
| South America | PC4-PC5 | 0.99 | 6.26 | 5.47 | 503.00 |
| Oceania | PC2-PC3 | 1.00 | 3.59 | 2.74 | 537.00 |
| Oceania | PC4-PC5 | 0.97 | 13.42 | 8.76 | 537.00 |

Back to top
