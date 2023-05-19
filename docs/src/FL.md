# Follow the Loser (FL)
follow the loser has been introduced by Borodin and [Vincent (2004)](https://proceedings.neurips.cc/paper/2003/hash/8c9f32e03aeb2e3000825c8c875c4edd-Abstract.html) in which, the investment weight is transferred from a stock provided a better performance in the past to a stock with unfavorable performance, since the approach considers that a stock with an undesirable performance in the past is able to provide a desirable return in the future. In this package, the following FL strategy is implemented so far:
1. Reweighted Price Relative Tracking System for Automatic Portfolio Optimization
2. Anti-Correlation (Anticor)

## Reweighted Price Relative Tracking System for Automatic Portfolio Optimization (RPRT)
RPRT is a FL strategy proposed by [Lai et al. (2018)](https://doi.org/10.1109/TSMC.2018.2852651). In the price prediction stage, it automatically assigns separate weights to the price relative predictions according to each asset’s performance, and these weights will also be automatically updated. In the portfolio optimizing stage, they proposed a novel tracking system with a generalized increasing factor to maximize the future wealth of next period. Through their study, an efficient algorithm is designed to solve the portfolio optimization objective, which is applicable to large-scale and time-limited situations. According to their extensive experiments on six benchmark datasets from real financial markets with diverse assets and different time spans, RPRT outperforms other state-of-the-art systems in cumulative wealth, mean excess return, annual percentage yield, and some typical risk metrics. Moreover, it can withstand considerable transaction costs and runs fast. It indicates that RPRT is an effective and efficient online portfolio selection system.

See [`rprt`](@ref).

### Run RPRT
**Note:** This package is meant to be used by researchers **NOT FOR MARKET PRACTITIONERS**.
Let's run the algorithm on the real market data. In this case, the data is collected as noted in the [Fetch Data](@ref) section.

Let's run the algorithm on the given data (named as `prices`):

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

julia> window_length, threshold, epsilon = 2, 0.6, 40;

# Let's run the algorithm for the last 5 days of the data.
julia> prices = prices[:, end-4:end];

julia> m_rprt = rprt(prices, w=window_length, theta=threshold, epsilon=epsilon);

# Get the weights of the assets for each day
juila> m_rprt.b
5×5 Matrix{Float64}:
 0.2  0.2  0.0  0.0  0.0
 0.2  0.2  0.0  0.0  0.0
 0.2  0.2  0.0  0.0  0.0
 0.2  0.2  1.0  1.0  1.0
 0.2  0.2  0.0  0.0  0.0
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_rprt.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9879822800308067
 0.985480892911241
 0.9646654456994471
 0.9392966194100733
 0.9448257537201438
```

The result indicates that if we had invested in the given period, we would have lost ~6.3% of our wealth. Note that [`sn`](@ref) automatically takes the last 5 relative prices in this case.
Now, let's investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
julia> results = OPSMetrics(m_rprt.b, rel_price)

            Cumulative Return: 0.945
                          APY: -0.943
Annualized Standard Deviation: 0.202
      Annualized Sharpe Ratio: -4.760
             Maximum Drawdown: 0.061
                 Calmar Ratio: -15.531

julia> results.
APY         Ann_Sharpe  Ann_Std     Calmar      MDD         Sn

julia> results.MDD
0.06070338058992675
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.

## Anti-Correlation (Anticor)
Anticor is a FL strategy proposed by [Borodin and El-Yaniv (2004)](https://www.doi.org/10.1613/jair.1336). The idea of Anticor is to exploit the mean-reversion property of asset prices. Based on two consecutive market windows of size w wealth is transferred from asset i to asset j if the growth rate of asset i is greater than the growth rate of asset j in the most recent window. Additionally, the correlation between asset i in the second last window and asset j in the last window must to be positive. The amount of wealth transferred from asset i to j depends on the strength of correlation between the assets and the strength of "self-anti-correlations" between each asset i. [[1](https://rdrr.io/github/ngloe/olpsR/man/alg_Anticor.html)]

See [`anticor`](@ref).

### Run Anticor
**Note:** This package is meant to be used by researchers **NOT FOR MARKET PRACTITIONERS**.
Let's run the algorithm on the real market data. In this case, the data is collected as noted in the [Fetch Data](@ref) section.

Let's run the algorithm on the given data (named as `prices`):

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

julia> window_size = 2;

# Let's run the algorithm for the last 15 days of the data.
julia> m_anticor = anticor(prices[:, end-14:end], window_size);

# Get the weights of the assets for each day
juila> m_anticor.b
5×15 Matrix{Float64}:
 0.2  0.2  0.2  0.2  0.266667   0.0  …  0.0  0.0  0.0  0.0  0.0  0.0  0.0   
 0.2  0.2  0.2  0.2  0.0333333  0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0   
 0.2  0.2  0.2  0.2  0.0        0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0   
 0.2  0.2  0.2  0.2  0.433333   1.0     1.0  1.0  1.0  1.0  1.0  1.0  1.0
 0.2  0.2  0.2  0.2  0.266667   0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_anticor.b, rel_price)
16-element Vector{Float64}:
 1.0
 1.0026929997309684
 0.9931968903246916
 0.9939468872805755
 0.9941204319128776
 ⋮
 0.9528191316023853
 0.9355287642277988
 0.9157684119500683
 0.8916854826115842
 0.8969343557511426
```

The result indicates that if we had invested in the given period, we would have lost ~10.3% of our wealth. Note that [`sn`](@ref) automatically takes the last 15 relative prices in this case.

Now, let's investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
julia> results = OPSMetrics(m_anticor.b, rel_price)

            Cumulative Return: 0.8969343557511426
                          APY: -0.8391655504688253
Annualized Standard Deviation: 0.1618626725690273
      Annualized Sharpe Ratio: -5.307990636954478
             Maximum Drawdown: 0.11070937679745295
                 Calmar Ratio: -7.579895892685864

julia> results.MDD
0.11070937679745295
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.