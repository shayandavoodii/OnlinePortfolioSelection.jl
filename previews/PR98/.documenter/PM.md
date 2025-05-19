
# Pattern-Matching (PM) {#Pattern-Matching-PM}

Pattern-matching algorithms stand among the most popular strategies in the domain of online portfolio selection. These algorithms primarily aim to discern patterns within historical price data and employ them for predicting future prices. They align with the perspective of technical analysts who anticipate the repetition of historical patterns in future market behavior. The current package incorporates the following pattern-matching algorithms:
1. [Correlation-driven Nonparametric Learning (CORN)](/PM#Correlation-driven-Nonparametric-Learning-(CORN))
  
2. [Dynamic RIsk CORrelation-driven Non-parametric (DRICORN)](/PM#Dynamic-RIsk-CORrelation-driven-Non-parametric-(DRICORN))
  
3. [Bᴷ](/PM#Bᴷ)
  
4. [ClusLog](/PM#ClusLog)
  
5. [Online Low Dimension Ensemble Method (OLDEM)](/PM#Online-Low-Dimension-Ensemble-Method-(OLDEM))
  
6. [Kernel-based Trend Pattern Tracking (KTPT)](/PM#Kernel-based-Trend-Pattern-Tracking-(KTPT))
  

## Correlation-driven Nonparametric Learning (CORN) {#Correlation-driven-Nonparametric-Learning-CORN}

Correlation-driven Nonparametric Learning (CORN) is a pattern-matching algorithm introduced by [Li _et al._ [21]](/refs#10.1145/1961189.1961193). CORN employs correlation as the measure of similarity between different time windows. Within CORN, multiple experts are defined to generate portfolios. Each trading day involves a combination of expert portfolios to create the final portfolio. The distinction between CORN-K and CORN-U lies in their portfolio construction methods. CORN-K selects the K best experts, determined by their historical performance, to create the final portfolio. Conversely, CORN-U amalgamates all experts uniformly to construct the final portfolio. For further details, refer to [`cornu`](/funcs#OnlinePortfolioSelection.cornu-Union{Tuple{M},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20M,%20M}}%20where%20{T<:AbstractFloat,%20M<:Integer}) and [`cornk`](/funcs#OnlinePortfolioSelection.cornk-Union{Tuple{T},%20Tuple{AbstractMatrix{<:AbstractFloat},%20Vararg{T,%204}}}%20where%20T<:Integer).

### Run CORN-U {#Run-CORN-U}

The key parameters for CORN-U include `w` (maximum window size to be examined) and `rho` (correlation threshold). Larger values of `w` involve examining more window sizes, leading to enhanced accuracy but increased algorithm runtime. However, the same relationship does not hold for `rho`. Extreme values for `rho` (e.g., 0.99 or 0.01) are advised against by the authors. As CORN is intended to identify time windows with positive directional correlation, negative values for `rho` are not permissible. From the authors&#39; experiments, an optimal `rho` value was found to be 0.2, and this has been set as the default value.

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

julia> rel_prices = prices[:, 2:end] ./ prices[:, 1:end-1]

julia> model = cornu(prices, horizon, w)
julia> model = cornu(rel_prices, horizon, w)

julia> model.b
5×5 Matrix{Float64}:
 0.759879   0.37932    0.518244   0.841716   0.538972
 0.0600301  0.0798703  0.0198005  0.0395709  0.0397726
 0.0600301  0.0798703  0.0198005  0.0395709  0.0397726
 0.0600301  0.0798703  0.0198005  0.0395709  0.0397726
 0.0600301  0.381069   0.422354   0.0395709  0.34171
```


One can compute the cumulative wealth during the investment period by using the [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function:

```julia
julia> sn(model.b, rel_prices)
6-element Vector{Float64}:
 1.0
 0.9874863981778458
 0.9867337486209383
 0.997125392069827
 0.9899191819701306
 0.9791598729100073
```


The result indicates that the algorithm experienced a loss of ~2% of the initial wealth during the investment period. Further analysis of the algorithm&#39;s performance can be conducted using the [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat) functions. For more detailed information, refer to the [Performance evaluation](/performance_eval#Performance-evaluation) section.

### Run CORN-K {#Run-CORN-K}

The key parameters of CORN-K include `k` (number of best experts used for portfolio construction), `w` (maximum window size to be examined), and `rho` (number of correlation coefficient thresholds to be examined). CORN-K utilizes the best experts to formulate the final portfolio, aiming to outperform CORN-U. To observe its performance, let&#39;s execute CORN-K on the same dataset as used for CORN-U:

```julia
# run the algorithm on the last 5 days
julia> horizon, k, w, rho = 5, 10, 5, 5, 5;

julia> model = cornk(rel_prices, horizon, k, w, rho);

julia> model.b
5×5 Matrix{Float64}:
 0.679862   0.279356   0.681348   0.581841   0.678181
 0.0800344  0.0798487  0.0796631  0.0795637  0.079953
 0.0800344  0.0798487  0.0796631  0.0795637  0.079953
 0.0800344  0.0798487  0.0796631  0.0795637  0.079953
 0.0800344  0.481098   0.0796631  0.179468   0.0819602
```


Last but not least, the cumulative wealth of the algorithm on the investment period and given dataset can be computed by using the [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function:

```julia
julia> sn(model.b, rel_prices)
6-element Vector{Float64}:
 1.0
 0.9875572675972655
 0.9873565694624061
 0.9913102075729211
 0.9827281883555271
 0.9722491752324016
```


Expectedly, CORN-K performed better than CORN-U on the same dataset. The result indicates that the algorithm has lost ~3.1% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat) functions. See [Performance evaluation](/performance_eval#Performance-evaluation) section for more information.

## Dynamic RIsk CORrelation-driven Non-parametric (DRICORN) {#Dynamic-RIsk-CORrelation-driven-Non-parametric-DRICORN}

Dynamic Risk CORrelation-driven Non-parametric (DRICORN)[[22](/refs#10.1007/978-3-030-66151-9_12)] employs a similar principle to CORN-K. However, DRICORN incorporates the beta of the portfolio as a risk measure in the portfolio optimization. Additionally, it considers the recent market trend to capitalize on positive risks while minimizing exposure to negative risks. For further details, refer to [`dricornk`](/funcs#OnlinePortfolioSelection.dricornk-Union{Tuple{M},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractVector{T},%20Vararg{M,%204}}}%20where%20{T<:AbstractFloat,%20M<:Integer}).

### Run DRICORN-K {#Run-DRICORN-K}

Given that this algorithm is constructed on the CORN-K model, it shares analogous parameters. However, DRICORN-K requires market index data (e.g., S&amp;P 500) to calculate the portfolio&#39;s beta and the market trend. Additionally, a coefficient is used to regulate the portfolio&#39;s beta, with the default value set to `1e-3`. Let&#39;s execute DRICORN-K using the same data as CORN-U and CORN-K.

```julia
# run the algorithm on the last 4 days
julia> horizon, k, w, rho = 4, 10, 5, 5, 5;

julia> rel_price = rand(4, 28);

julia> market_prices = rand(28);

julia> model = dricornk(rel_price, market_prices, horizon, k, w, rho);

julia> model.b
4×4 Matrix{Float64}:
 0.221173   0.529528   0.424046  0.389769
 0.597183   0.0863265  0.334074  0.349607
 0.1052     0.0        0.0       0.0
 0.0764436  0.384145   0.24188   0.260624
```


Using [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function, one can compute the cumulative wealth during the investment period. Further analysis of the algorithm can be done by using the [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat) functions. See [Performance evaluation](/performance_eval#Performance-evaluation) section for more information.

## Bᴷ {#Bᴷ}

Bᴷ, presented as a type of kernel-based investment strategy, is a pattern-matching algorithm introduced by [Györfi _et al._ [23]](/refs#10.1111/j.1467-9965.2006.00274.x). In essence, Bᴷ shares similarities with histogram-based strategies, albeit utilizing more flexible elementary strategies that replace rigid past market vector discretization with a &quot;moving-window&quot; rule. This implementation incorporates the uniform kernel function. Check [`bk`](/funcs#OnlinePortfolioSelection.bk-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20S,%20S,%20T}}%20where%20{T<:AbstractFloat,%20S<:Integer}) for more information.

### Run Bᴷ {#Run-Bᴷ}

The most important parameter of Bᴷ is `k` (number of best experts to be used for portfolio construction). Let&#39;s run Bᴷ on the same data as CORN-U, CORN-K, etc.:

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


Using [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function, one can compute the cumulative wealth during the investment period:

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


The result indicates that the algorithm has lost ~3% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat) functions. See [Performance evaluation](/performance_eval#Performance-evaluation) section for more information.

## ClusLog {#ClusLog}

ClusLog contains some variant of models proposed by [Khedmati and Azin [24]](/refs#KHEDMATI2020113546), namely, KMNLOG and KMDLOG. The main idea behind these algorithms is to cluster the historical time windows based on their inter-correlation. Then, the algorithm uses a day after the found time windows as the potential day to occur with the same pattern for tomorrow. In order to perform the portfolio selection, the algorithm uses the semi-log optimal approach in order to maximize the expected return of the portfolio. See [`cluslog`](/funcs#OnlinePortfolioSelection.cluslog).

### Run ClusLog {#Run-ClusLog}

::: tip Note

In order to use this function, you have to install the [`Clustering.jl`](https://github.com/JuliaStats/Clustering.jl) package and import it on your own. The reason behind this design is that I do not intend to add extra dependencies to this package for the sake of just an algorithm. The `Clustering.jl` package can be installed by running the following command in the Julia REPL:

```julia
julia> using Pkg

julia> pkg"add Clustering@0.15.2"

# Or

julia> pkg.add(name="Clustering", version="0.15.2")
```


After intalling the package, you can use the [`cluslog`](/funcs#OnlinePortfolioSelection.cluslog) function after importing the `Clustering.jl` package.

:::

Let&#39;s run ClusLog on the same data as CORN-U, CORN-K, etc.:

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


Using [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function, one can compute the cumulative wealth during the investment period:

```julia
julia> sn(model.b, rel_price)
3-element Vector{Float64}:
 1.0
 0.9932798769652941
 0.9817775041346212
```


The result indicates that the algorithm has lost ~1.8% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat) functions. See [Performance evaluation](/performance_eval#Performance-evaluation) section for more information.

## Online Low Dimension Ensemble Method (OLDEM) {#Online-Low-Dimension-Ensemble-Method-OLDEM}

[Xi _et al._ [25]](/refs#XI2023109872) proposed a method called OLDEM, which stands for online low-dimension ensemble method. It is a novel online portfolio selection strategy that aims to maximize the cumulative wealth by predicting the future prices and risks of a group of assets. The novelties of this method are:
- High-dimensional learning framework: The method treats the financial market as a complex high-dimensional dynamical system (HDS) and randomly generates a large number of low-dimensional subsystems (LDS) from it. These LDSs capture the correlation and dynamical information of the market from different perspectives and are used to predict the future prices of each asset. The final prediction is obtained by aggregating the predictions from the LDSs using ensemble learning techniques.
  
- Predictive instantaneous risk assessment: The method also develops a novel high-dimensional covariance matrix estimation/prediction method for short-term data, which can assess the instantaneous risk structure and uncertainty of the projected portfolio returns. This allows the method to introduce a risk term into the portfolio optimization problem, which is usually missing or inappropriate in existing methods.
  
- Improved optimization setting: The method formulates a more appropriate optimization problem for online portfolio selection, which considers the predictive instantaneous risk and the self-financing constraint. The method employs online learning algorithms to solve the optimization problem and update the portfolio at each time slot. See [`oldem`](/funcs#OnlinePortfolioSelection.oldem-Union{Tuple{T},%20Tuple{S},%20Tuple{AbstractMatrix,%20S,%20S,%20S,%20S,%20T,%20T,%20T}}%20where%20{S<:Integer,%20T<:AbstractFloat}).
  

### Run OLDEM {#Run-OLDEM}

Let&#39;s run OLDEM on the real market data:

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["MSFT", "TSLA", "AAPL", "META", "MMM"];

julia> querry = [
         get_prices(ticker, startdt="2020-01-01", enddt="2020-01-15")["adjclose"]
         for ticker in tickers
       ];

julia> prices = stack(querry) |> permutedims;

julia> x = prices[:, 2:end]./prices[:, 1:end-1]
5×8 Matrix{Float64}:
 0.987548  1.00259  0.990882  1.01593  1.01249   0.995373  1.01202  0.992957
 1.02963   1.01925  1.0388    1.0492   0.978055  0.993373  1.09769  1.02488
 0.990278  1.00797  0.995297  1.01609  1.02124   1.00226   1.02136  0.986497
 0.994709  1.01883  1.00216   1.01014  1.01431   0.998901  1.01766  0.987157
 0.991389  1.00095  0.995969  1.01535  1.00316   0.995971  1.00249  1.00249
 
julia> σ = 0.025;
julia> w = 2;
julia> h = 4;
julia> L = 4;
julia> s = 3;

julia> model = oldem(x, h, w, L, s, σ, 0.002, 0.25);

julia> model.b
5×4 Matrix{Float64}:
 0.2  1.99964e-8  1.0         0.0
 0.2  1.0         0.0         0.0
 0.2  0.0         0.0         1.99964e-8
 0.2  0.0         0.0         1.0
 0.2  0.0         1.99964e-8  0.0
```


Keep in mind that since this algorithm randomly select the low-dimensional subsystems, the result may vary from run to run. Using [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat) function, one can compute the cumulative wealth during the investment period:

```julia
julia> sn(model.b, x)
5-element Vector{Float64}:
 1.0
 1.005851012021382
 0.9991849380303157
 1.0016764248621135
 0.9881506219530738
```


The result indicates that the algorithm has lost ~1.2% of the initial wealth during the investment period. Further analysis of the algorithm can be done by using the [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat) functions. See [Performance evaluation](/performance_eval#Performance-evaluation) section for more information.

## Kernel-based Trend Pattern Tracking (KTPT) {#Kernel-based-Trend-Pattern-Tracking-KTPT}

[Lai _et al._ [26]](/refs#Lai2018) introduced an innovative kernel-based trend tracking (KTPT) system designed for OPS. This system employs a three-phase price forecasting model that identifies both trend-following and trend-reversing patterns in asset prices to aid in predicting future movements. Additionally, KTPT features a unique kernel-driven tracking mechanism that optimizes the portfolio by effectively capturing potential asset price growth. Unlike earlier kernels that estimate the likelihood of a price relative, this kernel evaluates the alignment between the current portfolio and predicted price to modulate each asset&#39;s influence during the optimization process.

::: tip Note

In order to use this algorithm, you have to install [`Lasso.jl`](https://github.com/JuliaStats/Lasso.jl) package. After a successful installation and importing, you can use this algorithm:

```julia
julia> using Pkg; Pkg.add("Lasso")
julia> using OnlinePortfolioSelection, Lasso
```


:::

### Run KTPT {#Run-KTPT}

Let&#39;s run [`ktpt`](/funcs#OnlinePortfolioSelection.ktpt) on the real market data:

```julia
julia> using OnlinePortfolioSelection, YFinance, Lasso

julia> tickers = ["GOOG", "AAPL", "MSFT", "AMZN"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-31")["adjclose"] for ticker=tickers];

julia> prices = stack(querry, dims=1);

julia> h, w, q, eta, v, phat_t, bhat_t = 5, 5, 6, 1000, 0.5, rand(length(tickers)), nothing

julia> model = ktpt(prices, h, w, q, eta, v, phat_t, bhat_t);

julia> model.b
4×5 Matrix{Float64}:
 0.25  0.0  1.0  1.0  1.0
 0.25  0.0  0.0  0.0  0.0
 0.25  1.0  0.0  0.0  0.0
 0.25  0.0  0.0  0.0  0.0

julia> x = prices[:, 2:end]./prices[:, 1:end-1];

julia> sn(model.b, x)
6-element Vector{Float64}:
 1.0
 0.9903640322766385
 0.9682097787851796
 0.9808095798904469
 0.984908122467024
 0.9830242099475751
```


You can analyse the algorithm&#39;s performance using several metrics that have been provided in this package. Check out the [Performance evaluation](/performance_eval#Performance-evaluation) section for more details.

## References {#References}
1. B. Li, S. C. Hoi and V. Gopalkrishnan. _CORN: Correlation-Driven Nonparametric Learning Approach for Portfolio Selection_. [ACM Trans. Intell. Syst. Technol. **2**](https://doi.org/10.1145/1961189.1961193) (2011).
  
2. S. Sooklal, T. L. van Zyl and A. Paskaramoorthy. [_DRICORN-K: A Dynamic RIsk CORrelation-driven Non-parametric Algorithm for Online Portfolio Selection_](https://doi.org/10.1007/978-3-030-66151-9_12). In: _Artificial Intelligence Research_, edited by A. Gerber (Springer International Publishing, Cham, 2020); pp. 183–196.
  
3. L. Györfi, G. Lugosi and F. Udina. _NONPARAMETRIC KERNEL-BASED SEQUENTIAL INVESTMENT STRATEGIES_. [Mathematical Finance **16**, 337–357](https://doi.org/10.1111/j.1467-9965.2006.00274.x) (2006).
  
4. M. Khedmati and P. Azin. _An online portfolio selection algorithm using clustering approaches and considering transaction costs_. [Expert Systems with Applications **159**, 113546](https://doi.org/10.1016/j.eswa.2020.113546) (2020).
  
5. W. Xi, Z. Li, X. Song and H. Ning. _Online portfolio selection with predictive instantaneous risk assessment_. [Pattern Recognition **144**, 109872](https://doi.org/10.1016/j.patcog.2023.109872) (2023).
  
6. Z.-R. Lai, P.-Y. Yang, X. Wu and L. Fang. [_A kernel-based trend pattern tracking system for portfolio optimization_](http://dx.doi.org/10.1007/s10618-018-0579-5). [Data Mining and Knowledge Discovery **32**, 1708–1734](https://doi.org/10.1007/s10618-018-0579-5) (2018).
  
