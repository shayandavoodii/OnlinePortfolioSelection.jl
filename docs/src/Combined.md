# Introduction

Nowadays researchers are trying to take advantage of each strategy and propose new methods that combine them. I plan to implement some of these methods in this package. A list of the methods that I've implemented so far is as follows:
1. LOcal ADaptive learning system (LOAD)
2. MRvol

## LOcal ADaptive learning system (LOAD)
[GUAN2019104958](@citet) proposed a new OPS method, named LOcal ADaptive learning system (LOAD), which is a combination of the Follow the Winner (FW) and Follow the Loser principles. They tried to find the stocks that have a positive trend in the most recent time window by fitting a linear regression on the price data of the stocks against time. They used momentum principle to predict the next price of assets in this case. On the other hand, for the stocks that does not have a satisfactory trend in the most recent time window, they used the mean reversion principle to predict the next price of assets. They claim that through this fusion, the overall system can be more adaptive and effective than systems based on single strategies. After predicting the next prices, the next relative prices are predicted and used in the portfolio optimization.

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

julia> model = load(prices, d_fac, window, horizon, eta);

# Get the portfolio weights
julia> model.b
3×5 Matrix{Float64}:
 0.333333  2.65043e-10  1.65697e-8  0.669392  0.329286
 0.333333  1.0          1.0         0.330608  0.670714
 0.333333  0.0          0.0         0.0       0.0 
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

## MRvol

Combination of meta-learning algorithms with other strategies are also investogated. For example, [LIN2024121472](@citet) proposed a new OPS method, named MRvol, which is a combination of the Follow the Loser (FL) and Meta-Learning (ML) strategies. First, they try to select the stocks that have the relative price bellow than 1 as the first filter, and then search for the stock that have the most relative volume value among the filtered stocks as the second filter. Then, they apply a meta-algorithm to integrate expert opinions (i.e., expert strategies), which are obtained based on mean reversion and trading volume. Thirdly, they determine the window size of the expert strategy as W and establish an expert strategy. When the expert constructs a stock portfolio, he/she identifies an investment target asset for each period, so there are W investment target assets. As they said, in order to reduce investment risk and increase diversification of investment, this paper considers using moving window data of different sizes to construct a pool of expert strategies, which is also called a pool of expert opinions, and then applies meta-algorithm in machine learning technique to integrate expert opinions to propose an investment strategy.

### Run MRvol

Let's run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> startdt, enddt = "2019-01-01", "2020-01-01";

julia> querry_open_price = [get_prices(ticker, startdt=startdt, enddt=enddt)["open"] for ticker in tickers];

julia> open_pr = reduce(hcat, querry_open_price) |> permutedims;

julia> querry_close_pr = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> close_pr = reduce(hcat, querry_close_pr) |> permutedims;

julia> querry_vol = [get_prices(ticker, startdt=startdt, enddt=enddt)["vol"] for ticker in tickers];

julia> vol = reduce(hcat, querry_vol) |> permutedims;

julia> rel_pr = (close_pr ./ open_pr)[:, 2:end];

julia> rel_vol = vol[:, 2:end] ./ vol[:, 1:end-1];

julia> size(rel_pr) == size(rel_vol)
true

julia> horizon = 100; Wₘᵢₙ = 4; Wₘₐₓ = 10; λ = 0.05; η = 0.01;

julia> r = mrvol(rel_pr, rel_vol, horizon, Wₘᵢₙ, Wₘₐₓ, λ, η);

julia> r.b
3×100 Matrix{Float64}:
 0.333333  0.0204062  0.0444759   …   0.38213   0.467793      
 0.333333  0.359864   0.194139        0.213264  0.281519
 0.333333  0.61973    0.761385        0.404606  0.250689

julia> sum(r.b, dims=1) .|> isapprox(1.0) |> all
true
```

Now, let's investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
julia> metrics = OPSMetrics(r.b, rel_pr)
            Cumulative Return: 1.0277067897356449
                          APY: 0.07129838196490379
Annualized Standard Deviation: 0.1224831726093685
      Annualized Sharpe Ratio: 0.41881983354977265
             Maximum Drawdown: 0.0692690958483587
                 Calmar Ratio: 1.0292956922808336

julia> metrics.Sn
101-element Vector{Float64}:
 1.0
 0.9945454662509302
 0.9889386321026037
 1.0108661401532446
 ⋮
 1.0219508111711197
 1.0185657113697373
 1.0277067897356449
```

The result of `metrics.Sn` indicates that if we had invested in the given period, we would have gained ~2.8% profit. It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.