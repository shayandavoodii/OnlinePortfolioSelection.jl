# Benchmark Strategies
In the domain of online portfolio selection, certain strategies are considered benchmark strategies. One of the simplest is the Buy and Hold (BH) strategy, often referred to as the *market strategy*. BH involves an equal investment in m assets at the beginning, maintaining these allocations throughout the subsequent periods, leading to passive weight adjustments based on the assets' price variations. An optimized version, the Best-Stock (BS) strategy, allocates all capital to the best-performing asset over the periods. These benchmark portfolio selection models are straightforward, lacking the use of sophisticated statistical or machine learning techniques to uncover data patterns. Consequently, they serve as baselines for evaluating the performance of newly developed models. Another benchmark strategy, the Constant Rebalanced Portfolio (CRP), maintains a fixed weight for each asset over a specified period. The currently implemented strategies in this package include:

1. [Constant Rebalanced Portfolio (CRP)](@ref)
2. [Best Stock (BS)](@ref)
3. [Uniform Portfolio (1/N)](@ref)
4. [Universal Portfolio (UP)](@ref)
5. [Online Newton Step (ONS)](@ref)

## Constant Rebalanced Portfolio (CRP)
Let's run the algorithm [COVER451321](@cite) on the real market data. Assume the data (named as `prices`) is collected as noted in the [Fetch Data](@ref) section.

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

The outcome demonstrates that if we had invested during the specified period, we would have incurred a loss of approximately 2.8% of our capital. It's important to note that [`sn`](@ref) automatically considers the last 5 relative prices in this instance. It is possible to analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.

## Best Stock (BS)

The model [KBSSMOP](@cite) is a variant of the BAH strategy that retroactively acquires the best stock. Within this package, users can select the number of days to retrospectively examine (using the `last_n` keyword argument) and identify the best stock. If `last_n` is either not provided or set to `0`, the algorithm will consider the entire dataset up to the present day for each period to identify the best stock. Conversely, if `last_n` is specified, the algorithm will only consider the performance of each stock within the last `last_n` days and then select the best-performing one. To implement the algorithm on real market data, let's assume the data is collected as detailed in the [Fetch Data](@ref) section.

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

## Uniform Portfolio (1/N)

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

## Universal Portfolio (UP)

Universal Portfolio (UP) is a Follow the Winner (FW) strategy introduced by [COVER451321](@citet). This algorithm is designed to optimize the cumulative wealth of a portfolio over the investment horizon. UP's approach is centered on daily stock market performance and the distribution of wealth invested in individual stocks.

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
julia> prices = prices |> transpose;

julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];
# Let's run the algorithm on the last 5 days of the data.
julia> m_up = up(rel_price[:, end-4:end], eval_points=100);

juila> m_up.b
5×5 Matrix{Float64}:
 0.2  0.208371  0.20835   0.208378  0.208491
 0.2  0.171292  0.17157   0.171647  0.171811
 0.2  0.221486  0.221459  0.221315  0.221753
 0.2  0.187741  0.187294  0.186637  0.186165
 0.2  0.21111   0.211327  0.212023  0.21178
```

One can calculate the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> sn(m_up.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9879822800563391
 0.9853362080114016
 0.9872299951993896
 0.9778393831200343
 0.9721457631543731
```

The outcome shows that if we had invested during that period, we would have incurred a loss of approximately 2.7% in wealth. It's important to note that [`sn`](@ref) automatically considers the last 5 relative prices in this context.
Let's now examine the algorithm's performance using various significant metrics.

```julia
julia> results = opsmetrics(m_up.b, rel_price)

            Cumulative Wealth: 0.972
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

It is worth mentioning that each metric can be accessed individually by writing `results.` and pressing `Tab` key. Note that one can individually investigate the performance of the algorithm regarding each metric. See [`sn`](@ref), [`mer`](@ref), [`ir`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`ann_std`](@ref), [`calmar`](@ref), and [`mdd`](@ref). See [Performance evaluation](@ref) section for more information.

## Online Newton Step (ONS)
Another benchmark strategy is the Online Newton Step (ONS) algorithm [10.1145/1143844.1143846](@cite), which implicitly predicts the next price ratio via all historical data with a uniform probability. See [`ons`](@ref).

Let's run the algorithm on the real market data:

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-12")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1);

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> model = ons(rel_pr, 1, 0.005, 0.1);

julia> model.b
3×6 Matrix{Float64}:
 0.333333  0.333327  0.333293  0.333295  0.333319  0.333375
 0.333333  0.333302  0.333221  0.333182  0.333205  0.333184
 0.333333  0.333371  0.333486  0.333524  0.333475  0.333441
```

You can analyse the algorithm's performance using several metrics that have been provided in this package. Check out the [Performance evaluation](@ref) section for more details.

## References

```@bibliography
Pages = [@__FILE__]
Canonical = false
```