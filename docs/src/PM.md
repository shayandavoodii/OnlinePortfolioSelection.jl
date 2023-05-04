# Pattern-matching algorithms

Pattern-matching algorithms are one of most popular algorithms in the context of online portfolio selection. The main idea behind these algorithms is to find a pattern in the past price data and use it to predict the future price. These strategies are in consensus with technical analysts perspective. Technical analysts believe that the historical patterns in the price data will repeat in the future. The following pattern-matching algorithms are implemented in this package so far:
1. Correlation-driven Nonparametric Learning
1.1. CORN-U  
1.2. CORN-K
2. Dynamic RIsk CORrelation-driven Non-parametric

## Correlation-driven Nonparametric Learning
Correlation-driven Nonparametric Learning (CORN) is a pattern-matching algorithm proposed by [Borodin et al. (2010)](https://doi.org/10.1145/1961189.1961193). CORN utilizes the correlation as the similarity measure between time windows. Additionally, CORN defines several experts to construct portfolios. For each trading day, CORN combines the portfolios of the experts to construct the final portfolio. This is where CORN-K and CORN-U differ. CORN-K uses K best experts (based on their performance on historical data) to construct the final portfolio. On the other hand, CORN-U uses all the experts and uniformly combines their portfolios to construct the final portfolio.
See [`cornu`](@ref) and [`cornk`](@ref). 

### Run CORN-U
The most important parameters of CORN-U are `w` (maximum window size to be examined) and `rho` (correlation threshold). The higher the `w` is, the more window sizes are examined; consequently, the more time it takes to run the algorithm. However, the algorithm performs more accurately. The former is not true for `rho`. The authors have recommended to avoid extreme values for `rho` (e.g., 0.99 or 0.01). Since CORN aims to find time windows positive directional correlation, the negative values of `rho` are not allowed. Authors have found that the best values for `rho` in their experiments are 0.2. As a result, the default value for `rho` is set to 0.2.

Since CORN family algorithms perform better when they are trained on a long period of time, we use the data of a longer period of time (e.g., ~1 year) to train the algorithm. Then, we use the data of a shorter period of time (e.g., last 10 days) to perform the portfolio selection.

```julia
juila> using OnlinePortfolioSelection

julia> size(prices)
(268, 5)

# OnlinePortfolioSelection suppose that the data is in the form of a matrix
# where each row is the price vector of the assets at a specific time period.
julia> prices = prices |> permutedims;

# run the algorithm on the last 5 days
julia> horizon, w = 5, 10

julia> model = cornu(prices, horizon, w)

julia> model.b
5×5 Matrix{Float64}:
 0.0       0.198536  0.0995612  0.0        0.0
 0.0       0.389272  0.0        0.0        0.0980504
 0.0       0.0       0.430479   0.0998267  0.0
 0.714743  0.0       0.0        0.0        0.203183
 0.285257  0.412192  0.46996    0.900173   0.698766
```

One can compute the cumulative wealth during the investment period by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(model.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9910701218600744
 0.9956345799968089
 1.0038929232387375
 0.9914403615208097
 0.9851289224781754
```

The result indicates that the algorithm has lost 1.5% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref) functions. See [Performance evaluation](@ref) section for more information.

### Run CORN-K
The most important parameters of CORN-K are `k` (number of best experts to be used for portfolio construction), `w` (maximum window size to be examined), and `rho` (number of correlation coefficient thresholds to be examined). Since CORN-K uses the best experts to construct the final portfolio, it is supposed to perform better than CORN-U. Let's run CORN-K on the same data as CORN-U:

```julia
# run the algorithm on the last 5 days
julia> horizon, k, w, rho = 5, 10, 5, 5, 5;

julia> model = cornk(prices, horizon, k, w, rho);

julia> model.b
```

Last but not least, the cumulative return of the algorithm on the investment period and given dataset can be computed by using the [`sn`](@ref) function:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(model.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9920219584145965
 0.997769753240107
 1.0153550964116513
 1.004610801506029
 1.0017637293758395
```

As mentioned earlier, CORN-K performed better than CORN-U on the same dataset. The result indicates that the algorithm has gained ~0.18% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref) functions. See [Performance evaluation](@ref) section for more information.

## Dynamic RIsk CORrelation-driven Non-parametric
[Dynamic RIsk CORrelation-driven Non-parametric (DRICORN)](https://www.doi.org/10.1007/978-3-030-66151-9_12) follows the same idea as CORN-K. However, DRICORN considers the beta of portfolio as a measure of risk in the portfolio optimization. Furthermore, they consider the recent trend of market in order to take advantage of positive risks, and avoid negative risks.
See [`dricornk`](@ref).

### Run DRICORN-K
Since this algorithm is built on top of CORN-K, it shares the similar parameters with CORN-K. Nevertheless, DRICORN-K needs the data of the market index (e.g., S&P 500) in order to compute the beta of the portfolio, and the trend of the market. It is worth mentioning that the algorithm also takes a coefficient in order to regularize the beta of the portfolio. The default value for this coefficient is `1e-3`. Let's run DRICORN-K on the same data as CORN-U and CORN-K:

```julia
# run the algorithm on the last 5 days
julia> horizon, k, w, rho = 5, 10, 5, 5, 5;

julia> model = dricornk(prices, market_prices, horizon, k, w, rho);

julia> model.b
4×5 Matrix{Float64}:
 0.0  0.25  0.25  0.25  0.17438
 0.0  0.25  0.25  0.25  0.17438
 0.0  0.25  0.25  0.25  0.174281
 1.0  0.25  0.25  0.25  0.476959
```

Using [`sn`](@ref) function, one can compute the cumulative wealth during the investment period:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(model.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.9906902403938972
 0.9867624995658737
 0.9841621752990845
 0.9754797369845584
 0.9738144349688777
```

The result indicates that the algorithm has lost ~2.6% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref) functions. See [Performance evaluation](@ref) section for more information.