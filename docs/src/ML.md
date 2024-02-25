# Meta-Learning Strategies (ML)

Meta-learning strategies are employed to combine opinions from experts to formulate a final portfolio. Each expert's opinion is represented as a vector of weights summing to one. Subsequently, the performance of each expert is quantified, influencing the final portfolio. Each expert can either be a portfolio optimization model or simply a vector of weights as an input. The following meta-learning strategies are currently implemented in the package:

1. [Combination Weights based on Online Gradient Descent (CW-OGD)](@ref)
2. [Continuous Aggregating Exponential Gradient (CAEG)](@ref)
3. [Weak Aggregating Exponential Gradient (WAEG)](@ref)
4. [Moving-window-based Adaptive Exponential Gradient (MAEG)](@ref)

## Combination Weights based on Online Gradient Descent (CW-OGD)

[ZHANG2021107533](@citet) introduced a novel online portfolio selection algorithm leveraging a weighted learning technique and an online gradient descent algorithm. Their strategy demonstrates enhanced robustness by integrating various expert strategies and successfully addresses the challenge of complex computational time. To begin, the authors establish an expert pool encompassing numerous basic expert strategies, among which the strategy investing in a single stock is chosen as the fundamental expert strategy. Subsequently, they employ a loss function to assess the performance of each basic expert strategy and utilize the OGD algorithm to adjust the weight vector for the experts based on their losses.

### Run CW-OGD

**Note:** This package is meant to be used by researchers **NOT FOR MARKET PRACTITIONERS**.
Let's run the algorithm on the real market data. (see [`cwogd`](@ref) for more information.)

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> startdt, enddt = "2019-01-01", "2019-01-10";

julia> querry_open_price = [get_prices(ticker, startdt=startdt, enddt=enddt)["open"] for ticker in tickers];

julia> open_pr = reduce(hcat, querry_open_price) |> permutedims;

julia> querry_close_pr = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> close_pr = reduce(hcat, querry_close_pr) |> permutedims;

julia> rel_pr = close_pr ./ open_pr
3×6 Matrix{Float64}:
 1.01956  0.987568  1.02581  0.994822  1.00796   1.01335
 1.01577  0.973027  1.02216  1.00413   0.997671  1.00395
 1.0288   0.976042  1.03692  0.997097  1.00016   0.993538

julia> gamma = 0.1; H = 0.5;

julia> model = cwogd(rel_pr, gamma, H);

julia> model.b
3×5 Matrix{Float64}:
 0.333333  0.351048  0.346241  0.338507  0.350524
 0.333333  0.321382  0.309454  0.320351  0.311853
 0.333333  0.32757   0.344305  0.341142  0.337623
```

Now, let's investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
julia> metrics = opsmetrics(model.b, rel_pr)
            Cumulative Wealth: 1.0323425490046683
                          APY: 2.8071567518024554
Annualized Standard Deviation: 0.2821163077868604
      Annualized Sharpe Ratio: 9.879459906685577
             Maximum Drawdown: 0.021128559444089628
                 Calmar Ratio: 132.86077355300776

juila> metrics.Sn
7-element Vector{Float64}:
 1.0
 1.0213786603648736
 0.9997984006244297
 1.0282690253184847
 1.0266415196096432
 1.0286957343361505
 1.0323425490046683
```

The result indicates that if we had invested in the given period, we would have gained ~3.2% profit.
It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`mer`](@ref), [`ir`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`ann_std`](@ref), [`calmar`](@ref), and [`mdd`](@ref). See [Performance evaluation](@ref) section for more information.

## Continuous Aggregating Exponential Gradient (CAEG)

[doi:10.1080/01605682.2020.1848358](@citet) presented a new online portfolio strategy that aggregates multiple exponential gradient strategies with different learning rates using the weak aggregating algorithm. The strategy has a universal property that guarantees its average logarithmic growth rate to be the same as the best constant rebalanced portfolio in hindsight. The authors combine the portfolio pool using the following formula:

```math
{\mathbf{b}_{t + 1}} = \frac{{\sum\nolimits_{\eta  \in \tilde E} {{\mathbf{b}_{t + 1}}\left( \eta  \right){{\left( {{S_t}\left( \eta  \right)} \right)}^{\frac{1}{{\sqrt {t + 1} }}}}} }}{{\sum\nolimits_{\eta  \in \tilde E} {{{\left( {{S_t}\left( \eta  \right)} \right)}^{\frac{1}{{\sqrt {t + 1} }}}}} }}
```

