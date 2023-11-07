# Meta-Learning Strategies (ML)

Meta-learning strategies are employed to combine opinions from experts to formulate a final portfolio. Each expert's opinion is represented as a vector of weights summing to one. Subsequently, the performance of each expert is quantified, influencing the final portfolio. Each expert can either be a portfolio optimization model or simply a vector of weights as an input. The following meta-learning strategies are currently implemented in the package:

1. Combination Weights based on Online Gradient Descent (CW-OGD) 

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
julia> metrics = OPSMetrics(model.b, rel_pr)
            Cumulative Return: 1.0323425490046683
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
It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.

```@bibliography
```
