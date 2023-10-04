# Introduction

Nowadays researchers are trying to take advantage of each strategy and propose new methods that combine them. I plan to implement some of these methods in this package. A list of the methods that I've implemented so far is as follows:
1. LOcal ADaptive learning system (LOAD)

## LOcal ADaptive learning system (LOAD)
(Guan & An (2019))[https://doi.org/10.1016/j.knosys.2019.104958] proposed a new OPS method, named LOcal ADaptive learning system (LOAD), which is a combination of the Follow the Winner (FW) and Follow the Loser principles. They tried to find the stocks that have a positive trend in the most recent time window by fitting a linear regression on the price data of the stocks against time. They used momentum principle to predict the next price of assets in this case. On the other hand, for the stocks that does not have a satisfactory trend in the most recent time window, they used the mean reversion principle to predict the next price of assets. They claim that through this fusion, the overall system can be more adaptive and effective than systems based on single strategies. After predicting the next prices, the next relative prices are predicted and used in the portfolio optimization.

### Run LOAD

**Note:** This package is meant to be used by researchers **NOT FOR MARKET PRACTITIONERS**.
Let's run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "AMZN"];

julia> startdt, enddt = "2022-04-01", "2023-04-27";

julia> prices = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> prices = reduce(hcat, prices);

julia> prices = prices |> permutedims;

julia> d_fac, window, horizon, eta = 0.5, 10, 5, 0.1;

julia> model, St = load(prices, d_fac, window, horizon, eta);

# Get the portfolio weights
julia> model.b
3×5 Matrix{Float64}:
 0.333333  2.65043e-10  1.65697e-8  0.669392  0.329286
 0.333333  1.0          1.0         0.330608  0.670714
 0.333333  0.0          0.0         0.0       0.0 

# Get the cumulative wealth of the portfolio over the trading period
julia> St
6-element Vector{Float64}:
 1.0
 0.9937811173943497
 0.9925654837139548
 0.9787063658040356
 0.9652327928615669
 1.012107319760618
```

The result indicates that if we had invested in the given period, we would have gained ~1.2% profit. Now, let's investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
juli> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> metrics = OPSMetrics(model.b, rel_price)
            Cumulative Return: 1.0121073197606183
                          APY: 0.8340827024050514
Annualized Standard Deviation: 0.40329283437815505
      Annualized Sharpe Ratio: 2.0185895533212266
             Maximum Drawdown: 0.034767207138433065
                 Calmar Ratio: 23.990500562325092

julia> metrics.Sn
6-element Vector{Float64}:
 1.0
 0.9937811173943497
 0.9925654837139548
 0.9787063658040356
 0.9652327928615669
 1.0121073197606183
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.