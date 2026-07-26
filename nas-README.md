---
created: 2026-07-12
last-modified: 2026-07-27
---

## 说明

`redirect.html` 中实现了重定向，
打开后会前往 `https://froq.me/research-site/explorations/warming-temporal-pathways/manuscript/results/01-global-kinematics.html`。

当上面的网站更新后，我**一定**会在 `redirect.html` 中加一条带时间的 log，
通常情况下不需要查看
（也不容易查看，因为用浏览器打开就重定向了，除非用编辑器打打开），
其存在的意义是我手动添加 log 会在 NAS 上有通知。

网站更新后，我**可能**会在这个文件的「更新记录」部分增加关键的内容更新记录，
可作为导读。

## 更新记录

### 2026-07-27

#### 当前交接状态（以此为准）

- 网站公开结构已收敛为：manuscript（六个 Results 小节）、supplementary、investigations、
  literature、log、reference 与 notes。`draft/`、`decisions/` 和 helper debugging 页面已移除。
- manuscript 的六个 Results 文件是正式论证链；seasonal/ice 与 teleconnection candidate
  material 位于 supplementary。investigations 承载模块化探索，不自动提升为论文结论。
- literature 暂时保留三页结构，但已标记为待整体优化；后续应从实际手稿证据 task 出发，
  再决定领域综述、创新性、直接对比、方法审计与机制/边界等分类。
- `site/zotero.bib` 已作为普通 Git 文件提交，远程渲染可复现引用；不再依赖本机绝对链接。
- 部署脚本现在从干净 Git worktree 渲染，避免本地 `_output` 缓存将已删除页面重新发布。
  历史 draft、decision 和被移动页面 URL 保留为自动跳转，不是独立内容页。
- GitHub Pages 已部署。全站当前 render 为 90 页；route source、route 和活动旧路径检查通过。
  已知遗留警告是 Results 01 的 `@tbl-spatial-autocorrelation` 尚未解析。
- 交接检查时，一个完整 `pipeline/run.jl run manuscript --force` 和独立的 `ice-days`
  producer 仍在本机运行；前者已写完 canonical `monthly-stl nt=99` 输出，后续任务尚未
  完成。下一位 agent 应先查看 `/tmp/explore-quarto-manuscript-rerun.log` 与
  `/tmp/explore-quarto-manuscript-rerun.exit`，不得并发启动第二个 full run。

#### 后续工作

1. 以 manuscript 六节为唯一正式写作链，逐段补全证据与行文；不要重建 draft 层。
2. 先从具体 manuscript claim 创建 literature task，再更新 reading queue 和 paper notes；
   暂不提前重构 literature 分类。
3. 若改动 producer，先用 `pipeline/run.jl plan manuscript` 确认依赖；仅在需要时重跑
   昂贵 STL，普通页面渲染不得生产 durable data。
4. 修复或移除 Results 01 中未定义的空间自相关表交叉引用。

#### 管线与站点重构

- `data-process/` 已成为独立的源码 Git 仓库。活动任务由编号 `steps/` 重组为语义化
  `tasks/`：foundation、temperature、metrics、pathways、context 和 experimental。
  原始数据与 `derived/` 输出仍不进入 Git。
- `pipeline/manifest.toml` 现在是唯一活动任务/DAG/dataset catalog；Julia 和 R 都通过
  dataset id 解析输入输出路径。旧 `steps/` 仅保留为本地兼容层，活动代码与页面不再依赖它。
- `site/R/` 分为 core、domains、figures 和 checks。主图 helper 可单独 source/run；QMD
  只负责图层、文字和交叉引用。
- manuscript 现稳定为六个 Results 小节；季节冰、候选表和候选 atlas 位于 supplementary
  或 investigations。86 个历史公开路径已映射到有效的新页面。

#### 验证

- 使用既有 canonical `monthly-stl nt=99` 输出，重新运行 manuscript profile 的其余活动
  producer；lake metadata、annual/ice、annual STL、metrics、trajectory、空间 PCA、
  robustness 与两类描述性 teleconnection 输出均已完成。
- 新 runner 支持显式 `--reuse <task-id>`：只在声明输出存在且非空时复用昂贵上游数据，
  不会静默跳过。
- 完整站点 106 页 render 成功；活动 helper contract、dataset manifest、真实输出完整性、
  legacy route 和活动旧路径检查均通过。

#### 说明

- 未重跑月度 STL 本身。它是唯一显著慢的 producer；本次只为验证重构而复用先前的
  canonical `nt=99` 输出。以后在更换原始输入或 STL 算法时，需显式重跑该任务。
- 此条为当时状态；当前版本已在 GitHub Pages 部署，以上「当前交接状态」为准。

### 2026-07-12（历史记录，非当前工作计划）

#### 进展

