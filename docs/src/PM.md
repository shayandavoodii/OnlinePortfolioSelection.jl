# Pattern-matching algorithms

Pattern-matching algorithms stand among the most popular strategies in the domain of online portfolio selection. These algorithms primarily aim to discern patterns within historical price data and employ them for predicting future prices. They align with the perspective of technical analysts who anticipate the repetition of historical patterns in future market behavior. The current package incorporates the following pattern-matching algorithms:

- Correlation-driven Nonparametric Learning (CORN)
  - [CORN-U](@ref "Run CORN-U")
  - [CORN-K](@ref "Run CORN-K")
- Dynamic RIsk CORrelation-driven Non-parametric (DRICORN-K)
- Bᴷ
- ClusLog
  - KMNLOG
  - KMDLOG

## Correlation-driven Nonparametric Learning

Correlation-driven Nonparametric Learning (CORN) is a pattern-matching algorithm introduced by [10.1145/1961189.1961193](@citet). CORN employs correlation as the measure of similarity between different time windows. Within CORN, multiple experts are defined to generate portfolios. Each trading day involves a combination of expert portfolios to create the final portfolio. The distinction between CORN-K and CORN-U lies in their portfolio construction methods. CORN-K selects the K best experts, determined by their historical performance, to create the final portfolio. Conversely, CORN-U amalgamates all experts uniformly to construct the final portfolio. For further details, refer to [`cornu`](@ref) and [`cornk`](@ref).

### Run CORN-U

The key parameters for CORN-U include `w` (maximum window size to be examined) and `rho` (correlation threshold). Larger values of `w` involve examining more window sizes, leading to enhanced accuracy but increased algorithm runtime. However, the same relationship does not hold for `rho`. Extreme values for `rho` (e.g., 0.99 or 0.01) are advised against by the authors. As CORN is intended to identify time windows with positive directional correlation, negative values for `rho` are not permissible. From the authors' experiments, an optimal `rho` value was found to be 0.2, and this has been set as the default value.

CORN algorithms, including CORN-U, exhibit improved performance when trained on longer time periods (e.g., ~1 year) for portfolio selection.

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

The result indicates that the algorithm experienced a loss of 1.5% of the initial wealth during the investment period. Further analysis of the algorithm's performance can be conducted using the [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref) functions. For more detailed information, refer to the [Performance evaluation](@ref) section.

### Run CORN-K

The key parameters of CORN-K include `k` (number of best experts used for portfolio construction), `w` (maximum window size to be examined), and `rho` (number of correlation coefficient thresholds to be examined). CORN-K utilizes the best experts to formulate the final portfolio, aiming to outperform CORN-U. To observe its performance, let's execute CORN-K on the same dataset as used for CORN-U:

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

Expectedly, CORN-K performed better than CORN-U on the same dataset. The result indicates that the algorithm has gained ~0.18% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref) functions. See [Performance evaluation](@ref) section for more information.

## Dynamic RIsk CORrelation-driven Non-parametric

Dynamic Risk CORrelation-driven Non-parametric (DRICORN)[10.1007/978-3-030-66151-9_12](@cite) employs a similar principle to CORN-K. However, DRICORN incorporates the beta of the portfolio as a risk measure in the portfolio optimization. Additionally, it considers the recent market trend to capitalize on positive risks while minimizing exposure to negative risks. For further details, refer to [`dricornk`](@ref).

### Run DRICORN-K

Given that this algorithm is constructed on the CORN-K model, it shares analogous parameters. However, DRICORN-K requires market index data (e.g., S&P 500) to calculate the portfolio's beta and the market trend. Additionally, a coefficient is used to regulate the portfolio's beta, with the default value set to `1e-3`. Let's execute DRICORN-K using the same data as CORN-U and CORN-K.

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

## Bᴷ

