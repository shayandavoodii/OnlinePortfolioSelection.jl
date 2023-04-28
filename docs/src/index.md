CurrentModule = OPS
DocTestSetup  = quote
    using OPS
end
```

# Introduction
Online Portfolio Selection (OPS) strategies are trading algorithms that sequentially allocate capital among a group of assets to maximize the final returns of the investment. It is a fundamental problem in computational finance that has been extensively studied across several research communities, including finance, statistics, artificial intelligence, machine learning, and data mining. From an online machine learning perspective, it is formulated as a sequential decision problem and there are a variety of state-of-the-art approaches that have been developed to solve it. These approaches are grouped into several major categories, including benchmarks, “Follow-the-Winner” approaches, “Follow-the-Loser” approaches, “Pattern-Matching” based approaches, and "Meta-Learning" Algorithms[1](https://arxiv.org/abs/1212.2129).
This package provides an efficient implementation of OPS algorithms. The algorithms are implemented in Julia in a fully type-stable manner. All the algorithms return an object of type `OPSAlgorithm` which can be used to query the portfolio weights, number of assets,  cumulative return of portfolio, and the name of the algorithm. Seven algorithms are implemented so far and more will be added in the future. The available algorithms are:
1. Constant Rebalanced Portfolio (CRP)
2. Exponential Gradient (EG)
3. Universal Portfolio (UP)
4. Correlation-driven Nonparametric Learning
    4.1. CORN-U
    4.2. CORN-K
5. Dynamic RIsk CORrelation-driven Non-parametric

# Installation
The dev version of the package can be installed by running the following command in the Julia REPL after pressing `]`:
```julia
pkg> add https://github.com/shayandavoodii/OPS.jl.git
```

# Quick Start
The package can be imported by running the following command in the Julia REPL:
```julia
julia> using OPS
```
One can perform several strategies on a given dataset and analyse and compare the results. The following code snippet shows how to perform the strategies on a given dataset and compare the results:
```julia
# read adjusted close prices
julia> pr = CSV.read("data\\sp500.csv", DataFrame) |> Matrix |> permutedims;

julia> pr = pr[2:end, :];

julia> market_pr = pr[1, :];

julia> size(pr)
(24, 1276)
```
The dataset contains the adjusted close prices of 24 stocks in the S&P 500 within 1276 trading days. Now, suppose we want to perform the strategies on the last 50 days of the dataset with default arguments:
```julia
julia> crp = CRP(pr[:, end-50:end]);

julia> eg = EG(pr[:, end-50:end]);

julia> up = UP(pr[:, end-50:end]);

julia> rprt = RPRT(pr[:, end-50:end]);

julia> corn_u = CORNU(pr, 50, 3);

julia> corn_k = CORNK(pr, 50, 3, 2, 2);

juila> drcorn_k = DRICORNK(pr, market_pr, 50, 3, 2, 2);
```
Now, let's plot the trend of daily cumulative budgets of each algorithm:
```julia
julia> using Plots

julia> plot(
            [crp.budgets, eg.budgets, up.budgets, rprt.budgets,
            corn_u.budgets, corn_k.budgets, drcorn_k.budgets], 
            label = ["CRP" "EG" "UP" "RPRT" "CORN-U" "CORN-K" "DRICORN-K"], 
            xlabel = "Day", ylabel = "Cumulative return", legend = :topleft
       )
```

```@raw html
<img src="assets/cumulative_budgets.png" width="70%">
```

The plot shows that the cumulative return of CORN-K outperforms the other algorithms almost all the time. Note that the initial investment for all of the algorithms is set to 1 (this can be modified by setting the keyword argument `init_budg` for each algorithm).Now, let's investigate the performance of the algorithms in terms of some of prominent performance metrics:
```julia
julia> rel_pr = pr[:, 2:end] ./ pr[:, 1:end-1];

julia> all_metrics = OPSMetrics.([crp.b, eg.b, up.b, rprt.b, corn_u.b, corn_k.b, drcorn_k.b], Ref(rel_pr));
```
Now, one can embed the metrics in a DataFrame and compare the performance of the algorithms with respect to each other:
```julia
julia> using DataFrames

julia> nmodels = length(all_metrics);

julia> comp_algs = DataFrame(
           Algorithm = ["CRP", "EG", "UP", "RPRT", "CORN-U", "CORN-K", "DRICORN-K"],
           APY = [all_metrics[i].APY for i = 1:nmodels],
           Ann_Sharpe = [all_metrics[i].Ann_Sharpe for i = 1:nmodels],
           Ann_Std = [all_metrics[i].Ann_Std for i = 1:nmodels],
           Calmar = [all_metrics[i].Calmar for i = 1:nmodels],
           MDD = [all_metrics[i].MDD for i = 1:nmodels],
       )
7×6 DataFrame
 Row │ Algorithm  APY        Ann_Sharpe  Ann_Std   Calmar    MDD       
     │ String     Float64    Float64     Float64   Float64   Float64   
─────┼─────────────────────────────────────────────────────────────────
   1 │ CRP        -0.289228   -1.41586   0.218403  -2.96123  0.0976717
   2 │ EG         -0.287809   -1.409     0.218459  -2.95441  0.0974169
   3 │ UP         -0.288415   -1.41139   0.218519  -2.95588  0.0975733
   4 │ RPRT       -0.996266   -4.70081   0.21619   -1.4582   0.683216
   5 │ CORN-U     -0.126009   -0.505762  0.288691  -1.25383  0.100499
   6 │ CORN-K      0.826495    2.48378   0.324705  17.688    0.0467263
   7 │ DRICORN-K  -0.248369   -1.20917   0.221946  -2.54495  0.0975929
```
The `comp_algs` shows that CORN-K outperforms the other algorithms in terms of annualizeed percentage yield (APY), annualized Sharpe ratio, Calmar ratio, and maximum drawdown (MDD). However, the annualized standard deviation of CORN-K is higher than the other algorithms in this dataset.
