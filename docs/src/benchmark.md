# Benchmark Strategies
Some strategies in the context of online portfolio selection are considered as benchmark strategies. The simplest benchmark strategy is the Buy and Hold (BH) strategy which is called as the *market strategy*. The BAH model invests equally in m assets at the beginning and remains unchanged during the next periods, thus the weights of assets change passively with their price variations. A special BAH model, the Best-Stock (BS), invests all the capital into the best asset over the periods which is an optimal BAH in hindsight. Overall, the Benchmark portfolio selection models are quite simple because they do not adopt complex or sophisticated techniques via statistics and machine learning to explore the patterns within the data. Thus they are often taken as the baselines for performance comparison with new designed models. Another benchmark strategy is the Constant Rebalanced Portfolio (CRP) which assigns a fixed weight to each asset throughout a given period.

See [`crp`](@ref).

### Run CRP
Let's run the algorithm on the real market data. Assume the data (named as `prices`) is collected as noted in the ["Fetch Data"](@ref) section.

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

# Let's run the algorithm on the last 5 days of the data.
julia> m_crp = crp(prices[:, end-4:end]);

juila> m_crp.b
5×5 Matrix{Float64}:
 0.2  0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2  0.2
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_crp.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9879822623031318
 0.9854808899164217
 0.9871240426268018
 0.977351149446221
 0.9716459683279461
```

The result indicates that if we had invested in the given period, we would have lost ~2.8% of our capital. Note that [`sn`](@ref) automatically takes the last 5 relative prices in this case.
Now, let's investiagte the performance of the algorithm according to some of the prominent metrics:

```julia
julia> results = OPSMetrics(m_crp.b, rel_price)

            Cumulative Return: 0.972
                          APY: -0.765
Annualized Standard Deviation: 0.087
      Annualized Sharpe Ratio: -9.008
             Maximum Drawdown: 0.028
                 Calmar Ratio: -26.993

julia> results.
APY         Ann_Sharpe  Ann_Std     Calmar      MDD         Sn

julia> results.MDD
0.02835403167205386
```

It is worht mentioning that each metric can be accessed individually by writing `results.` and pressing `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref).