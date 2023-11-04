```@meta
DocTestSetup = quote
    using OnlinePortfolioSelection
end
```

# Introduction

Online Portfolio Selection (OPS) strategies are trading algorithms that sequentially allocate capital among a group of assets to maximize the final returns of the investment. It is a fundamental problem in computational finance that has been extensively studied across several research communities, including finance, statistics, artificial intelligence, machine learning, and data mining. From an online machine learning perspective, it is formulated as a sequential decision problem and there are a variety of state-of-the-art approaches that have been developed to solve it. These approaches are grouped into several major categories, including benchmarks, “Follow-the-Winner” approaches, “Follow-the-Loser” approaches, “Pattern-Matching” based approaches, and "Meta-Learning" Algorithms [[1](https://arxiv.org/abs/1212.2129)].
This package provides an efficient implementation of OPS algorithms. The algorithms are implemented in Julia in a fully type-stable manner. All the algorithms return an object of type `OPSAlgorithm` which can be used to query the portfolio weights, number of assets, and the name of the algorithm. Sixteen algorithms are implemented so far and more will be added in the future. The available algorithms are:

1. Constant Rebalanced Portfolio (CRP)
2. Exponential Gradient (EG)
3. Universal Portfolio (UP)
4. Correlation-driven Nonparametric Learning
  - 4.1 CORN-U
  - 4.2 CORN-K
- Passive Aggressive Mean Reversion (PAMR)

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
pkg> add https://github.com/shayandavoodii/OnlinePortfolioSelection.jl.git
```

# Quick Start

The package can be imported by running the following command in the Julia REPL:

```julia
julia> using OnlinePortfolioSelection
```

One can perform several strategies on a given dataset and analyse and compare the results. The following code snippet shows how to perform the strategies on a given dataset and compare the results:

```julia
juila> using CSV, DataFrames

# read adjusted close prices
julia> pr = CSV.read("data\\sp500.csv", DataFrame) |> Matrix |> permutedims;

julia> pr = pr[2:end, :];

julia> market_pr = pr[1, :];

julia> size(pr)
(24, 1276)
```

The dataset contains the adjusted close prices of 24 stocks in the S&P 500 within 1276 trading days. Now, suppose we want to perform the strategies on the last 50 days of the dataset with default arguments:

```julia
julia> m_corn_u = cornu(pr, 50, 3);

julia> m_corn_k = cornk(pr, 50, 3, 2, 2);

juila> m_drcorn_k = dricornk(pr, market_pr, 50, 5, 5, 5);
```

Now, let's plot the trend of daily cumulative budgets of each algorithm. For this, we have to calculate it using the achieved portfolio weights and relative prices in the same time period:

```julia
# calculate the relative prices
julia> rel_pr = pr[:, 2:end] ./ pr[:, 1:end-1];

julia> models = [m_corn_u, m_corn_k, m_drcorn_k];

# calculate the cumulative budgets
julia> budgets = [sn(model.b, rel_pr[:, end-49:end]) for model in models];

julia> using Plots

julia> plot(
            budgets, 
            label = ["CORN-U" "CORN-K" "DRICORN-K"], 
            xlabel = "Day", ylabel = "Cumulative return", legend = :bottomleft,
       )
```

```@raw html
<img src="assets/cumulative_budgets.png" width="100%">
```

The plot shows that the cumulative return of CORN-K outperforms the other algorithms almost all the time. Note that the initial investment for all of the algorithms is set to 1 (this can be modified by setting the keyword argument `init_budg` for each algorithm). Now, let's investigate the performance of the algorithms in terms of some of prominent performance metrics:

```julia
julia> all_metrics = OPSMetrics.([m_corn_u.b, m_corn_k.b, m_drcorn_k.b], Ref(rel_pr));
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

The `comp_algs` shows that CORN-K outperforms the other algorithms in terms of annualizeed percentage yield (APY), annualized Sharpe ratio, Calmar ratio, and maximum drawdown (MDD). However, the annualized standard deviation of CORN-K is higher than the other algorithms in this dataset. Note that these metrics can be calculated individually by calling the corresponding [`sn`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`ann_std`](@ref), [`calmar`](@ref), and [`mdd`](@ref) functions. See the [Performance evaluation](@ref) for more details.
