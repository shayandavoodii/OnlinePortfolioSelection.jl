


# Introduction {#Introduction}

Online Portfolio Selection (OPS) strategies represent trading algorithms that sequentially allocate capital among a pool of assets with the aim of maximizing investment returns. This forms a fundamental issue in computational finance, extensively explored across various research domains, including finance, statistics, artificial intelligence, machine learning, and data mining. Framed within an online machine learning context, OPS is defined as a sequential decision problem, providing a range of advanced approaches to tackle this challenge. These approaches categorize into benchmarks, “Follow-the-Winner” and “Follow-the-Loser” strategies, “Pattern-Matching” based methodologies, and &quot;Meta-Learning&quot; Algorithms [[1](/refs#li2013online)].

This package offers an efficient implementation of OPS algorithms in Julia, ensuring complete type stability. All algorithms yield an [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object, permitting inquiries into portfolio weights, asset count, and algorithm names. Presently, 33 algorithms are incorporated, with ongoing plans for further additions. The existing algorithms are as follows:    

::: tip Note

In the following table, the abbreviations **PM**, **ML**, **FL**, and **FW** stand for **Pattern-Matching**, **Meta-Learning**, **Follow the Loser**, and **Follow the Winner**, respectively.

:::

| Row № |                                             Algorithm                                             | Strategy | Year | Row № |                                Algorithm                                 | Strategy | Year |
|:-----:|:-------------------------------------------------------------------------------------------------:|:--------:|:----:|:-----:|:------------------------------------------------------------------------:|:--------:|:----:|
|   1   |                   [CORN](/PM#Correlation-driven-Nonparametric-Learning-(CORN))                    |    PM    | 2011 |  18   |          [CWMR](/FL#Confidence-Weighted-Mean-Reversion-(CWMR))           |    FL    | 2013 |
|   2   |             [DRICORN-K](/PM#Dynamic-RIsk-CORrelation-driven-Non-parametric-(DRICORN))             |    PM    | 2020 |  19   |      [CAEG](/ML#Continuous-Aggregating-Exponential-Gradient-(CAEG))      |    ML    | 2020 |
|   3   |                   [BCRP](/benchmark#Best-Constant-Rebalanced-Portfolio-(BCRP))                    |  Market  | 1991 |  20   |        [OLDEM](/PM#Online-Low-Dimension-Ensemble-Method-(OLDEM))         |    PM    | 2023 |
|   4   |                             [UP](/benchmark#Universal-Portfolio-(UP))                             |  Market  | 1991 |  21   |  [AICTR](/FW#Adaptive-Input-and-Composite-Trend-Representation-(AICTR))  |    FW    | 2018 |
|   5   |                                [EG](/FW#Exponential-Gradient-(EG))                                |    FW    | 1998 |  22   |           [EGM](/FW#Exponential-Gradient-with-Momentum-(EGM))            |    FW    | 2021 |
|   6   |                                 [BS](/benchmark#Best-Stock-(BS))                                  |  Market  | 2007 |  23   |          [TPPT](/Combined#Trend-Promote-Price-Tracking-(TPPT))           | Combined | 2021 |
|   7   | [RPRT](/FL#Reweighted-Price-Relative-Tracking-System-for-Automatic-Portfolio-Optimization-(RPRT)) |    FL    | 2020 |  24   |              [GWR](/FL#Gaussian-Weighting-Reversion-(GWR))               |    FL    | 2019 |
|   8   |                             [Anticor](/FL#Anti-Correlation-(Anticor))                             |    FL    | 2003 |  25   |                [ONS](/benchmark#Online-Newton-Step-(ONS))                |  Market  | 2006 |
|   9   |                             [1/N](/benchmark#Uniform-Portfolio-(1/N))                             |  Market  |  -   |  26   |               [DMR](/FL#Distributed-Mean-Reversion-(DMR))                |    FL    | 2023 |
|  10   |                       [OLMAR](/FL#Online-Moving-Average-Reversion-(OLMAR))                        |    FL    | 2012 |  27   |                 [RMR](/FL#Robust-Median-Reversion-(RMR))                 |    FL    | 2016 |
|  11   |                                           [Bᴷ](/PM#Bᴷ)                                            |    PM    | 2006 |  28   |       [SSPO](/FW#Short-term-Sparse-Portfolio-Optimization-(SSPO))        |    FW    | 2018 |
|  12   |                      [LOAD](/Combined#LOcal-ADaptive-learning-system-(LOAD))                      | Combined | 2019 |  29   |         [WAEG](/ML#Weak-Aggregating-Exponential-Gradient-(WAEG))         |    ML    | 2020 |
|  13   |                                     [MRvol](/Combined#MRvol)                                      | Combined | 2023 |  30   |   [MAEG](/ML#Moving-window-based-Adaptive-Exponential-Gradient-(MAEG))   |    ML    | 2022 |
|  14   |                                      [ClusLog](/PM#ClusLog)                                       |    PM    | 2020 |  31   | [SPOLC](/FL#Short-term-portfolio-optimization-with-loss-control-(SPOLC)) |    FL    | 2020 |
|  15   |            [CW-OGD](/ML#Combination-Weights-based-on-Online-Gradient-Descent-(CW-OGD))            |    ML    | 2021 |  32   |              [TCO](/FL#Transaction-Cost-Optimization-(TCO))              |    FL    | 2018 |
|  16   |                       [PAMR](/FL#Passive-Aggressive-Mean-Reversion-(PAMR))                        |    FL    | 2012 |  33   |          [KTPT](/PM#Kernel-based-Trend-Pattern-Tracking-(KTPT))          |    PM    | 2018 |
|  17   |                               [PPT](/FW#Price-Peak-Tracking-(PPT))                                |    FW    | 2018 |       |                                                                          |          |      |


The available methods can be viewed by calling the [`opsmethods`](/funcs#OnlinePortfolioSelection.opsmethods-Tuple{}) function.

# Installation {#Installation}

The latest stable version of the package can be installed by running the following command in the Julia REPL after pressing `]`:

```julia
pkg> add OnlinePortfolioSelection
```


or

```julia
julia> using Pkg; Pkg.add("OnlinePortfolioSelection")
```


or even

```julia
juila> using Pkg; pkg"add OnlinePortfolioSelection"
```


The dev version can be installed usint the following command:

```julia
pkg> dev OnlinePortfolioSelection

# or

julia> using Pkg; pkg"dev OnlinePortfolioSelection"
```


# Quick Start {#Quick-Start}

The package can be imported by running the following command in the Julia REPL:

```julia
julia> using OnlinePortfolioSelection
```


Multiple strategies can be applied to a given dataset for analysis and comparison of results. The following code snippet demonstrates how to execute these strategies on a provided dataset and compare their outcomes:

```julia
juila> using CSV, DataFrames

# read adjusted close prices
julia> pr = CSV.read("data\\sp500.csv", DataFrame) |> Matrix |> permutedims;

julia> pr = pr[2:end, :];

# calculate the relative prices
julia> rel_pr = pr[:, 2:end] ./ pr[:, 1:end-1];

julia> market_pr = pr[1, :];

julia> rel_pr_market = market_pr[2:end] ./ market_pr[1:end-1];

julia> size(pr)
(24, 1276)
```


The dataset encompasses adjusted close prices of 24 stocks in the S&amp;P 500 across 1276 trading days. Suppose we aim to apply the strategies to the most recent 50 days of the dataset using default arguments:

```julia
julia> m_corn_u = cornu(rel_pr, 50, 3);

julia> m_corn_k = cornk(rel_pr, 50, 3, 2, 2);

juila> m_drcorn_k = dricornk(pr, market_pr, 50, 5, 5, 5);
```


Next, let&#39;s visualize the daily cumulative budgets&#39; trends for each algorithm. To do this, we&#39;ll need to compute them by utilizing the attained portfolio weights and relative prices within the same time period.

```julia
julia> models = [m_corn_u, m_corn_k, m_drcorn_k];

# calculate the cumulative wealth for each algorithm
julia> wealth = [sn(model.b, rel_pr[:, end-49:end]) for model in models];

julia> using Plots

julia> plot(
            wealth, 
            label = ["CORN-U" "CORN-K" "DRICORN-K"], 
            xlabel = "Day", ylabel = "Cumulative return", legend = :bottomleft,
       )
```



![](assets/cumulative_budgets.png)


The plot illustrates that the cumulative wealth of CORN-K consistently outperforms the other algorithms. It&#39;s important to note that the initial investment for all algorithms is standardized to 1, although this can be adjusted by setting the keyword argument `init_budg` for each algorithm. Now, let&#39;s delve into the performance analysis of the algorithms using prominent [performance metrics](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/performance_eval/):

```julia
julia> all_metrics = opsmetrics.([m_corn_u.b, m_corn_k.b, m_drcorn_k.b], Ref(rel_pr), Ref(rel_pr_market));
```


Now, one can embed the metrics in a DataFrame and compare the performance of the algorithms with respect to each other:

```julia
julia> using DataFrames

julia> nmodels = length(all_metrics);

julia> comp_algs = DataFrame(
           Algorithm = ["CORN-U", "CORN-K", "DRICORN-K"],
           MER = [all_metrics[i].MER for i = 1:nmodels],
           IR = [all_metrics[i].IR for i = 1:nmodels],
           APY = [all_metrics[i].APY for i = 1:nmodels],
           Ann_Sharpe = [all_metrics[i].Ann_Sharpe for i = 1:nmodels],
           Ann_Std = [all_metrics[i].Ann_Std for i = 1:nmodels],
           Calmar = [all_metrics[i].Calmar for i = 1:nmodels],
           MDD = [all_metrics[i].MDD for i = 1:nmodels],
           AT = [all_metrics[i].AT for i = 1:nmodels],
       )
3×9 DataFrame
 Row │ Algorithm  MER        IR         APY        Ann_Sharpe  Ann_Std   Calmar    MDD        AT        
     │ String     Float64    Float64    Float64    Float64     Float64   Float64   Float64    Float64   
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ CORN-U     0.0514619  0.0963865  -0.126009   -0.505762  0.288691  -1.25383  0.100499   0.847198
   2 │ CORN-K     0.054396   0.198546    0.826495    2.48378   0.324705  17.688    0.0467263  0.87319
   3 │ DRICORN-K  0.0507907  0.0829576  -0.2487     -1.21085   0.22191   -2.54629  0.0976717  0.0053658
```


The comparison analysis, via `comp_algs`, highlights that CORN-K outperforms the other algorithms in terms of annualized percentage yield (APY), annualized Sharpe ratio, Calmar ratio, and maximum drawdown (MDD). However, it&#39;s essential to note that the annualized standard deviation of CORN-K surpasses that of the other algorithms within this dataset. These individual metrics can be computed separately by using corresponding functions such as [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat). For further insights and details, please refer to the [Performance evaluation](/performance_eval#Performance-evaluation).

## References {#References}
1. B. Li and S. C. Hoi. [_Online Portfolio Selection: A Survey_](https://doi.org/10.48550/arXiv.1212.2129) (2013).
  
