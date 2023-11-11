# Follow the Winner (FW)

The Follow the Winner (FW) strategies operate on the principle that assets that have shown superior performance in the past are likely to continue excelling in the future. In this package, the following FW strategies have been implemented:

1. Exponential Gradient (EG)
2. Price Peak Tracking (PPT)

## Exponential Gradient

Exponential Gradient (EG) is a FW strategy introduced by [https://doi.org/10.1111/1467-9965.00058](@citet). The authors assert that EG can nearly attain the same wealth as the best constant rebalanced portfolio (BCRP), discerned retrospectively from the actual market outcomes. This algorithm is notably straightforward to implement.

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

julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

# Let's run the algorithm on the last 5 days of the data.
julia> m_eg = eg(rel_price[:, end-4:end], eta=0.02);

juila> m_eg.b
5×5 Matrix{Float64}:
 0.2  0.199997  0.199998  0.200013  0.200025
 0.2  0.199926  0.199974  0.199997  0.20001
 0.2  0.20005   0.20004   0.200024  0.200076
 0.2  0.200011  0.19995   0.199862  0.1998
 0.2  0.200016  0.200039  0.200105  0.200089
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> sn(m_eg.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9879822592665679
 0.985479797067587
 0.9871244111946488
 0.9773536585545797
 0.9716460557458115
```

The outcome suggests that if we had invested during the given period, we would have incurred a loss of approximately 2.8% of our wealth. It's important to note that [`sn`](@ref) automatically considers the last 5 relative prices in this case. Let's proceed to investigate the algorithm's performance using key metrics.

```julia
julia> results = OPSMetrics(m_eg.b, rel_price)

            Cumulative Return: 0.9716460557458115
        Mean Excessive Return: 0.022895930308319247
  Annualized Percentage Yield: -0.7653568719687657
Annualized Standard Deviation: 0.08718280263716766
      Annualized Sharpe Ratio: -9.008162713433503
             Maximum Drawdown: 0.028353944254188468
                 Calmar Ratio: -26.992959607575816

julia> results.
APY         Ann_Sharpe  Ann_Std     Calmar      MDD         Sn

julia> results.MDD
0.028353944254188468
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.

## Price Peak Tracking (PPT)

The Price Peak Tracking (PPT) algorithm [7942104](@cite) is a novel linear learning system for online portfolio selection, based on the idea of tracking control. The algorithm uses a transform function that aggressively tracks the increasing power of different assets, and allocates more investment to the better performing ones. The PPT objective can be solved by a fast backpropagation algorithm, which is suitable for large-scale and time-limited applications, such as high-frequency trading. The algorithm has been shown to outperform other state-of-the-art systems in computational time, cumulative wealth, and risk-adjusted metrics (See [`ppt`](@ref)).

Let's run the algorithm on the real market data.

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "AMZN", "GOOG", "MSFT"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2020-01-01")["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> model = ppt(prices, 10, 100, 100);

julia> model.b
4×100 Matrix{Float64}:
 0.25  1.0  0.999912    0.999861    …  0.0         0.0       
 0.25  0.0  2.92288e-5  4.63411e-5     1.00237e-8  9.72784e-9
 0.25  0.0  2.92288e-5  4.63411e-5     1.0         1.0
 0.25  0.0  2.92288e-5  4.63411e-5     0.0         0.0
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(model.b, rel_price)
101-element Vector{Float64}:
 1.0
 0.9888797685444782
 0.9863705003355839
 ⋮
 1.250897464327529
 1.2363240910685966
 1.2371383272398555
```

The outcome suggests that if we had invested during the given period, we would have incurred a loss of approximately 2.8% of our wealth. It's important to note that [`sn`](@ref) automatically considers the last 5 relative prices in this case. Let's proceed to investigate the algorithm's performance using key metrics.

```julia
julia> results = OPSMetrics(model.b, rel_price)

            Cumulative Return: 1.2371383272398555
        Mean Excessive Return: -0.15974968844419762
  Annualized Percentage Yield: 0.709598073342651
Annualized Standard Deviation: 0.1837958159802144
      Annualized Sharpe Ratio: 3.751979171369636
             Maximum Drawdown: 0.04210405543971303
                 Calmar Ratio: 16.853437654211092

julia> results.MER
-0.15974968844419762
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing the `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref). See [Performance evaluation](@ref) section for more information.

## References

```@bibliography
Pages = [@__FILE__]
Canonical = false
```