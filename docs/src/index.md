```@meta
DocTestSetup = quote
    using OnlinePortfolioSelection
end
```

# Introduction

Online Portfolio Selection (OPS) strategies represent trading algorithms that sequentially allocate capital among a pool of assets with the aim of maximizing investment returns. This forms a fundamental issue in computational finance, extensively explored across various research domains, including finance, statistics, artificial intelligence, machine learning, and data mining. Framed within an online machine learning context, OPS is defined as a sequential decision problem, providing a range of advanced approaches to tackle this challenge. These approaches categorize into benchmarks, “Follow-the-Winner” and “Follow-the-Loser” strategies, “Pattern-Matching” based methodologies, and "Meta-Learning" Algorithms [li2013online](@cite).
This package offers an efficient implementation of OPS algorithms in Julia, ensuring complete type stability. All algorithms yield an [`OPSAlgorithm`](@ref) object, permitting inquiries into portfolio weights, asset count, and algorithm names. Presently, 24 algorithms are incorporated, with ongoing plans for further additions. The existing algorithms are as follows:

!!! note
    In the following table, the abbreviations **PM**, **ML**, **FL**, and **FW** stand for **Pattern-Matching**, **Meta-Learning**, **Follow the Loser**, and **Follow the Winner**, respectively.

| Row № |                                                   Algorithm                                         | Strategy | Year | Row № |                                       Algorithm                                 | Strategy | Year |
|:-----:|:---------------------------------------------------------------------------------------------------:|:--------:|:----:|:-----:|:-------------------------------------------------------------------------------:|:--------:|:----:|
| 1     | [CORN](@ref Correlation-driven-Nonparametric-Learning-(CORN))                                       | PM       | 2011 | 13    | [MRvol](@ref)                                                                   | Combined | 2023 |
| 2     | [DRICORN-K](@ref Dynamic-RIsk-CORrelation-driven-Non-parametric-(DRICORN))                          | PM       | 2020 | 14    | [CW-OGD](@ref Combination-Weights-based-on-Online-Gradient-Descent-(CW-OGD))    | ML       | 2021 |
| 3     | [CRP](@ref Constant-Rebalanced-Portfolio-(CRP))                                                     | Market   | 1991 | 15    | [ClusLog](@ref)                                                                 | PM       | 2020 |
| 4     | [UP](@ref Universal-Portfolio-(UP))                                                                 | Market   | 1991 | 16    | [PAMR](@ref Passive-Aggressive-Mean-Reversion-(PAMR))                           | FL       | 2012 |
| 5     | [EG](@ref Exponential-Gradient-(EG))                                                                | FW       | 1998 | 17    | [PPT](@ref Price-Peak-Tracking-(PPT))                                           | FW       | 2018 |
| 6     | [BS](@ref Best-Stock-(BS))                                                                          | Market   | 2007 | 18    | [CWMR](@ref Confidence-Weighted-Mean-Reversion-(CWMR))                          | FL       | 2013 |
| 7     | [RPRT](@ref Reweighted-Price-Relative-Tracking-System-for-Automatic-Portfolio-Optimization-(RPRT))  | FL       | 2020 | 19    | [CAEG](@ref Continuous-Aggregating-Exponential-Gradient-(CAEG))                 | ML       | 2020 |
| 8     | [Anticor](@ref Anti-Correlation-(Anticor))                                                          | FL       | 2003 | 20    | [OLDEM](@ref Online-Low-Dimension-Ensemble-Method-(OLDEM))                      | PM       | 2023 |
| 9     | [1/N](@ref Uniform-Portfolio-(1/N))                                                                 | Market   | -    | 21    | [AICTR](@ref Adaptive-Input-and-Composite-Trend-Representation-(AICTR))         | FW       | 2018 |
| 10    | [OLMAR](@ref Online-Moving-Average-Reversion-(OLMAR))                                               | FL       | 2012 | 22    | [EGM](@ref Exponential-Gradient-with-Momentum-(EGM))                            | FW       | 2021 |
| 11    | [Bᴷ](@ref)                                                                                          | PM       | 2006 | 23    | [TPPT](@ref Trend-Promote-Price-Tracking-(TPPT))                                | Combined | 2021 |
| 12    | [LOAD](@ref LOcal-ADaptive-learning-system-(LOAD))                                                  | Combined | 2019 | 24    | [GWR](@ref Gaussian-Weighting-Reversion-(GWR))                                  | FL       | 2019 |

