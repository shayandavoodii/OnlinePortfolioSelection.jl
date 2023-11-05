# Benchmark Strategies
In the domain of online portfolio selection, certain strategies are considered benchmark strategies. One of the simplest is the Buy and Hold (BH) strategy, often referred to as the *market strategy*. BH involves an equal investment in m assets at the beginning, maintaining these allocations throughout the subsequent periods, leading to passive weight adjustments based on the assets' price variations. An optimized version, the Best-Stock (BS) strategy, allocates all capital to the best-performing asset over the periods. These benchmark portfolio selection models are straightforward, lacking the use of sophisticated statistical or machine learning techniques to uncover data patterns. Consequently, they serve as baselines for evaluating the performance of newly developed models. Another benchmark strategy, the Constant Rebalanced Portfolio (CRP), maintains a fixed weight for each asset over a specified period. The currently implemented strategies in this package include:

1. Constant Rebalanced Portfolio (CRP)
2. Best Stock (BS)
3. Uniform Portfolio (1/N)

## CRP
Let's run the algorithm on the real market data. Assume the data (named as `prices`) is collected as noted in the [Fetch Data](@ref) section.

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

The outcome demonstrates that if we had invested during the specified period, we would have incurred a loss of approximately 2.8% of our capital. It's important to note that [`sn`](@ref) automatically considers the last 5 relative prices in this instance. Let's further analyze the algorithm's performance based on some significant metrics:

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

## BS

The model is a variant of the BAH strategy that retroactively acquires the best stock. Within this package, users can select the number of days to retrospectively examine (using the `last_n` keyword argument) and identify the best stock. If `last_n` is either not provided or set to `0`, the algorithm will consider the entire dataset up to the present day for each period to identify the best stock. Conversely, if `last_n` is specified, the algorithm will only consider the performance of each stock within the last `last_n` days and then select the best-performing one. To implement the algorithm on real market data, let's assume the data is collected as detailed in the [Fetch Data](@ref) section.

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

# Let's run the algorithm on the last 10 days of the data.
julia> m_bs = bs(prices[:, end-9:end]);

juila> m_bs.b
5×10 Matrix{Float64}:
 0.2  0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.2  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.2  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.2  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.2  1.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0
```

After running the algorithm, one can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_bs.b, rel_price)
11-element Vector{Float64}:
 1.0
 1.0067934076484562
 1.009228482491198
 1.0188656476194202
 1.0387633347003844
 1.0354766468359777
 1.027215571086806
 1.0305022589512125
 1.0499557074411052
 1.0350324760158582
 1.0255278032954953
```

The outcome suggests that if we had invested during the specified period, we would have gained approximately 2.6% of our capital. Notably, [`sn`](@ref) automatically considers the last 10 relative prices in this scenario.

It's important to highlight that this package offers functions designed to assess the algorithm's performance. For additional insights, refer to the [Performance evaluation](@ref) section.

## 1/N

This model invests equally in all assets. Let's run the algorithm:

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(17, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

# Let's run the algorithm on the last 10 days of the data.
julia> m_uni = uniform(5, 10);

juila> m_uni.b
5×10 Matrix{Float64}:
 0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2  0.2
```

After running the algorithm, one can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(m_uni.b, rel_price)
11-element Vector{Float64}:
 1.0
 1.006793403065235
 1.0044027643134168
 1.0040238271404696
 1.0051064998568846
 0.9884495565932121
 0.9765706200501145
 0.9740981677925922
 0.9757223268076264
 0.9660623342882886
 0.960423009921307
```

The result reveals that if investment had been made during the specified period, a loss of approximately 3.9% of the capital would have been incurred. It's noteworthy that [`sn`](@ref) automatically accounts for the last 10 relative prices in this context.

Additionally, this package offers functions for assessing the algorithm's performance. For further details, refer to the [Performance evaluation](@ref) section.