- 冰期已处理。
- 分季节已计算，简单分析不同季节差异显著。
  如 DJF 表面气压（SP）对的 acceleration 的影响为正（p = +0.551），
  而 MAM SP 的影响为负（p = -0.523），
  且 SP 的标准差、年均值对 acceleration 的影响都很大（p = 0.482，p = 0.394）。
- 风速？Warming speed 与年均风速关系为正？（p = 0.301）
- 正在跑 ERA5-Land 的部分变量的提取，根据测试的速度，至少还需要一天时间完成。
- 简要分析区域性，不同区域的主导贡献因素不同，且甚至有符号差异
  （如全球来看，降水和增温是负相关，但南美是正相关，反向）。
- 聚类变量去掉了 40 年平均温度，用标准化后 40 年 STL Trend 做 5 类。
  - 用 STL Trend 而非原始温度 / 滑动窗口后的原始温度，已做分析，有强依据。
  - 可解释，且在其他变量（如湖深等）上也有聚集现象，待进一步归因。
- 遥相关对不同区域 / 聚类类型湖泊的影响差异显著。如 C2 类（大部分在西西伯利亚）
  对 lag0 的 NAO 和 lag1 的 AO 反应较其他类偏强；非洲对 lag1 的 Niño3.4 响应强，
  而南美存在两个强 lag，lag0 和 lag1。待进一步分析。

#### 下一步

- 上面的内容写进 draft。
- ERA5-Land 变量提取，归因。
- 聚类尝试严格物理解释。
- GAM 模型。

### 2026-07-20（历史记录，核心定义仍有效）

#### 进展

- 研究主线已收敛为：**全球湖泊增温的时间—空间异质性**。不再以聚类类型、STARS
  或单一“加速度”判定作为主体结果。
- 主分析使用 GLAST 的 raw 年均 LSWT：
  - 长期增温为 1981–2020 年均温度的 Theil–Sen slope（折算为 40 年变化）。
  - 局地增温速度为端点对齐的 10 年滑动 Theil–Sen slope。
  - “增温速度变化”是这条 10 年速度序列的 Sen trend；它描述轨迹更趋向增温或降温，
    **不**解释为瞬时物理加速度。
- STL 只作为 PCA 的低频预处理（`nt = 99`），不再替代 raw 年均温度的主指标。
- PCA 改为等面积空间平衡 PCA：92,245 个湖泊先汇总为 573 个占据格网，再做
  baseline-centred 年 STL trajectory 分解。这样避免湖泊密集区域仅因样本数多而主导
  协方差。PC1–PC5 解释 84.6% 的格网轨迹方差。
  - PC1 是最大的共同低频背景。
  - PC2–PC3 在 leave-one-continent-out 重拟合中可重复、但排序可交换；它们是主要的
    次级描述结构，不是固定物理机制。
  - PC4–PC5 保留为较低优先级、部分混合的细节。
- 季节与冰期模块保留为独立的描述性支路：比较四季、极端温度与冰日的 10 年 rate，
  不把它们当作可相加的年增温贡献，也不再提出冰川融水归因。
- 遥相关部分保留一个经过约束的结果：上一年夏季 NAO/AO 与当年 JJA 去趋势湖温的
  关联场具有连续空间结构；PC2–PC3 可提高该关联场的空间留出预测，而 PC1 的增益很小。
  该结果通过不同格网、空间分块、LOCO 与 leave-one-decade-out 检查，但只作为
  **描述性空间共定位/关联**，不作因果归因。
- 当前完整草稿的阅读顺序：
  1. `01-global-kinematics.qmd`：原始年均增温、10 年局地速度与空间异质性。
  2. `02-seasonal-ice-context.qmd`：季节/冰状态的可选背景模块。
  3. `03-warming-pattern-decomposition.qmd`：等面积 PCA、空间结构与稳定性。
  4. `04-teleconnection-sensitivity.qmd`：JJA NAO/AO 关联场及其与 PCA 的桥接。
  5. `05-discussion.qmd`：结论、边界与后续工作。

#### 同步说明

- `site/` 是独立 Git 仓库并部署到 GitHub Pages；本次新增/修订尚在本地工作区，待逐章
  审阅批注完成后再提交和部署。
- `data-process/` 不在 Git 中，含原始数据和大体积处理产物，仍由 Syncthing/NAS 同步。
  页面渲染只读取其中已产出的 curated outputs，不会在渲染时写入持久分析数据。
- 正式定义见 `site/docs/analysis-contract.qmd`；指标算法说明见
  `site/reference/methods/index.qmd`。

#### 下一步

- 逐章审阅当前 draft，收敛文字与图形，而非继续无约束扩展候选机制。
- 若需进入解释阶段，先定义新的时空关联模型与留出验证契约；ERA5/其他外部变量只能
  支持背景关联，不能直接承担因果结论。
- 审阅完成后，提交 `site/` 并运行部署脚本更新 GitHub Pages。