The available methods can be viewed by calling the [`opsmethods`](@ref) function.

# Installation

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

# Quick Start

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

julia> market_pr = pr[1, :];

julia> size(pr)
(24, 1276)
```

The dataset encompasses adjusted close prices of 24 stocks in the S&P 500 across 1276 trading days. Suppose we aim to apply the strategies to the most recent 50 days of the dataset using default arguments:

```julia
julia> m_corn_u = cornu(pr, 50, 3);

julia> m_corn_k = cornk(pr, 50, 3, 2, 2);

juila> m_drcorn_k = dricornk(pr, market_pr, 50, 5, 5, 5);
```

Next, let's visualize the daily cumulative budgets' trends for each algorithm. To do this, we'll need to compute them by utilizing the attained portfolio weights and relative prices within the same time period.

```julia
# calculate the relative prices
julia> rel_pr = pr[:, 2:end] ./ pr[:, 1:end-1];

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

```@raw html
<img src="assets/cumulative_budgets.png" width="100%">
```

The plot illustrates that the cumulative return of CORN-K consistently outperforms the other algorithms. It's important to note that the initial investment for all algorithms is standardized to 1, although this can be adjusted by setting the keyword argument `init_budg` for each algorithm. Now, let's delve into the performance analysis of the algorithms using prominent [performance metrics](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/performance_eval/):

```julia
julia> all_metrics = opsmetrics.([m_corn_u.b, m_corn_k.b, m_drcorn_k.b], Ref(rel_pr));
```

Now, one can embed the metrics in a DataFrame and compare the performance of the algorithms with respect to each other:

```julia
julia> using DataFrames

julia> nmodels = length(all_metrics);

julia> comp_algs = DataFrame(
           Algorithm = ["CORN-U", "CORN-K", "DRICORN-K"],
           APY = [all_metrics[i].APY for i = 1:nmodels],
           Ann_Sharpe = [all_metrics[i].Ann_Sharpe for i = 1:nmodels],
           Ann_Std = [all_metrics[i].Ann_Std for i = 1:nmodels],
           Calmar = [all_metrics[i].Calmar for i = 1:nmodels],
           MDD = [all_metrics[i].MDD for i = 1:nmodels],
       )
3×6 DataFrame
 Row │ Algorithm  APY        Ann_Sharpe  Ann_Std   Calmar    MDD       
     │ String     Float64    Float64     Float64   Float64   Float64   
─────┼─────────────────────────────────────────────────────────────────
   1 │ CORN-U     -0.126009   -0.505762  0.288691  -1.25383  0.100499
   2 │ CORN-K      0.826495    2.48378   0.324705  17.688    0.0467263
   3 │ DRICORN-K  -0.248393   -1.20933   0.221934  -2.54505  0.0975985
```

The comparison analysis, via `comp_algs`, highlights that CORN-K outperforms the other algorithms in terms of annualized percentage yield (APY), annualized Sharpe ratio, Calmar ratio, and maximum drawdown (MDD). However, it's essential to note that the annualized standard deviation of CORN-K surpasses that of the other algorithms within this dataset. These individual metrics can be computed separately by using corresponding functions such as [`sn`](@ref), [`mer`](@ref), [`ir`](@ref). For further insights and details, please refer to the [Performance evaluation](@ref).

## References

```@bibliography
Pages = [@__FILE__]
Canonical = false
```