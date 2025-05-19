
# Introduction {#Introduction}

Nowadays researchers are trying to take advantage of each strategy and propose new methods that combine them. I plan to implement some of these methods in this package. A list of the methods that I&#39;ve implemented so far is as follows:
1. [LOcal ADaptive learning system (LOAD)](/Combined#LOcal-ADaptive-learning-system-(LOAD))
  
2. [MRvol](/Combined#MRvol)
  
3. [Trend Promote Price Tracking (TPPT)](/Combined#Trend-Promote-Price-Tracking-(TPPT))
  

## LOcal ADaptive learning system (LOAD) {#LOcal-ADaptive-learning-system-LOAD}

[Guan and An [31]](/refs#GUAN2019104958) proposed a new OPS method, named LOcal ADaptive learning system (LOAD), which is a combination of the Follow the Winner (FW) and Follow the Loser principles. They tried to find the stocks that have a positive trend in the most recent time window by fitting a linear regression on the price data of the stocks against time. They used momentum principle to predict the next price of assets in this case. On the other hand, for the stocks that does not have a satisfactory trend in the most recent time window, they used the mean reversion principle to predict the next price of assets. They claim that through this fusion, the overall system can be more adaptive and effective than systems based on single strategies. After predicting the next prices, the next relative prices are predicted and used in the portfolio optimization.

### Run LOAD {#Run-LOAD}

**Note:** This package is meant to be used by researchers **NOT FOR MARKET PRACTITIONERS**. Let&#39;s run the algorithm on the real market data.

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


The result indicates that if we had invested in the given period, we would have gained ~1.2% profit. Now, let&#39;s investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
juli> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> metrics = opsmetrics(model.b, rel_price)
            Cumulative Wealth: 1.0121073197606183
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


It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat). See [Performance evaluation](/performance_eval#Performance-evaluation) section for more information.

## MRvol {#MRvol}

Combination of meta-learning algorithms with other strategies are also investogated. For example, [Lin _et al._ [32]](/refs#LIN2024121472) proposed a new OPS method, named MRvol, which is a combination of the Follow the Loser (FL) and Meta-Learning (ML) strategies. First, they try to select the stocks that have the relative price bellow than 1 as the first filter, and then search for the stock that have the most relative volume value among the filtered stocks as the second filter. Then, they apply a meta-algorithm to integrate expert opinions (i.e., expert strategies), which are obtained based on mean reversion and trading volume. Thirdly, they determine the window size of the expert strategy as W and establish an expert strategy. When the expert constructs a stock portfolio, he/she identifies an investment target asset for each period, so there are W investment target assets. As they said, in order to reduce investment risk and increase diversification of investment, this paper considers using moving window data of different sizes to construct a pool of expert strategies, which is also called a pool of expert opinions, and then applies meta-algorithm in machine learning technique to integrate expert opinions to propose an investment strategy.

### Run MRvol {#Run-MRvol}

Let&#39;s run the algorithm on the real market data.

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


Now, let&#39;s investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
julia> metrics = opsmetrics(r.b, rel_pr)
            Cumulative Wealth: 1.0277067897356449
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


The result of `metrics.Sn` indicates that if we had invested in the given period, we would have gained ~2.8% profit. It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat). See [Performance evaluation](/performance_eval#Performance-evaluation) section for more information.

## Trend Promote Price Tracking (TPPT) {#Trend-Promote-Price-Tracking-TPPT}

[Dai _et al._ [33]](/refs#DAI2022107957) proposed a new OPS method, named Trend Promote Price Tracing (TPPT), which is a combination of the Follow the Winner (FW) and Follow the Loser (FL) strategies. They tried to employ a three state price prediction function in which investigates through the price trend of the most recent window. For the portfolio selection phase, the algorithm solves investment proportion and feedbacks the increasing ability of assets to the investment proportion in order to maximize the accumulated wealth. See [`tppt`](/funcs#OnlinePortfolioSelection.tppt).

### Run TPPT {#Run-TPPT}

Let&#39;s run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-12")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1);

julia> horizon, w = 3, 3;

julia> model = tppt(prices, horizon, w);

julia> model.b
3×3 Matrix{Float64}:
 0.333333  1.52594e-6  7.35766e-7
 0.333333  5.30452e-6  3.90444e-6
 0.333333  0.999993    0.999995
```


You can analyse the algorithm&#39;s performance using several metrics that have been provided in this package. Check out the [Performance evaluation](/performance_eval#Performance-evaluation) section for more details.

## References {#References}
1. H. Guan and Z. An. _A local adaptive learning system for online portfolio selection_. [Knowledge-Based Systems **186**, 104958](https://doi.org/10.1016/j.knosys.2019.104958) (2019).
  
2. H. Lin, Y. Zhang and X. Yang. _Online portfolio selection of integrating expert strategies based on mean reversion and trading volume_. [Expert Systems with Applications **238**, 121472](https://doi.org/10.1016/j.eswa.2023.121472) (2024).
  
3. H.-L. Dai, C.-X. Liang, H.-M. Dai, C.-Y. Huang and R. M. Adnan. _An online portfolio strategy based on trend promote price tracing ensemble learning algorithm_. [Knowledge-Based Systems **239**, 107957](https://doi.org/10.1016/j.knosys.2021.107957) (2022).
  
