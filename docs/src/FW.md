# Follow the Winner (FW)

The Follow the Winner (FW) strategies operate on the principle that assets that have shown superior performance in the past are likely to continue excelling in the future. In this package, the following FW strategies have been implemented:

1. Universal Portfolio (UP)
2. Exponential Gradient (EG)

## Universal Portfolio

Universal Portfolio (UP) is a Follow the Winner (FW) strategy introduced by [Cover (1991)](https://doi.org/10.1111/j.1467-9965.1991.tb00002.x). This algorithm is designed to optimize the cumulative return of a portfolio over the investment horizon. UP's approach is centered on daily stock market performance and the distribution of wealth invested in individual stocks.

See [`up`](@ref).

### Run UP

**Note:** This package is meant to be used by researchers **NOT FOR MARKET PRACTITIONERS**.
Let's run the algorithm on the real market data. The data is collected as noted in the [Fetch Data](@ref) section.

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

# Let's run the algorithm on the last 5 days of the data.
julia> m_up = up(prices[:, end-4:end], eval_points=100);

juila> m_up.b
5×5 Matrix{Float64}:
 0.2  0.216518  0.216638  0.21681   0.216542
 0.2  0.203395  0.203615  0.203754  0.203528
 0.2  0.191899  0.191793  0.192316  0.192473
 0.2  0.193023  0.192302  0.191687  0.19208
 0.2  0.195164  0.195652  0.195433  0.195377
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_up.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9879822623031318
 0.9856240412854884
 0.9874863498385578
 0.9778277061434468
 0.9718529924971879
```

The outcome shows that if we had invested during that period, we would have incurred a loss of approximately 2.8% in wealth. It's important to note that [`sn`](@ref) automatically considers the last 5 relative prices in this context.
Let's now examine the algorithm's performance using various significant metrics.

```julia
julia> results = OPSMetrics(m_up.b, rel_price)

            Cumulative Return: 0.972
                          APY: -0.763
Annualized Standard Deviation: 0.088
      Annualized Sharpe Ratio: -8.857
             Maximum Drawdown: 0.028
                 Calmar Ratio: -27.101

julia> results.
APY         Ann_Sharpe  Ann_Std     Calmar      MDD         Sn

julia> results.MDD
0.02814700750281207
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.

## Exponential Gradient

Exponential Gradient (EG) is a FW strategy introduced by [Helmbold et al. (1998)](https://onlinelibrary.wiley.com/doi/10.1111/1467-9965.00058). The authors assert that EG can nearly attain the same wealth as the best constant rebalanced portfolio (BCRP), discerned retrospectively from the actual market outcomes. This algorithm is notably straightforward to implement.

See [`eg`](@ref).

### Run EG

Let's run the algorithm on the real market data. The data is collected as noted in the "[Fetch-Data](@ref)" section.

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

# Let's run the algorithm on the last 5 days of the data.
julia> m_eg = eg(prices[:, end-4:end], eta=0.02);

juila> m_eg.b
5×5 Matrix{Float64}:
 0.2  0.200001  0.200016  0.20003   0.199997
 0.2  0.200049  0.200073  0.200087  0.200064
 0.2  0.19999   0.199973  0.200029  0.200051
 0.2  0.199937  0.199846  0.19978   0.199827
 0.2  0.200023  0.200092  0.200074  0.200061 
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_eg.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9879822623031318
 0.9854825989102248
 0.98713136445759
 0.9773624367829401
 0.9716549466747438
```

The outcome suggests that if we had invested during the given period, we would have incurred a loss of approximately 2.8% of our wealth. It's important to note that [`sn`](@ref) automatically considers the last 5 relative prices in this case. Let's proceed to investigate the algorithm's performance using key metrics.

```julia
julia> results = OPSMetrics(m_eg.b, rel_price)

            Cumulative Return: 0.972
                          APY: -0.765
Annualized Standard Deviation: 0.087
      Annualized Sharpe Ratio: -9.005
             Maximum Drawdown: 0.028
                 Calmar Ratio: -26.9

julia> results.
APY         Ann_Sharpe  Ann_Std     Calmar      MDD         Sn

julia> results.MDD
0.028345053325256164
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.