Bᴷ, presented as a type of kernel-based investment strategy, is a pattern-matching algorithm introduced by [https://doi.org/10.1111/j.1467-9965.2006.00274.x](@citet). In essence, Bᴷ shares similarities with histogram-based strategies, albeit utilizing more flexible elementary strategies that replace rigid past market vector discretization with a "moving-window" rule. This implementation incorporates the uniform kernel function. Check [`bk`](@ref) for more information.

### Run Bᴷ

The most important parameter of Bᴷ is `k` (number of best experts to be used for portfolio construction). Let's run Bᴷ on the same data as CORN-U, CORN-K, etc.:

```julia
julia> using OnlinePortfolioSelection

julia> horizon, k, n_splits, similarity_thresh = 5, 5, 10, 0.2;

julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

# run the algorithm on the last 5 days
julia> model = bk(rel_price[:, end-horizon+1:end], k, n_splits, similarity_thresh);

julia> model.b
5×5 Matrix{Float64}:
 0.2  0.2  0.196078  0.156876  0.153047
 0.2  0.2  0.196078  0.156876  0.250758
 0.2  0.2  0.215685  0.156876  0.172675
 0.2  0.2  0.196078  0.156876  0.153047
 0.2  0.2  0.196079  0.372496  0.270474
```

Using [`sn`](@ref) function, one can compute the cumulative wealth during the investment period:

```julia
julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> sn(model.b, rel_price)
6-element Vector{Float64}:
 1.0
 0.987982263196868
 0.9854808683947185
 0.9870411234122491
 0.9763511652573162
 0.9698166561732083
```

The result indicates that the algorithm has lost ~3% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref) functions. See [Performance evaluation](@ref) section for more information.

## ClusLog

ClusLog contains some variant of models proposed by [KHEDMATI2020113546](@citet), namely, KMNLOG and KMDLOG. The main idea behind these algorithms is to cluster the historical time windows based on their inter-correlation. Then, the algorithm uses a day after the found time windows as the potential day to occur with the same pattern for tomorrow. In order to perform the portfolio selection, the algorithm uses the semi-log optimal approach in order to maximize the expected return of the portfolio. See [`cluslog`](@ref).

### Run ClusLog

In order to use this function, you have to install the [`Clustering.jl`](https://github.com/JuliaStats/Clustering.jl) package and import it on your own. The reason behind this design is that I do not intend to add extra dependencies to this package for the sake of just an algorithm. The `Clustering.jl` package can be installed by running the following command in the Julia REPL:

```julia
julia> using Pkg

julia> pkg"add Clustering@0.15.2"

# Or

julia> pkg.add(name="Clustering", version="0.15.2")
```

After intalling the package, you can use the [`cluslog`](@ref) function after importing the `Clustering.jl` package. Let's run ClusLog on the same data as CORN-U, CORN-K, etc.:

```julia
julia> using OnlinePortfolioSelection, Clustering

julia> horizon, max_window_size, clustering_model, max_n_clusters, max_n_clustering, optm_boundries = 2, 3, KMNLOG, 3, 7, (0.0, 1.0);

julia> prices = prices |> permutedims;

julia> rel_price = prices[:, 2:end] ./ prices[:, 1:end-1];

# run the algorithm on the last 2 days
julia> model = cluslog(rel_price, horizon, max_window_size, clustering_model, max_n_clusters, max_n_clustering, optm_boundries);
[ Info: Analysis for trading day 1 is done.
[ Info: Analysis for trading day 2 is done.

julia> model.b
5×2 Matrix{Float64}:
 0.963883    0.00479629
 0.00337321  0.973796
 0.00657932  0.00360691
 0.00183594  0.00164263
 0.0243289   0.0161582
```

Using [`sn`](@ref) function, one can compute the cumulative wealth during the investment period:

```julia
julia> sn(model.b, rel_price)
3-element Vector{Float64}:
 1.0
 0.9932798769652941
 0.9817775041346212
```

The result indicates that the algorithm has lost ~1.8% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`ann_std`](@ref), [`apy`](@ref), [`ann_sharpe`](@ref), [`mdd`](@ref), and [`calmar`](@ref) functions. See [Performance evaluation](@ref) section for more information.

## References

```@bibliography
Pages = [@__FILE__]
Canonical = false
```