# Data and code availability package — author verification required

Status: **not ready to paste into a submission**. This file records the required deposit and wording decisions without asserting a repository, DOI, licence, or access condition that has not been confirmed.

## Inventory and access route

| Evidence family | Role in the paper | Current route | Submission action |
|----|----|----|----|
| GLAST lake-surface-water-temperature reconstruction and lake metadata | Primary third-party input | Reused public data | Cite the exact release and persistent source; record version/date accessed. |
| HydroLAKES attributes and lake identifiers | Third-party spatial/morphometric input | Reused public data | Cite the exact release and persistent source; record version/date accessed. |
| Derived annual, seasonal, trajectory, PCA and robustness tables | Generated processed research data | Local ignored `data-process/derived/` outputs | Deposit a documented, compact reproduction package with figure source tables and a manifest. |
| Main and supplementary figure source data | Generated processed research data | Produced from curated outputs during render | Deposit panel-level source data with figure/table mapping. |
| Julia processing pipeline | Code required to reproduce durable outputs | Local `data-process/` Git repository | Create a public archival release, include `Project.toml`/`Manifest.toml`, task manifest and run instructions. |
| Quarto/R manuscript rendering code | Code required to reproduce figures and prose | `research-site` Git repository | Create a tagged archival release; pin figure dependencies and link the release to the data record. |

## Working draft — Data Availability

> **Do not submit before replacing every bracketed field.**

Data generated in this study, including processed lake-level and equal-area trajectory summaries, PCA and robustness outputs, and panel-level source data, will be available in **\[repository\]** under **\[DOI/accession\]**. The deposited record will contain a file manifest, variable definitions and units, processing provenance, and a map from source files to each main and supplementary figure. The publicly available GLAST reconstruction and associated lake metadata were obtained from **\[exact release and persistent identifier\]**; HydroLAKES attributes were obtained from **\[exact release and persistent identifier\]**. Their licences and version/access dates will be recorded in the deposited manifest. No human-participant or sensitive data were analysed.

## Working draft — Code Availability

> **Do not submit before replacing every bracketed field.**

The Julia processing workflow and the Quarto/R code used to generate the analyses and figures will be archived at **\[archival repository DOI or tagged release URL\]**. The release will include the task manifest, environment files, execution instructions and checks needed to reproduce the deposited processed data and manuscript figures. Third-party data are subject to the terms of their original providers and are not redistributed in the code archive.

## Deposit gate

Choose a public data repository and create a draft record; obtain a DOI or stable accession before submission.

Define the compact reproducible data package; do not attempt to deposit all raw local cache files by default.

Write `README.md`, `MANIFEST.csv`, a variable data dictionary, units, missing-value codes, and provenance from raw inputs to each derived family.

Export source-data tables for every displayed panel and map each to figure/table identifiers.

Confirm GLAST and HydroLAKES releases, persistent identifiers, licences and access dates.

Archive a tagged release of the Julia pipeline and Quarto/R site code; record package/runtime versions.

Choose licences only after confirming rights over generated and third-party-derived content.

Reconcile this document, the repository metadata and final manuscript statements word-for-word.

## 中文核对

- 目前可复现的主证据由 GLAST、HydroLAKES、处理后轨迹/PCA 表和两套代码共同支撑；其中处理后数据与逐图 source data 尚未入库。
- 不能把本地 `derived/`、raw 缓存或 GitHub 工作目录直接称作公开数据仓库。投稿前需确定仓库与 DOI/登录号。
- GLAST 与 HydroLAKES 属于复用公共数据，应分别写清版本、永久链接、许可和访问日期；作者不应在代码仓库中重新分发其原始数据，除非许可允许。

Back to top