where $t$ is the today's index, $\tilde E = \{ {\eta _1},{\eta _2}, \ldots ,{\eta _n}\}$ is a set of EG experts with different $\eta$ parameters, the cumulative wealth of the expert $\eta$ at time $t$ is denoted as ${S_t}\left( \eta  \right)$, and the portfolio by expert $\eta$ at time $t+1$ is represented as $\mathbf{b}_{t + 1}$.

### Run CAEG

Let's run the algorithm on the real market data (Also, see [`caeg`](@ref)):
    
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> startdt, enddt = "2020-1-1", "2020-1-10";

julia> open_querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["open"] for ticker ∈ tickers];

julia> open_ = stack(open_querry) |> permutedims;

julia> close_querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker ∈ tickers];

julia> close_ = stack(close_querry) |> permutedims;

julia> rel_pr = close_./open_;

julia> learning_rates = [0.02, 0.05];

julia> model = caeg(rel_pr, learning_rates);

julia> model.b
3×6 Matrix{Float64}:
 0.333333  0.333322  0.333286  0.333271  0.333287  0.333368
 0.333333  0.333295  0.333271  0.333171  0.333123  0.333076
 0.333333  0.333383  0.333443  0.333558  0.33359   0.333557
```

Now, let's investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
julia> metrics = opsmetrics(model.b, rel_pr)

            Cumulative Wealth: 1.0503793029297175
        Mean Excessive Return: -0.041332740360267836
  Annualized Percentage Yield: 6.880223548529358
Annualized Standard Deviation: 0.16251944416204514
      Annualized Sharpe Ratio: 42.21170939822534
             Maximum Drawdown: 0.006347966314766578
                 Calmar Ratio: 1083.8468900700761
```

The result indicates that if we had invested in the given period, we would have gained ~5% profit. Please check the [Performance evaluation](@ref) section for more information.

## Weak Aggregating Exponential Gradient (WAEG)

Some OPS strategies aim to address the problem of finding optimal values for their parameters. For example, [Yang2020-if](@citet) intoduced another ML algorithm in the scope of OPS, called WAEG. The authors proposed a new online portfolio selection strategy that aggregates multiple Exponential Gradient ([EG](@ref "Exponential Gradient (EG)")) strategies with different learning rates using the weak aggregating algorithm. The strategy has a universal property that guarantees its average logarithmic growth rate to be the same as the best constant rebalanced portfolio in hindsight. The main difference between WAEG and [CAEG](@ref "Continuous Aggregating Exponential Gradient (CAEG)") is that the former uses a finit set of EG experts, while the latter uses a continuous set of EG experts.

### Run WAEG

Let's run the algorithm on the real market data (Also, see [`waeg`](@ref)):

```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(4, 8);

julia> m = waeg(rel_pr, 0.01, 0.2, 20);

julia> m.b
4×8 Matrix{Float64}:
 0.25  0.238126  0.24158   0.2619    0.261729  0.27466   0.25148   0.256611
 0.25  0.261957  0.259588  0.248465  0.228691  0.24469   0.256674  0.246801
 0.25  0.245549  0.247592  0.254579  0.27397   0.259982  0.272341  0.290651
 0.25  0.254368  0.25124   0.235057  0.23561   0.220668  0.219505  0.205937
```

One can analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.

## Moving-window-based Adaptive Exponential Gradient (MAEG)

[Zhang2022-ht](@citet) proposed a novel ML algorithm that updates the learning rate of the [EG](@ref "Exponential Gradient (EG)") algorithm by maximizing the recent cumulative return using the price data in a fixed length moving window. MAEG uses the recent price data in a moving window of fixed length to exploit the “time heterogeneity” of historical market information. This algorithm gets a set of learning rates as one of the inputs. Then, it adaptively adjusts the learning rate to the market condition and directly uses the learning rate in the portfolio calculation process.

### Run MAEG

Let's run the algorithm on the real market data (Also, see [`maeg`](@ref)):

```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(4, 10);

julia> w = 3;

julia> H = [0.01, 0.02, 0.2];

julia> m = maeg(rel_pr, w, H);

julia> m.b
4×10 Matrix{Float64}:
 0.25  0.250307  0.25129   0.251673  0.250823  0.267687  0.313794  0.319425  0.378182  0.427249
 0.25  0.249138  0.248921  0.249289  0.250482  0.23192   0.202576  0.179329  0.160005  0.168903
 0.25  0.250026  0.250656  0.24931   0.24995   0.226647  0.237694  0.237879  0.216076  0.192437
 0.25  0.250528  0.249134  0.249728  0.248744  0.273746  0.245936  0.263367  0.245737  0.211411
```

One can analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.

## References

```@bibliography
Pages = [@__FILE__]
Canonical = false
```
