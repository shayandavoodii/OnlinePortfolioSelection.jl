
# Functions {#Functions}
<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.aictr-Tuple{AbstractMatrix, Integer, Integer, Integer, AbstractVector, AbstractVector{<:OnlinePortfolioSelection.TrendRep}}' href='#OnlinePortfolioSelection.aictr-Tuple{AbstractMatrix, Integer, Integer, Integer, AbstractVector, AbstractVector{<:OnlinePortfolioSelection.TrendRep}}'><span class="jlbinding">OnlinePortfolioSelection.aictr</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
aictr(
  prices::AbstractMatrix,
  horizon::Integer,
  w::Integer,
  ϵ::Integer,
  σ::AbstractVector,
  trend_model::AbstractVector{<:TrendRep};
  bt::AbstractVector = ones(size(prices, 1))/size(prices, 1)
)
```


Run the Adaptive Input and Composite Trend Representation (AICTR) algorithm.

**Arguments**
- `prices::AbstractMatrix`: Matrix of prices.
  
- `horizon::Integer`: Number investing days.
  
- `w::Integer`: Window size.
  
- `ϵ::Integer`: Update strength.
  
- `σ::AbstractVector`: Vector of size `L` that contains the standard deviation of each trend representation.
  
- `trend_model::AbstractVector{<:TrendRep}`: Vector of trend representations. [`SMAP`](/types#OnlinePortfolioSelection.SMAP), [`EMA`](/types#OnlinePortfolioSelection.EMA), and [`PP`](/types#OnlinePortfolioSelection.PP) are supported.
  

**Keyword Arguments**
- `bt::AbstractVector`: Initial portfolio vector of size `n_assets`.
  

::: warning Beware

`prices` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG", "AMZN", "META", "TSLA", "BRK-A", "NVDA", "JPM", "JNJ"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2019-12-31")["adjclose"] for ticker ∈ tickers];

julia> prices = stack(querry) |> permutedims;

julia> horizon = 5;

julia> w = 3;

julia> ϵ = 500;

julia> σ = [0.5, 0.5];

julia> models = [SMAP(), EMA(0.5)];

julia> bt = [0.3, 0.3, 0.4];

julia> model = aictr(prices, horizon, w, ϵ, σ, models)

julia> model.b
10×5 Matrix{Float64}:
 0.1  0.0         0.0         0.0         0.0
 0.1  0.0         0.0         0.0         0.0
 0.1  1.0         6.92439e-8  0.0         0.0
 0.1  0.0         0.0         0.0         0.0
 0.1  0.0         1.0         0.0         0.0
 0.1  0.0         0.0         0.0         0.0
 0.1  6.92278e-8  0.0         0.0         0.0
 0.1  0.0         0.0         6.95036e-8  1.0
 0.1  0.0         0.0         0.0         0.0
 0.1  0.0         0.0         1.0         6.95537e-8
```


**References**
> 
> [Radial Basis Functions With Adaptive Input and Composite Trend Representation for Portfolio Selection](https://www.doi.org/10.1109/TNNLS.2018.2827952)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/AICTR.jl#L322-L392" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T}, Tuple{T, T, T}} where T<:AbstractFloat' href='#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T}, Tuple{T, T, T}} where T<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.ann_sharpe</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
ann_sharpe(APY::T, Rf::T, sigma_prtf::T) where T<:AbstractFloat
```


Calculate the Annualized Sharpe Ratio of investment. Also, see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`opsmetrics`](/funcs#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20AbstractVector{T}}}%20where%20{T<:AbstractFloat,%20S<:Int64}).

**Arguments**
- `APY::T`: the APY of investment.
  
- `Rf::T`: the risk-free rate of return.
  
- `sigma_prtf::T`: the standard deviation of the portfolio $\sigma_p$.
  

**Returns**
- `::AbstractFloat`: the Annualized Sharpe Ratio of investment.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L234-L246" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}' href='#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}'><span class="jlbinding">OnlinePortfolioSelection.ann_std</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
ann_std(cum_ret::AbstractVector{AbstractFloat}; dpy)
```


Calculate the Annualized Standard Deviation ($\sigma_p$) of portfolio. Also, see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`opsmetrics`](/funcs#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20AbstractVector{T}}}%20where%20{T<:AbstractFloat,%20S<:Int64}).

**Arguments**
- `cum_ret::AbstractVector{AbstractFloat}`: the cumulative wealth of investment during the investment period.
  

**Keyword Arguments**
- `dpy`: the number of days in a year.
  

**Returns**
- `::AbstractFloat`: the Annualized Standard Deviation ($\sigma_p$) of portfolio.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L194-L207" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.anticor-Union{Tuple{T}, Tuple{Matrix{T}, Int64}} where T<:Real' href='#OnlinePortfolioSelection.anticor-Union{Tuple{T}, Tuple{Matrix{T}, Int64}} where T<:Real'><span class="jlbinding">OnlinePortfolioSelection.anticor</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
anticor(adj_close::Matrix{T}, window::Int) where {T<:Real}
```


Run the Anticor algorithm on `adj_close` with window sizes `window`.

::: warning Beware!

`adj_close` should be a matrix of size `n_assets` × `n_periods`.

:::

**Arguments**
- `adj_close::Matrix{T}`: matrix of adjusted close prices
  
- `window::Int`: size of the window
  

**Returns**
- `::OPSAlgorithm(n_assets, b, alg)`: An OPSAlgorithm object.
  

**Example**

```julia
julia> using OnlinePortfolioSelection

julia> adj_close = [
       1. 2.
       4. 9.
       7. 8.
       10. 11.
       13. 7.
       8. 17.
       19. 20.
       22. 23.
       25. 8.
       2. 12.
       5. 12.
       5. 0.
       0. 2.
       1. 1.
       ];

julia> adj_close = permutedims(adj_close);

julia> m_anticor = anticor(adj_close, 3);

julia> m_anticor.b
2×14 Matrix{Float64}:
 0.5  0.5  0.5  0.5  …  0.0  0.0  0.0  1.0
 0.5  0.5  0.5  0.5     1.0  1.0  1.0  0.0

julia> sum(m_anticor.b, dims=1) .|> isapprox(1., atol=1e-8) |> all
true
```


**References**
> 
> [Can We Learn to Beat the Best Stock](https://www.doi.org/10.1613/jair.1336)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/Anticor.jl#L1-L52" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.apy-Union{Tuple{S}, Tuple{AbstractFloat, S}} where S<:Int64' href='#OnlinePortfolioSelection.apy-Union{Tuple{S}, Tuple{AbstractFloat, S}} where S<:Int64'><span class="jlbinding">OnlinePortfolioSelection.apy</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
apy(Sn::AbstractFloat, n_periods::S; dpy::S=252) where S<:Int
```


Calculate the Annual Percentage Yield (APY) of investment. Also, see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`opsmetrics`](/funcs#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20AbstractVector{T}}}%20where%20{T<:AbstractFloat,%20S<:Int64}).

**Arguments**
- `Sn::AbstractFloat`: the cumulative wealth of investment.
  
- `n_periods::S`: the number investment periods.
  
- `dpy::S=252`: the number of days in a year.
  

**Returns**
- `::AbstractFloat`: the APY of investment.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L215-L227" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.at-Tuple{AbstractMatrix, AbstractMatrix}' href='#OnlinePortfolioSelection.at-Tuple{AbstractMatrix, AbstractMatrix}'><span class="jlbinding">OnlinePortfolioSelection.at</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
at(rel_pr::AbstractMatrix, b::AbstractMatrix)
```


Calculate the average turnover of the portfolio. Also, see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat), and [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat).

**Arguments**
- `rel_pr::AbstractMatrix`: The relative price of the stocks.
  
- `b::AbstractMatrix`: The weights of the portfolio.
  

**Returns**
- `::AbstractFloat`: the average turnover of the portfolio.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L287-L298" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.bcrp-Union{Tuple{AbstractMatrix{T}}, Tuple{T}} where T<:AbstractFloat' href='#OnlinePortfolioSelection.bcrp-Union{Tuple{AbstractMatrix{T}}, Tuple{T}} where T<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.bcrp</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
bcrp(rel_pr::AbstractMatrix{T}) where T<:AbstractFloat
```


Run Best Constant Rebalanced Portfolio (BCRP) algorithm.

**Arguments**
- `rel_pr::AbstractMatrix{T}`: Relative price matrix.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object
  

**Example**

```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(3, 8);

julia> m_bcrp = bcrp(rel_pr);

julia> m_bcrp.b
3×8 Matrix{Float64}:
 8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9  8.58038e-9
 1.0         1.0         1.0         1.0         1.0         1.0         1.0         1.0
 0.0         0.0         0.0         0.0         0.0         0.0         0.0         0.0

julia> sum(m_bcrp.b, dims=1) .|> isapprox(1.) |> all
true
```


**References**
> 
> [Universal Portfolios](https://onlinelibrary.wiley.com/doi/10.1111/j.1467-9965.1991.tb00002.x)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/BCRP.jl#L1-L35" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.bk-Union{Tuple{S}, Tuple{T}, Tuple{AbstractMatrix{T}, S, S, T}} where {T<:AbstractFloat, S<:Integer}' href='#OnlinePortfolioSelection.bk-Union{Tuple{S}, Tuple{T}, Tuple{AbstractMatrix{T}, S, S, T}} where {T<:AbstractFloat, S<:Integer}'><span class="jlbinding">OnlinePortfolioSelection.bk</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
bk(rel_price::AbstractMatrix{T}, K::S, L::S, c::T) where {T<:AbstractFloat, S<:Integer}
```


Run Bᴷ algorithm.

**Arguments**
- `rel_price::AbstractMatrix{T}`: Relative prices of assets.
  
- `K::S`: Number of experts.
  
- `L::S`: Number of time windows.
  
- `c::T`: The similarity threshold.
  

::: warning Beware!

`rel_price` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Example**

```julia
julia> using OnlinePortfolioSelection

julia> daily_relative_prices = rand(3, 20);
julia> nexperts = 10;
julia> nwindows = 3;
julia> sim_thresh = 0.5;

julia> model = bk(daily_relative_prices, nexperts, nwindows, sim_thresh);

julia> model.b
3×20 Matrix{Float64}:
 0.333333  0.333333  0.354839  0.318677  …  0.333331  0.329797  0.322842  0.408401
 0.333333  0.333333  0.322581  0.362646     0.333339  0.340406  0.354317  0.295811
 0.333333  0.333333  0.322581  0.318677     0.333331  0.329797  0.322842  0.295789

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```


**Reference**
> 
> [NONPARAMETRIC KERNEL-BASED SEQUENTIAL INVESTMENT STRATEGIES](https://doi.org/10.1111/j.1467-9965.2006.00274.x)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/BK.jl#L1-L41" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.bs-Union{Tuple{Matrix{T}}, Tuple{T}} where T<:AbstractFloat' href='#OnlinePortfolioSelection.bs-Union{Tuple{Matrix{T}}, Tuple{T}} where T<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.bs</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
bs(adj_close::Matrix{T}; last_n::Int=0) where {T<:AbstractFloat}
```


Run the Best So Far algorithm on the given data.

**Arguments**
- `adj_close::Matrix{T}`: A matrix of adjusted closing prices of assets.
  

**Keyword Arguments**
- `last_n::Int`: The number of periods to look back for the performance of each asset. If `last_n` is 0, then the performance is calculated from the first period to the previous period.
  

::: warning Beware!

The `adj_close` matrix should be in the order of assets x periods.

:::

**Returns**
- `::OPSAlgorithm(n_assets, b, alg)`: An instance of `OPSAlgorithm`.
  

**Example**

```julia
julia> using OnlinePortfolioSelection

julia> adj_close = rand(5, 10);

julia> model = bs(adj_close, last_n=2);

julia> model.b
5×10 Matrix{Float64}:
 0.2  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0
 0.2  0.0  0.0  1.0  0.0  1.0  0.0  0.0  0.0  0.0
 0.2  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.2  1.0  1.0  0.0  0.0  0.0  1.0  0.0  1.0  1.0
 0.2  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```


**References**
> 
> [KERNEL-BASED SEMI-LOG-OPTIMAL EMPIRICAL PORTFOLIO SELECTION STRATEGIES](https://doi.org/10.1142/S0219024907004251)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/BS.jl#L1-L40" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.caeg-Tuple{AbstractMatrix, AbstractVector}' href='#OnlinePortfolioSelection.caeg-Tuple{AbstractMatrix, AbstractVector}'><span class="jlbinding">OnlinePortfolioSelection.caeg</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
caeg(rel_pr::AbstractMatrix, ηs::AbstractVector)
```


Run CAEG algorithm.

**Arguments**
- `rel_pr::AbstractMatrix`: Historical relative prices. The paper&#39;s authors used _&quot;the ratio of closing price to last closing price&quot;_.
  
- `ηs::AbstractVector`: Learning rates.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Examples**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> startdt, enddt = "2020-1-1", "2020-1-10";

julia> open_querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["open"] for ticker ∈ tickers];

julia> open_ = stack(open_querry) |> permutedims;

julia> close_querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker ∈ tickers];

julia> close_ = stack(close_querry) |> permutedims;

julia> rel_pr = close_./open_;

julia> learning_rates = [0.02, 0.05];

julia> model = caeg(rel_pr, learning_rates);

julia> model.b
3×6 Matrix{Float64}:
 0.333333  0.333322  0.333286  0.333271  0.333287  0.333368
 0.333333  0.333295  0.333271  0.333171  0.333123  0.333076
 0.333333  0.333383  0.333443  0.333558  0.33359   0.333557
```


**References**
> 
> [Aggregating exponential gradient expert advice for online portfolio selection](https://doi.org/10.1080/01605682.2020.1848358)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/CAEG.jl#L1-L47" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.calmar-Union{Tuple{T}, Tuple{T, T}} where T<:AbstractFloat' href='#OnlinePortfolioSelection.calmar-Union{Tuple{T}, Tuple{T, T}} where T<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.calmar</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
calmar(APY::T, MDD::T) where T<:AbstractFloat
```


Calculate the Calmar Ratio of investment. Also, see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat), and [`opsmetrics`](/funcs#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20AbstractVector{T}}}%20where%20{T<:AbstractFloat,%20S<:Int64}).

**Arguments**
- `APY::T`: the APY of investment.
  
- `MDD::T`: the MDD of investment.
  

**Returns**
- `::AbstractFloat`: the Calmar Ratio of investment.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L272-L283" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.cluslog' href='#OnlinePortfolioSelection.cluslog'><span class="jlbinding">OnlinePortfolioSelection.cluslog</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
cluslog(
  rel_pr::AbstractMatrix{<:AbstractFloat},
  horizon::Int,
  TW::Int,
  clus_mod::Type{<:ClusLogVariant},
  nclusters::Int,
  nclustering::Int,
  boundries::NTuple{2, AbstractFloat};
  progress::Bool=true
)
```


Run KMNLOG, KMDLOG, etc., algorithms on the given data.

::: tip Important note

In order to use this function, you have to install the [Clustering.jl](https://github.com/JuliaStats/Clustering.jl) package first, and then import it along with the OnlinePortfolioSelection.jl package:

```julia
julia> using Pkg; Pkg.add(name="Clustering", version="0.15.2")
julia> using OnlinePortfolioSelection, Clustering
```


:::

**Arguments**
- `rel_pr::AbstractMatrix{<:AbstractFloat}`: Relative prices of assets. Each column represents the price of an asset at a given time.
  
- `horizon::Int`: Number of trading days.
  
- `TW::Int`: Maximum time window length to be examined.
  
- `clus_mod::Type{<:ClusLogVariant}`: Clustering model to be used. Currently, only [`KMNLOG`](/types#OnlinePortfolioSelection.KMNLOG) and [`KMDLOG`](/types#OnlinePortfolioSelection.KMDLOG) are supported.
  
- `nclusters::Int`: The maximum number of clusters to be examined.
  
- `nclustering::Int`: The number of times clustering algorithm is run for optimal number of clusters.
  
- `boundries::NTuple{2, AbstractFloat}`: The lower and upper boundries for the weights of assets in the portfolio.
  

**Keyword Arguments**
- `progress::Bool=true`: Whether to log the progress or not.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

Two clustering model is available as of now: [`KMNLOG`](/types#OnlinePortfolioSelection.KMNLOG), and [`KMDLOG`](/types#OnlinePortfolioSelection.KMDLOG). The first example utilizes [`KMNLOG`](/types#OnlinePortfolioSelection.KMNLOG):

```julia
julia> using OnlinePortfolioSelection, Clustering

julia> adj_close = [
         1.5464 1.5852 1.6532 1.7245 1.5251 1.4185 1.2156 1.3231 1.3585 1.4563 1.4456
         1.2411 1.2854 1.3456 1.4123 1.5212 1.5015 1.4913 1.5212 1.5015 1.4913 1.5015
         1.3212 1.3315 1.3213 1.3153 1.3031 1.2913 1.2950 1.2953 1.3315 1.3213 1.3315
       ]

julia> rel_pr = adj_close[:, 2:end]./adj_close[:, 1:end-1]

julia> horizon = 3; TW = 3; nclusters_ = 3; nclustering = 10; lb, ub = 0.0, 1.;

julia> model = cluslog(rel_pr, horizon, TW, KMNLOG, nclusters_, nclustering, (lb, ub));

julia> model.b
3×3 Matrix{Float64}:
0.00264911  0.00317815  0.148012
0.973581    0.971728    0.848037
0.02377     0.0250939   0.00395028

julia> sum(model.b , dims=1) .|> isapprox(1.) |> all
true
```


The same approach works for [`KMDLOG`](/types#OnlinePortfolioSelection.KMDLOG) as well:

```julia
julia> using OnlinePortfolioSelection, Clustering

julia> model = cluslog(rel_pr, horizon, TW, KMDLOG, nclusters_, nclustering, (lb, ub));

julia> model.b
3×3 Matrix{Float64}:
4.59938e-7  4.96421e-7  4.89426e-7
0.999998    0.999997    0.999997
2.02964e-6  2.02787e-6  2.02964e-6

julia> sum(model.b , dims=1) .|> isapprox(1.) |> all
true
```


See also [`KMNLOG`](/types#OnlinePortfolioSelection.KMNLOG), and [`KMDLOG`](/types#OnlinePortfolioSelection.KMDLOG).

**Reference**
> 
> [An online portfolio selection algorithm using clustering approaches and considering transaction costs](https://doi.org/10.1016/j.eswa.2020.113546)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/CLUSLOG.jl#L1-L89" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.cornk-Union{Tuple{T}, Tuple{AbstractMatrix{<:AbstractFloat}, Vararg{T, 4}}} where T<:Integer' href='#OnlinePortfolioSelection.cornk-Union{Tuple{T}, Tuple{AbstractMatrix{<:AbstractFloat}, Vararg{T, 4}}} where T<:Integer'><span class="jlbinding">OnlinePortfolioSelection.cornk</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
cornk(
  x::AbstractMatrix{<:AbstractFloat},
  horizon::T,
  k::T,
  w::T,
  p::T;
  init_budg=1,
  progress::Bool=false
) where T<:Integer
```


Run CORN-K algorithm.

**Arguments**
- `x::AbstractMatrix{<:AbstractFloat}`: price relative matrix of assets.
  
- `horizon::T`: The number of periods to invest.
  
- `k::T`: The number of top experts to be selected.
  
- `w::T`: maximum length of time window to be examined.
  
- `p::T`: maximum number of correlation coefficient thresholds.
  

**Keyword Arguments**
- `init_budg=1`: The initial budget for investment.
  
- `progress::Bool=false`: Whether to show the progress bar.
  

::: warning Beware!

`x` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Examples**

```julia
julia> using OnlinePortfolioSelection

julia> x = rand(5, 100);

julia> model = cornk(x, 10, 3, 5, 3);

julia> model.alg
"CORN-K"

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```


See [`cornu`](/funcs#OnlinePortfolioSelection.cornu-Union{Tuple{M},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20M,%20M}}%20where%20{T<:AbstractFloat,%20M<:Integer}), and [`dricornk`](/funcs#OnlinePortfolioSelection.dricornk-Union{Tuple{M},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractVector{T},%20Vararg{M,%204}}}%20where%20{T<:AbstractFloat,%20M<:Integer}).

**Reference**
> 
> [CORN: Correlation-driven nonparametric learning approach for portfolio selection](https://doi.org/10.1145/1961189.1961193)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/CORN.jl#L80-L129" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.cornu-Union{Tuple{M}, Tuple{T}, Tuple{AbstractMatrix{T}, M, M}} where {T<:AbstractFloat, M<:Integer}' href='#OnlinePortfolioSelection.cornu-Union{Tuple{M}, Tuple{T}, Tuple{AbstractMatrix{T}, M, M}} where {T<:AbstractFloat, M<:Integer}'><span class="jlbinding">OnlinePortfolioSelection.cornu</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
cornu(
  x::AbstractMatrix{T},
  horizon::M,
  w::M;
  rho::T=0.2,
  init_budg=1,
  progress::Bool=false
) where {T<:AbstractFloat, M<:Integer}
```


Run CORN-U algorithm.

**Arguments**
- `x::AbstractMatrix{T}`: price relative matrix of assets.
  
- `horizon::M`: The number of periods to invest.
  
- `w::M`: maximum length of time window to be examined.
  

**Keyword Arguments**
- `rho::T=0.2`: The correlation coefficient threshold.
  
- `init_budg=1`: The initial budget for investment.
  
- `progress::Bool=false`: Whether to show the progress bar.
  

::: warning Beware!

`x` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Examples**

```julia
julia> using OnlinePortfolioSelection

julia> x = rand(5, 100);

julia> model = cornu(x, 10, 5, 0.5);

julia> model.alg
"CORN-U"

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```


See [`cornk`](/funcs#OnlinePortfolioSelection.cornk-Union{Tuple{T},%20Tuple{AbstractMatrix{<:AbstractFloat},%20Vararg{T,%204}}}%20where%20T<:Integer), and [`dricornk`](/funcs#OnlinePortfolioSelection.dricornk-Union{Tuple{M},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractVector{T},%20Vararg{M,%204}}}%20where%20{T<:AbstractFloat,%20M<:Integer}).

**Reference**
> 
> [CORN: Correlation-driven nonparametric learning approach for portfolio selection](https://doi.org/10.1145/1961189.1961193)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/CORN.jl#L1-L48" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.cwmr' href='#OnlinePortfolioSelection.cwmr'><span class="jlbinding">OnlinePortfolioSelection.cwmr</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
cwmr(
  rel_pr::AbstractMatrix,
  ϕ::AbstractFloat,
  ϵ::AbstractFloat,
  variant::Type{<:CWMRVariant},
  ptfdis::Type{<:PtfDisVariant}
)

cwmr(
  rel_pr::AbstractMatrix,
  ϕ::AbstractVector,
  ϵ::AbstractVector,
  variant::Type{<:CWMRVariant},
  ptfdis::Type{<:PtfDisVariant};
  adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing
)
```


Run the Confidence Weighted Mean Reversion (CWMR) algorithm.

::: tip Important note

In order to use this function, you have to install the [Distributions.jl](https://github.com/JuliaStats/Distributions.jl) package first, and then import it along with the OnlinePortfolioSelection.jl package:

```julia
julia> using Pkg; Pkg.add("Distributions")
julia> using Distributions, OnlinePortfolioSelection
```


:::

**Methods**
- `cwmr(rel_pr::AbstractMatrix, ϕ::AbstractFloat, ϵ::AbstractFloat, variant::Type{<:CWMRVariant}, ptfdis::Type{<:PtfDisVariant})`
  
- `cwmr(rel_pr::AbstractMatrix, ϕ::AbstractVector, ϵ::AbstractVector, variant::Type{<:CWMRVariant}, ptfdis::Type{<:PtfDisVariant}; adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing)`
  

**Method 1**

Through this method, we can run the following variants of the CWMR algorithm: `CWMR-Var`, `CWMR-Stdev`, `CWMR-Var-s` and `CWMR-Stdev-s`.

**Arguments**
- `rel_pr::AbstractMatrix`: Relative prices of the assets.
  
- `ϕ::AbstractFloat`: Learning rate.
  
- `ϵ::AbstractFloat`: Expert&#39;s weight. It should be ∈ [0, 1].
  
- `variant::Type{<:CWMRVariant}`: Variant of the algorithm. It can be `CWMRD` or `CWMRS`.
  
- `ptfdis::Type{<:PtfDisVariant}`: Portfolio distribution. It can be `Var` or `Stdev`.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object that contains the result of running the algorithm.
  

**Example**

Let&#39;s run all the variants of the first method, such as `CWMR-Var`, `CWMR-Stdev`, `CWMR-Var-s` and `CWMR-Stdev-s`:

```julia
julia> using OnlinePortfolioSelection, YFinance, Distributions

julia> tickers = ["AAPL", "MSFT", "AMZN"];

julia> startdt, enddt = "2019-01-01", "2019-01-10";

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker=tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> variant, ptf_distrib = CWMRS, Var;

julia> model = cwmr(rel_pr, 0.5, 0.1, variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.344307  1.0         1.0         0.965464   0.0
 0.274593  2.76907e-8  0.0         0.0186898  1.0
 0.3811    2.73722e-8  2.23057e-9  0.0158464  2.21487e-7
```


**Method 2**

Through this method, we can run the following variants of the CWMR algorithm: `CWMR-Var-Mix`, `CWMR-Stdev-Mix`, `CWMR-Var-s-Mix` and `CWMR-Stdev-s-Mix`.

**Arguments**
- `rel_pr::AbstractMatrix`: Relative prices of the assets.
  
- `ϕ::AbstractVector`: A vector of learning rates.
  
- `ϵ::AbstractVector`: A vector of expert&#39;s weights. Each element should be ∈ [0, 1].
  
- `variant::Type{<:CWMRVariant}`: Variant of the algorithm. It can be `CWMRD` or `CWMRS`.
  
- `ptfdis::Type{<:PtfDisVariant}`: Portfolio distribution. It can be `Var` or `Stdev`.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Keyword Arguments**
- `adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing`: A vector of additional expert&#39;s portfolios.
  

::: warning Beware!

`adt_ptf` can be `nothing` or a vector of matrices of size `n_assets` × `n_periods`. As noted in the paper, the additional expert&#39;s portfolios should be chosen from the set of universal strategies, such as &#39;UP&#39;, &#39;EG&#39;, &#39;ONS&#39;, etc. See [`eg`](/funcs#OnlinePortfolioSelection.eg-Tuple{AbstractMatrix}), and [`up`](/funcs#OnlinePortfolioSelection.up-Union{Tuple{AbstractMatrix{T}},%20Tuple{T}}%20where%20T<:AbstractFloat) for more details.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object that contains the result of running the algorithm.
  

**Example**

Let&#39;s run all the variants of the second method, such as `CWMR-Var-Mix`, `CWMR-Stdev-Mix`, `CWMR-Var-s-Mix` and `CWMR-Stdev-s-Mix`:

```julia
julia> variant, ptf_distrib = CWMRS, Var;

julia> model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib);

julia> model.b
3×5 Matrix{Float64}:
 0.329642  0.853456   0.863553   0.819096  0.0671245
 0.338512  0.0667117  0.0694979  0.102701  0.842985
 0.331846  0.0798325  0.0669491  0.078203  0.0898904
```


Now, let&#39;s pass two different &#39;EG&#39; portfolios as additional expert&#39;s portfolios:

```julia
julia> variant, ptf_distrib = CWMRS, Var;

julia> eg1 = eg(rel_pr, eta=0.1).b;

julia> eg2 = eg(rel_pr, eta=0.2).b;

julia> model = cwmr(rel_pr, [0.5, 0.5], [0.1, 0.1], variant, ptf_distrib, adt_ptf=[eg1, eg2]);

julia> model.b
3×5 Matrix{Float64}:
 0.318927  0.768507  0.721524  0.753618  0.135071
 0.338759  0.111292  0.16003   0.133229  0.741106
 0.342314  0.120201  0.118446  0.113154  0.123823
```


See [Confidence Weighted Mean Reversion (CWMR)](/FL#Confidence-Weighted-Mean-Reversion-(CWMR)) for more informaton and examples.

**References**
> 
> [Confidence Weighted Mean Reversion Strategy for Online Portfolio Selection](http://dx.doi.org/10.1145/2435209.2435213)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/CWMR.jl#L2-L138" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.cwogd-Tuple{AbstractMatrix, AbstractFloat, Any}' href='#OnlinePortfolioSelection.cwogd-Tuple{AbstractMatrix, AbstractFloat, Any}'><span class="jlbinding">OnlinePortfolioSelection.cwogd</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
cwogd(
  rel_pr::AbstractMatrix,
  γ::AbstractFloat,
  H;
  bj::AbstractMatrix=diagm(ones(size(rel_pr, 1)))
)
```


Run the CW-OGD algorithm.

**Positional Arguments**
- `rel_pr::AbstractMatrix`: Relative price matrix where it represents proportion of the closing price to the opening price of each asset in each day.
  
- `γ::AbstractFloat`: Regular term coefficient of the basic expert&#39;s loss function.
  
- `H::AbstractFloat`: Constant for calculating step sizes.
  

**Keyword Arguments**
- `bj::AbstractMatrix=diagm(ones(size(rel_pr, 1)))`: Matrix of experts opinions. Each column of this matrix must have just one positive element == 1. and others are zero. Also, sum of each column must be equal to 1. and number of rows must be equal to number of rows of `rel_pr`.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) type.
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> startdt, enddt = "2019-01-01", "2019-01-10";

julia> querry_open_price = [get_prices(ticker, startdt=startdt, enddt=enddt)["open"] for ticker in tickers];

julia> open_pr = reduce(hcat, querry_open_price) |> permutedims;

julia> querry_close_pr = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> close_pr = reduce(hcat, querry_close_pr) |> permutedims;

julia> rel_pr = close_pr ./ open_pr
3×6 Matrix{Float64}:
 1.01956  0.987568  1.02581  0.994822  1.00796   1.01335
 1.01577  0.973027  1.02216  1.00413   0.997671  1.00395
 1.0288   0.976042  1.03692  0.997097  1.00016   0.993538

julia> gamma = 0.1; H = 0.5;

julia> model = cwogd(rel_pr, gamma, H);

julia> model.b
3×5 Matrix{Float64}:
 0.333333  0.351048  0.346241  0.338507  0.350524
 0.333333  0.321382  0.309454  0.320351  0.311853
 0.333333  0.32757   0.344305  0.341142  0.337623

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```


Or using a custom matrix of experts opinions:

```julia
julia> b1 = [
          0.0 1.0 0.0
          1.0 0.0 0.0
          0.0 0.0 1.0
        ]

julia> model = cwogd(rel_pr, gamma, H, bj=b1);

julia> model.b
3×6 Matrix{Float64}:
 0.333333  0.329802  0.347517  0.34271   0.334976  0.346992
 0.333333  0.322351  0.3104    0.298472  0.309369  0.300871
 0.333333  0.347847  0.342083  0.358819  0.355655  0.352137

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```


**References**
> 
> [[1] Combining expert weights for online portfolio selection based on the gradient descent algorithm.](https://doi.org/10.1016/j.knosys.2021.107533)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/CW-OGD.jl#L59-L142" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.dmr' href='#OnlinePortfolioSelection.dmr'><span class="jlbinding">OnlinePortfolioSelection.dmr</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
dmr(
  x::AbstractMatrix,
  horizon::Integer,
  α::Union{Nothing, AbstractVector{<:AbstractFloat}},
  n::Integer,
  w::Integer,
  η::AbstractFloat=0.
)
```


Run Distributed Mean Reversion (DMR) strategy.

**Arguments**
- `x::AbstractMatrix`: A matrix of asset price relatives.
  
- `horizon::Integer`: Investment horizon.
  
- `α::Union{Nothing, AbstractVector{<:AbstractFloat}}`: Vector of step sizes. If `nothing` is passed, the algorithm itself determines the values.
  
- `w::Integer`: Window size.
  
- `η::AbstractFloat=0.`: Threshold.
  

**Returns**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> assets = [
         "MSFT", "META", "GOOG", "AAPL", "AMZN", "TSLA", "NVDA", "PYPL", "ADBE", "NFLX", "MMM", "ABT", "ABBV", "ABMD", "ACN", "ATVI", "ADSK", "ADP", "AZN", "AMGN", "AVGO", "BA"
       ]

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2021-01-01")["adjclose"] for ticker=assets]

julia> prices = stack(querry, dims=1)

julia> x = prices[:, 2:end]./prices[:, 1:end-1]

julia> eta = 0.

julia> alpha = nothing

julia> n = 10

julia> w = 4

julia> horizon = 50

julia> model = dmr(x, horizon, alpha, n, w, eta);

julia> model.b
22×50 Matrix{Float64}:
 0.0454545  0.0910112   0.0909008    …  0.0907232    0.090959     0.0909736
 0.0454545  0.00706777  0.00706777      0.00706777   0.00706777   0.0978817
 0.0454545  0.0954079   0.095159        0.00432265   0.00432265   0.0955929
 0.0454545  0.0964977   0.0962938       0.0960025    0.0967765    0.0966751
 0.0454545  0.00476753  0.0957164       0.0956522    0.0957777    0.00476753
 0.0454545  0.00550015  0.00550015   …  0.00550015   0.00550015   0.00550015
 0.0454545  0.00426904  0.0952782       0.0949815    0.0945237    0.00426904
 0.0454545  0.00317911  0.00317911      0.00317911   0.00317911   0.00317911
 0.0454545  0.0944016   0.00350562      0.00350562   0.0938131    0.00350562
 0.0454545  0.00150397  0.00150397      0.0921901    0.0918479    0.0912083
 0.0454545  0.0956671   0.0959533    …  0.0960898    0.0962863    0.0960977
 0.0454545  0.00365637  0.0945089       0.00365637   0.00365637   0.00365637
 0.0454545  0.0909954   0.000375678     0.000375678  0.000375678  0.000375678
 0.0454545  0.00487068  0.00487068      0.0958842    0.00487068   0.0951817
 0.0454545  0.0970559   0.00595991      0.096872     0.0972911    0.0973644
 0.0454545  0.00523895  0.00523895   …  0.00523895   0.00523895   0.0963758
 0.0454545  0.00764483  0.00764483      0.00764483   0.00764483   0.00764483
 0.0454545  0.0971981   0.0971457       0.0974226    0.0975877    0.0973244
 0.0454545  0.00218155  0.0930112       0.0934464    0.00218155   0.00218155
 0.0454545  0.0914433   0.0915956       0.000654204  0.000654204  0.000654204
 0.0454545  0.0937513   0.00289981   …  0.00289981   0.0937545    0.00289981
 0.0454545  0.00669052  0.00669052      0.00669052   0.00669052   0.00669052
```


**Reference**
> 
> [Distributed mean reversion online portfolio strategy with stock network](https://doi.org/10.1016/j.ejor.2023.11.021)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/DMR.jl#L50-L126" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.dricornk-Union{Tuple{M}, Tuple{T}, Tuple{AbstractMatrix{T}, AbstractVector{T}, Vararg{M, 4}}} where {T<:AbstractFloat, M<:Integer}' href='#OnlinePortfolioSelection.dricornk-Union{Tuple{M}, Tuple{T}, Tuple{AbstractMatrix{T}, AbstractVector{T}, Vararg{M, 4}}} where {T<:AbstractFloat, M<:Integer}'><span class="jlbinding">OnlinePortfolioSelection.dricornk</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
dricornk(
  x::AbstractMatrix{T},
  relpr_market::AbstractVector{T},
  horizon::M,
  k::M,
  w::M,
  p::M;
  lambda::T=1e-3,
  init_budg=1,
  progress::Bool=false
) where {T<:AbstractFloat, M<:Integer}
```


Run the DRICORNK algorithm.

**Arguments**
- `x::AbstractMatrix{T}`: A matrix of relative prices of the assets.
  
- `relpr_market::AbstractVector{T}`: A vector of relative prices of the market in the same period.
  
- `horizon::M`: The investment horizon.
  
- `k::M`: The number of experts.
  
- `w::M`: maximum length of time window to be examined.
  
- `p::M`: maximum number of correlation coefficient thresholds.
  

**Keyword Arguments**
- `lambda::T=1e-3`: The regularization parameter.
  
- `init_budg=1`: The initial budget for investment.
  
- `progress::Bool=false`: Whether to show the progress bar.
  

::: warning Beware!

`x` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Example**

```julia
julia> using OnlinePortfolioSelection

julia> stocks_ret, market_ret = rand(10, 100), rand(100);

julia> m_dricornk = dricornk(stocks_ret, market_ret, 5, 2, 4, 3);

julia> sum(m_dricornk.b, dims=1) .|> isapprox(1.) |> all
true
```


See [`cornk`](/funcs#OnlinePortfolioSelection.cornk-Union{Tuple{T},%20Tuple{AbstractMatrix{<:AbstractFloat},%20Vararg{T,%204}}}%20where%20T<:Integer), and [`cornu`](/funcs#OnlinePortfolioSelection.cornu-Union{Tuple{M},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20M,%20M}}%20where%20{T<:AbstractFloat,%20M<:Integer}).

**Reference**
> 
> [DRICORN-K: A Dynamic RIsk CORrelation-driven Non-parametric Algorithm for Online Portfolio Selection](https://www.doi.org/10.1007/978-3-030-66151-9_12)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/DRICORNK.jl#L1-L51" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.eg-Tuple{AbstractMatrix}' href='#OnlinePortfolioSelection.eg-Tuple{AbstractMatrix}'><span class="jlbinding">OnlinePortfolioSelection.eg</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
eg(rel_pr::AbstractMatrix; eta::AbstractFloat=0.05)
```


Run Exponential Gradient (EG) algorithm.

**Arguments**
- `rel_pr::AbstractMatrix`: Historical relative prices.
  

**Keyword Arguments**
- `eta::AbstractFloat=0.05`: Learning rate.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Examples**

```julia
julia> using OnlinePortfolioSelection

julia> typeof(rel_pr), size(rel_pr)
(Matrix{Float64}, (3, 10))

julia> m_eg = eg(rel_pr);

julia> m_eg.b
3×10 Matrix{Float64}:
 0.333333  0.334092  0.325014  0.331234  0.314832  0.324674  0.326467  0.357498  0.353961  0.340167
 0.333333  0.345278  0.347718  0.337116  0.359324  0.363286  0.36466   0.348263  0.345386  0.355034
 0.333333  0.32063   0.327267  0.331649  0.325843  0.31204   0.308873  0.294239  0.300652  0.304799

julia> sum(m_eg.b, dims=1) .|> isapprox(1.0) |> all
true
```


**References**
> 
> [On-Line Portfolio Selection Using Multiplicative Updates](https://onlinelibrary.wiley.com/doi/10.1111/1467-9965.00058)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/EG.jl#L1-L39" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.egm' href='#OnlinePortfolioSelection.egm'><span class="jlbinding">OnlinePortfolioSelection.egm</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
egm(rel_pr::AbstractMatrix, model::EGMFramework, η::AbstractFloat=0.05)
```


Run the Exponential Gradient with Momentum (EGM) algorithm. This framework contains three variants: [`EGE`](/types#OnlinePortfolioSelection.EGE), [`EGR`](/types#OnlinePortfolioSelection.EGR) and [`EGA`](/types#OnlinePortfolioSelection.EGA).

**Arguments**
- `rel_pr::AbstractMatrix`: matrix of size `n_assets` by `n_periods` containing the relative prices.
  
- `model::EGMFramework`: EGM framework. [`EGE`](/types#OnlinePortfolioSelection.EGE), [`EGR`](/types#OnlinePortfolioSelection.EGR) or [`EGA`](/types#OnlinePortfolioSelection.EGA) can be used.
  
- `η::AbstractFloat=0.05`: learning rate.
  

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2019-01-12")["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1]
3×7 Matrix{Float64}:
 0.900393  1.04269  0.997774  1.01906  1.01698   1.0032    0.990182
 0.963212  1.04651  1.00128   1.00725  1.0143    0.993574  0.992278
 0.971516  1.05379  0.997833  1.00738  0.998495  0.995971  0.987723

julia> # EGE variant
julia> variant = EGE(0.5)

julia> model = egm(rel_pr, variant);

julia> model.b
3×7 Matrix{Float64}:
 0.333333  0.33294   0.332704  0.332576  0.332576  0.332634  0.332711
 0.333333  0.333493  0.333564  0.333619  0.333614  0.333647  0.33363
 0.333333  0.333567  0.333732  0.333805  0.33381   0.333719  0.333659

julia> # EGR variant
julia> variant = EGR(0.)

julia> model = egm(rel_pr, variant);

julia> model.b
3×7 Matrix{Float64}:
 0.333333  0.348653  0.350187  0.350575  0.348072  0.345816  0.344006
 0.333333  0.327     0.327299  0.326573  0.327852  0.326546  0.327824
 0.333333  0.324347  0.322514  0.322853  0.324077  0.327638  0.328169

julia> # EGA variant
julia> variant = EGA(0.5, 0.)

julia> model = egm(rel_pr, variant);

julia> model.b
3×7 Matrix{Float64}:
 0.333333  0.349056  0.350429  0.350706  0.348071  0.345757  0.343929
 0.333333  0.326833  0.327223  0.326516  0.327857  0.326514  0.327842
 0.333333  0.324111  0.322348  0.322779  0.324072  0.327729  0.328229
```


**References**
> 
> [Exponential Gradient with Momentum for Online Portfolio Selection](https://doi.org/10.1016/j.eswa.2021.115889)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/EGM.jl#L119-L184" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.gwr' href='#OnlinePortfolioSelection.gwr'><span class="jlbinding">OnlinePortfolioSelection.gwr</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
gwr(
  prices::AbstractMatrix,
  horizon::Integer,
  τ::Real=2.8,
  𝛿::Integer=50,
  ϵ::AbstractFloat=0.005
)

gwr(
  prices::AbstractMatrix,
  horizon::Integer,
  τ::AbstractVector{<:Real},
  𝛿::Integer=50,
  ϵ::AbstractFloat=0.005
)
```


Run the Gaussian Weighting Reversion (GWR) Strategy.

::: warning Beware!

`prices` should be a matrix of size `n_assets` × `n_periods`.

:::

**Method 1**

Run &#39;GWR&#39; variant.

**Arguments**
- `prices::AbstractMatrix`: Matrix of prices.
  
- `horizon::Integer`: The investment horizon.
  
- `τ::Real=2.8`: The parameter of gaussian function.
  
- `𝛿::Integer=50`: Hyperparameter.
  
- `ϵ::AbstractFloat=0.005`: A parameter to control the weighted range.
  

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["MSFT", "GOOG", "META"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-23")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1)
3×14 Matrix{Float64}:
 154.78    152.852  153.247   151.85   154.269  156.196   155.473   157.343   156.235  157.246  160.128  161.024   160.446  159.675
  68.3685   68.033   69.7105   69.667   70.216   70.9915   71.4865   71.9615   71.544   71.96    72.585   74.0195   74.22    74.2975
 209.78    208.67   212.6     213.06   215.22   218.3     218.06    221.91    219.06   221.15   221.77   222.14    221.44   221.32

julia> h = 3

julia> model = gwr(prices, h);

julia> model.b
3×3 Matrix{Float64}:
 0.333333  0.333333  1.4095e-11
 0.333333  0.333333  0.0
 0.333333  0.333333  1.0
```


**Method 2**

Run &#39;GWR-A&#39; variant.

**Arguments**
- `prices::AbstractMatrix`: Matrix of prices.
  
- `horizon::Integer`: The investment horizon.
  
- `τ::AbstractVector{<:Real}`: The parameters of gaussian function.
  
- `𝛿::Integer=50`: Hyperparameter.
  
- `ϵ::AbstractFloat=0.005`: A parameter to control the weighted range.
  

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["MSFT", "GOOG", "META"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-23")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1)
3×14 Matrix{Float64}:
 154.78    152.852  153.247   151.85   154.269  156.196   155.473   157.343   156.235  157.246  160.128  161.024   160.446  159.675
  68.3685   68.033   69.7105   69.667   70.216   70.9915   71.4865   71.9615   71.544   71.96    72.585   74.0195   74.22    74.2975
 209.78    208.67   212.6     213.06   215.22   218.3     218.06    221.91    219.06   221.15   221.77   222.14    221.44   221.32

julia> h = 3

julia> model = gwr(prices, h, [2, 3, 4]);

julia> model.b
3×3 Matrix{Float64}:
 0.333333  0.0  1.20769e-11
 0.333333  0.0  0.0
 0.333333  1.0  1.0
```


**Reference**
> 
> [Gaussian Weighting Reversion Strategy for Accurate On-line Portfolio Selection](https://doi.org/10.1109/TSP.2019.2941067)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/GWR.jl#L106-L206" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.ir-Union{Tuple{S}, Tuple{AbstractMatrix{S}, AbstractMatrix{S}, AbstractVector{S}}} where S<:AbstractFloat' href='#OnlinePortfolioSelection.ir-Union{Tuple{S}, Tuple{AbstractMatrix{S}, AbstractMatrix{S}, AbstractVector{S}}} where S<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.ir</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
ir(
  weights::AbstractMatrix{S},
  rel_pr::AbstractMatrix{S},
  rel_pr_market::AbstractVector{S};
  init_inv::S=1.
) where S<:AbstractFloat
```


Calculate the Information Ratio (IR) of portfolio. Also, see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`opsmetrics`](/funcs#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20AbstractVector{T}}}%20where%20{T<:AbstractFloat,%20S<:Int64}).

The formula for calculating the Information Ratio (IR) of portfolio is as follows:

$$IR = \frac{{{{\bar R}_s} - {{\bar R}_m}}}{{\sigma \left( {{R_s} - {R_m}} \right)}}$$

where $R_s$ represents the portfolio&#39;s daily return, $R_m$ represents the market&#39;s daily return, $\bar R_s$ represents the portfolio&#39;s average daily return, $\bar R_m$ represents the market&#39;s average daily return, and $\sigma$ represents the standard deviation of the portfolio&#39;s daily excess return over the market. Note that in this package, the logarithmic return is used.

**Arguments**
- `weights::AbstractMatrix{S}`: the weights of the portfolio.
  
- `rel_pr::AbstractMatrix{S}`: the relative price of the stocks.
  
- `rel_pr_market::AbstractVector{S}`: the relative price of the market.
  

**Keyword Arguments**
- `init_inv::S=1`: the initial investment.
  

::: warning Warning

The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

:::

::: tip Note

If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last `size(weights, 2)` columns of `rel_pr` will be used. The size of `rel_pr_market` will automatically be adjusted to the size of `w`.

:::

**Returns**
- `::AbstractFloat`: the Information Ratio (IR) of portfolio for the investment period.
  

**References**
> 
> [Adaptive online portfolio strategy based on exponential gradient updates](https://doi.org/10.1007/s10878-021-00800-7)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L132-L169" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.ktpt' href='#OnlinePortfolioSelection.ktpt'><span class="jlbinding">OnlinePortfolioSelection.ktpt</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
function ktpt(
  prices::AbstractMatrix,
  horizon::S,
  w::S,
  q::S,
  η::S,
  ν::T,
  p̂ₜ::AbstractVector,
  b̂ₜ::Union{Nothing, AbstractVector{T}}
) where {S<:Integer, T<:AbstractFloat}
```


Run kernel-based trend pattern tracking system for portfolio optimization model.

::: tip Important note

In order to use this function, you have to install the [Lasso.jl](https://github.com/JuliaStats/Lasso.jl) package first, and then import it along with the OnlinePortfolioSelection.jl package:

```julia
julia> using Pkg; Pkg.add("Lasso")
julia> using Lasso, OnlinePortfolioSelection
```


:::

**Arguments**
- `prices::AbstractMatrix`: Matrix of daily prices of assets.
  
- `horizon::S`: The horizon to run the algorithm for.
  
- `w::S`: The window size.
  
- `q::S`: Coefficient.
  
- `η::S`: Step size to optimize the portfolio.
  
- `ν::T`: is a mixing parameter that tunes the proportion of ℓ1 and ℓ2 regularization.
  
- `p̂ₜ::AbstractVector`: The vector of size `n_assets` at time `t`.
  
- `b̂ₜ::Union{Nothing, AbstractVector{T}}`: The vector of portfolio weights at time `t`.
  

::: warning Beware!

`prices` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

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
```


**Reference**
> 
> [A kernel-based trend pattern tracking system for portfolio optimization](https://doi.org/10.1007/s10618-018-0579-5)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/KTPT.jl#L1-L64" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.load-Union{Tuple{S}, Tuple{T}, Tuple{AbstractMatrix{T}, T, S, S, T}} where {T<:AbstractFloat, S<:Int64}' href='#OnlinePortfolioSelection.load-Union{Tuple{S}, Tuple{T}, Tuple{AbstractMatrix{T}, T, S, S, T}} where {T<:AbstractFloat, S<:Int64}'><span class="jlbinding">OnlinePortfolioSelection.load</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
load(adj_close::AbstractMatrix{T}, α::T, ω::S, horizon::S, η::T, ϵ::T=1.5) where {T<:AbstractFloat, S<:Int}
```


Run LOAD algorithm.

**Arguments**
- `adj_close::AbstractMatrix{T}`: Adjusted close price data.
  
- `α::T`: Decay factor. (0 &lt; α &lt; 1)
  
- `ω::S`: Window size. (ω &gt; 0)
  
- `horizon::S`: Investment horizon. (n_periods &gt; horizon &gt; 0)
  
- `η::T`: Threshold value. (η &gt; 0)
  
- `ϵ::T=1.5`: Expected return threshold value.
  

::: warning Beware!

`adj_close` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of type `OPSAlgorithm` containing the weights of each asset for each period.
  

**Example**

```julia
# Get data
julia> using YFinance
julia> startdt, enddt = "2022-04-01", "2023-04-27";
julia> querry = [
          get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers
       ];
julia> prices = reduce(hcat, querry);
julia> prices = permutedims(prices);

julia> using OnlinePortfolioSelection

julia> model = load(prices, 0.5, 30, 5, 0.1);

julia> model.b
5×5 Matrix{Float64}:
 0.2  2.85298e-8  0.0        0.0       0.0
 0.2  0.455053    0.637299   0.694061  0.653211
 0.2  0.215388    0.0581291  0.0       0.0
 0.2  0.329559    0.304572   0.305939  0.346789
 0.2  6.06128e-9  0.0        0.0       0.0

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```


**References**
> 
> [A local adaptive learning system for online portfolio selection](https://doi.org/10.1016/j.knosys.2019.104958)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/LOAD.jl#L124-L172" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.maeg-Tuple{AbstractMatrix, Integer, AbstractVector}' href='#OnlinePortfolioSelection.maeg-Tuple{AbstractMatrix, Integer, AbstractVector}'><span class="jlbinding">OnlinePortfolioSelection.maeg</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
maeg(x::AbstractMatrix, w::Integer, H::AbstractVector)
```


Run Moving-window-based Adaptive Exponential Gradient (MAEG) algorithm.

**Arguments**
- `x::AbstractMatrix`: A matrix of price relatives of `n_assets` over `n_periods`.
  
- `w::Integer`: The window size.
  
- `H::AbstractVector`: A vector of learning rates.
  

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

::: warning Beware!

`x` should be a matrix of size `n_assets` × `n_periods`.

:::

**Example**

```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(4, 10);

julia> w = 3;

julia> H = [0.01, 0.02, 0.2];

julia> m = maeg(rel_pr, w, H);

julia> m.b
4×10 Matrix{Float64}:
 0.25  0.250307  0.25129   0.251673  0.250823  0.267687  0.313794  0.319425  0.378182  0.427249
 0.25  0.249138  0.248921  0.249289  0.250482  0.23192   0.202576  0.179329  0.160005  0.168903
 0.25  0.250026  0.250656  0.24931   0.24995   0.226647  0.237694  0.237879  0.216076  0.192437
 0.25  0.250528  0.249134  0.249728  0.248744  0.273746  0.245936  0.263367  0.245737  0.211411
```


**References**
> 
> [Adaptive online portfolio strategy based on exponential gradient updates](https://doi.org/10.1007/s10878-021-00800-7)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/MAEG.jl#L7-L45" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}}, Tuple{T}} where T<:AbstractFloat' href='#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}}, Tuple{T}} where T<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.mdd</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
mdd(Sn::AbstractVector{T}) where T<:AbstractFloat
```


Calculate the Maximum Drawdown (MDD) of investment. Also, see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`opsmetrics`](/funcs#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20AbstractVector{T}}}%20where%20{T<:AbstractFloat,%20S<:Int64}).

**Arguments**
- `Sn::AbstractVector{T}`: the cumulative wealth of investment during the investment period. see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat).
  

**Returns**
- `::AbstractFloat`: the MDD of investment.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L250-L260" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.mer-Union{Tuple{T}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}, T}} where T<:AbstractFloat' href='#OnlinePortfolioSelection.mer-Union{Tuple{T}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}, T}} where T<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.mer</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
mer(
  weights::AbstractMatrix{T},
  rel_pr::AbstractMatrix{T},
  𝘷::T=0.
) where T<:AbstractFloat
```


Calculate the investments&#39;s Mean excess return (MER). Also, see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`opsmetrics`](/funcs#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20AbstractVector{T}}}%20where%20{T<:AbstractFloat,%20S<:Int64}).

**Arguments**
- `weights::AbstractMatrix{T}`: the weights of the portfolio.
  
- `rel_pr::AbstractMatrix{T}`: the relative price of the stocks.
  
- `𝘷::T=0.`: the transaction cost rate.
  

::: warning Warning

The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

:::

::: tip Note

If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last `size(weights, 2)` columns of `rel_pr` will be used.

:::

**Returns**
- `MER::AbstractFloat`: the investments&#39;s Mean excess return (MER).
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L85-L107" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.mrvol-Union{Tuple{S}, Tuple{T}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}, S, S, S, T, T}} where {T<:AbstractFloat, S<:Integer}' href='#OnlinePortfolioSelection.mrvol-Union{Tuple{S}, Tuple{T}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}, S, S, S, T, T}} where {T<:AbstractFloat, S<:Integer}'><span class="jlbinding">OnlinePortfolioSelection.mrvol</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
mrvol(
  rel_pr::AbstractMatrix{T},
  rel_vol::AbstractMatrix{T},
  horizon::S,
  Wₘᵢₙ::S,
  Wₘₐₓ::S,
  λ::T,
  η::T
) where {T<:AbstractFloat, S<:Integer}
```


Run MRvol algorithm.

**Arguments**
- `rel_pr::AbstractMatrix{T}`: Relative price matrix where it represents proportion of the closing price to the opening price of each asset in each day.
  
- `rel_vol::AbstractMatrix{T}`: Relative volume matrix where 𝘷ᵢⱼ represents the tᵗʰ trading volume of asset 𝑖 divided by the (t - 1)ᵗʰ trading volume of asset 𝑖.
  
- `horizon::S`: Investment horizon. The last `horizon` days of the data will be used to run the algorithm.
  
- `Wₘᵢₙ::S`: Minimum window size.
  
- `Wₘₐₓ::S`: Maximum window size.
  
- `λ::T`: Trade-off parameter in the loss function.
  
- `η::T`: Learning rate.
  

::: warning Beware!

`rel_pr` and `rel_vol` should be matrixes of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

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
 0.333333  0.0204062  0.0444759  …  0.38213   0.467793
 0.333333  0.359864   0.194139      0.213264  0.281519
 0.333333  0.61973    0.761385      0.404606  0.250689
```


**References**
> 
> [Online portfolio selection of integrating expert strategies based on mean reversion and trading volume.](https://doi.org/10.1016/j.eswa.2023.121472)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/MRvol.jl#L257-L325" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.oldem-Union{Tuple{T}, Tuple{S}, Tuple{AbstractMatrix, S, S, S, S, T, T, T}} where {S<:Integer, T<:AbstractFloat}' href='#OnlinePortfolioSelection.oldem-Union{Tuple{T}, Tuple{S}, Tuple{AbstractMatrix, S, S, S, S, T, T, T}} where {S<:Integer, T<:AbstractFloat}'><span class="jlbinding">OnlinePortfolioSelection.oldem</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
oldem(
  rel_pr::AbstractMatrix,
  horizon::S,
  w::S,
  L::S,
  s::S,
  σ::T,
  ξ::T,
  γ::T;
  bt::AbstractVector = ones(size(rel_pr, 1))/size(rel_pr, 1)
) where {S<:Integer, T<:AbstractFloat}
```


Run Online Low Dimension Ensemble Method (OLDEM).

**Arguments**
- `rel_pr::AbstractMatrix`: A matrix of size `n_assets` × `T` containing the price relatives of assets.
  
- `horizon::S`: Investment horizon.
  
- `w::S`: Window size.
  
- `L::S`: Number of subsystems.
  
- `s::S`: Number of assets in each subsystem.
  
- `σ::T`: Kernel bandwidth.
  
- `ξ::T`: tradeoff parameter.
  
- `γ::T`: tradeoff parameter.
  

**Keyword Arguments**
- `bt::AbstractVector`: A vector of length `n_assets` containing the initial portfolio weights. Presumebly, the initial portfolio portfolio is the equally weighted portfolio. However, one can use any other portfolio weights that satisfy the following condition: $\sum_{i=1}^{n\_assets} b_{i} = 1$.
  
- `progress::Bool=false`: Show the progress bar.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Example**

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


**References**
> 
> [Online portfolio selection with predictive instantaneous risk assessment](https://doi.org/10.1016/j.patcog.2023.109872)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/OLDEM.jl#L535-L610" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.olmar-Tuple{AbstractMatrix, Int64, Int64, Int64}' href='#OnlinePortfolioSelection.olmar-Tuple{AbstractMatrix, Int64, Int64, Int64}'><span class="jlbinding">OnlinePortfolioSelection.olmar</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
olmar(rel_pr::AbstractMatrix, horizon::Int, ω::Int, ϵ::Int)
olmar(rel_pr::AbstractMatrix, horizon::Int, ω::AbstractVector{<:Int}, ϵ::Int)
```


**Method 1**

Run the Online Moving Average Reversion algorithm (OLMAR).

**Arguments**
- `rel_pr::AbstractMatrix`: Matrix of relative prices.
  
- `horizon::Int`: Investment horizon.
  
- `ω::Int`: Window size.
  
- `ϵ::Int`: Reversion threshold.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "AMZN", "GOOG", "META"];

julia> startdt, enddt = "2019-01-01", "2020-01-01"

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> horizon = 5;
julia> windows = 3;
julia> epsilon = 4;

julia> m_olmar = olmar(rel_pr, horizon, windows, epsilon);

julia> m_olmar.b
5×5 Matrix{Float64}:
 0.2  1.0         0.484825  1.97835e-8  0.0
 0.2  1.95724e-8  0.515175  0.0         0.0
 0.2  0.0         0.0       1.0         1.0
 0.2  0.0         0.0       0.0         0.0
 0.2  0.0         0.0       0.0         1.9851e-8

julia> all(sum(m_olmar.b, dims=1) .≈ 1.0)
true
```


**Method 2**

Run BAH(OLMAR) algorithm.

**Arguments**
- `rel_pr::AbstractMatrix`: Matrix of relative prices.
  
- `horizon::Int`: Investment horizon.
  
- `ω::AbstractVector{<:Int}`: Window sizes.
  
- `ϵ::Int`: Reversion threshold.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "AMZN", "GOOG", "META"];

julia> startdt, enddt = "2019-01-01", "2020-01-01"

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> horizon = 5;
julia> windows = [3, 5, 7];
julia> epsilon = 4;

julia> model = olmar(rel_pr, horizon, windows, epsilon);

julia> model.b
5×5 Matrix{Float64}:
 0.2  0.2  0.333333    0.162297  1.33072e-8
 0.2  0.2  1.31177e-8  0.555158  0.0
 0.2  0.2  6.57906e-9  0.0       0.667358
 0.2  0.2  0.0         0.0       0.332642
 0.2  0.2  0.666667    0.282545  0.0
```


**References**
> 
> [On-Line Portfolio Selection with Moving Average Reversion](https://doi.org/10.48550/arXiv.1206.4626)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/OLMAR.jl#L1-L98" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.ons' href='#OnlinePortfolioSelection.ons'><span class="jlbinding">OnlinePortfolioSelection.ons</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
ons(rel_pr::AbstractMatrix, β::Integer=1, 𝛿::AbstractFloat=1/8, η::AbstractFloat=0.)
```


Run Online Newton Step (ONS) algorithm.

**Arguments**
- `rel_pr::AbstractMatrix`: relative prices.
  
- `β::Integer=1`: Hyperparameter.
  
- `𝛿::AbstractFloat=1/8`: Heuristic tuning parameter.
  
- `η::AbstractFloat=0.`: Learning rate.
  

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

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


**References**
> 
> [Algorithms for Portfolio Management based on the Newton Method](https://doi.org/10.1145/1143844.1143846)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/ONS.jl#L38-L75" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.opsmethods-Tuple{}' href='#OnlinePortfolioSelection.opsmethods-Tuple{}'><span class="jlbinding">OnlinePortfolioSelection.opsmethods</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
opsmethods()
```


Print the available algorithms in the package.

**Example**

```julia
julia> using OnlinePortfolioSelection

julia> opsmethods()

      ===== OnlinePortfolioSelection.jl =====
            Currently available methods
       =====================================

        up: Universal Portfolio - Call `up`
        eg: Exponential Gradient - Call `eg`
     cornu: CORN-U - Call `cornu`
          ⋮
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/OnlinePortfolioSelection.jl#L81-L101" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.opsmetrics-Union{Tuple{S}, Tuple{T}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}, AbstractVector{T}}} where {T<:AbstractFloat, S<:Int64}' href='#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S}, Tuple{T}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}, AbstractVector{T}}} where {T<:AbstractFloat, S<:Int64}'><span class="jlbinding">OnlinePortfolioSelection.opsmetrics</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
opsmetrics(
  weights::AbstractMatrix{T},
  rel_pr::AbstractMatrix{T},
  rel_pr_market::AbstractVector{T};
  init_inv::T=1.,
  Rf::T=0.02
  dpy::S=252,
  v::T=0.
  dpy::S=252
) where {T<:AbstractFloat, S<:Int}
```


Calculate the metrics of an OPS algorithm. Also, see [`sn`](/funcs#OnlinePortfolioSelection.sn-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}}}%20where%20T<:AbstractFloat), [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ir`](/funcs#OnlinePortfolioSelection.ir-Union{Tuple{S},%20Tuple{AbstractMatrix{S},%20AbstractMatrix{S},%20AbstractVector{S}}}%20where%20S<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat), and [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat).

**Arguments**
- `weights::AbstractMatrix{T}`: the weights of the portfolio.
  
- `rel_pr::AbstractMatrix{T}`: the relative price of the stocks.
  
- `rel_pr_market::AbstractVector{T}`: the relative price of the market.
  

**Keyword Arguments**
- `init_inv::T=1`: the initial investment.
  
- `Rf::T=0.02`: the risk-free rate of return.
  
- `dpy::S=252`: the number of days in a year.
  
- `v::T=0.`: the transaction cost rate.
  

::: warning Warning

The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

:::

::: tip Note

If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last `size(weights, 2)` columns of `rel_pr` will be used.

:::

**Returns**
- `::OPSMetrics`: An [`OPSMetrics`](/types#OnlinePortfolioSelection.OPSMetrics) object.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L313-L346" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.pamr-Tuple{AbstractMatrix, AbstractFloat, OnlinePortfolioSelection.PAMRModel}' href='#OnlinePortfolioSelection.pamr-Tuple{AbstractMatrix, AbstractFloat, OnlinePortfolioSelection.PAMRModel}'><span class="jlbinding">OnlinePortfolioSelection.pamr</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
pamr(rel_pr::AbstractMatrix, ϵ::AbstractFloat, C::AbstractFloat, model::PAMRModel)
```


Run the PAMR algorithm on the matrix of relative prices `rel_pr`.

**Arguments**
- `rel_pr::AbstractMatrix`: matrix of relative prices.
  
- `ϵ::AbstractFloat`: Sensitivity parameter.
  
- `C::AbstractFloat`: Aggressiveness parameter.
  
- `model::PAMRModel`: PAMR model to use. All three variants, namely, `PAMR()`, `PAMR1()`, and `PAMR2()` are supported.
  

::: warning Beware!

`rel_price` should be a matrix of size `n_assets` × `n_periods`.

:::

**Output**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "AMZN", "META", "GOOG"]

julia> startdt, enddt = "2019-01-01", "2020-01-01"

julia> querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers]

julia> prices = stack(querry) |> permutedims

julia> rel_pr =  prices[:, 2:end]./prices[:, 1:end-1]

julia> model = PAMR()

julia> eps = 0.01

julia> result = pamr(rel_pr, eps, model)

julia> result.b
5×251 Matrix{Float64}:
 0.2  0.224672  0.22704   0.230855  0.229743  …  0.0966823  0.0966057  0.0900667
 0.2  0.196884  0.197561  0.199825  0.203945     0.172787   0.171734   0.171626
 0.2  0.191777  0.190879  0.178504  0.178478     0.290126   0.289638   0.291135
 0.2  0.193456  0.193855  0.196363  0.189322     0.182514   0.181609   0.185527
 0.2  0.193211  0.190665  0.194453  0.198513     0.25789    0.260414   0.261645

julia> sum(result.b, dims=1) .|> isapprox(1.) |> all
true
```


In the same way, you can use `PAMR1()` and `PAMR2()`:

```julia
julia> model = PAMR1(C=0.02)

julia> eps = 0.01

julia> result = pamr(rel_pr, eps, model)

julia> result.b
5×251 Matrix{Float64}:
 0.2  0.200892  0.200978  0.201116  …  0.196264  0.19626   0.196257  0.19602
 0.2  0.199887  0.199912  0.199994     0.198835  0.199017  0.198979  0.198975
 0.2  0.199703  0.19967   0.199223     0.203659  0.203261  0.203243  0.203297
 0.2  0.199763  0.199778  0.199868     0.199246  0.199351  0.199319  0.19946
 0.2  0.199754  0.199662  0.199799     0.201997  0.20211   0.202202  0.202246

julia> model = PAMR2(C=1.)

julia> eps = 0.01

julia> result = pamr(rel_pr, eps, model)

julia> result.b
5×251 Matrix{Float64}:
 0.2  0.219093  0.220963  0.223948  …  0.119093  0.119013  0.118953  0.11385
 0.2  0.197589  0.198123  0.199895     0.175224  0.179199  0.178376  0.178291
 0.2  0.193636  0.192928  0.183242     0.279176  0.27052   0.270138  0.271307
 0.2  0.194936  0.19525   0.197214     0.183626  0.185922  0.185215  0.188272
 0.2  0.194746  0.192736  0.195701     0.242882  0.245346  0.247319  0.248279
```


**References**
> 
> [PAMR: Passive aggressive mean reversion strategy for portfolio selection](https://www.doi.org/10.1007/s10994-012-5281-z)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/PAMR.jl#L1-L84" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.ppt' href='#OnlinePortfolioSelection.ppt'><span class="jlbinding">OnlinePortfolioSelection.ppt</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
ppt(
  prices::AbstractMatrix,
  w::Int,
  ϵ::Int,
  horizon::Int,
  b̂ₜ::AbstractVector=ones(size(prices, 1))/size(prices, 1)
)
```


Run the Price Peak Tracking (PPT) algorithm.

**Arguments**
- `prices::AbstractMatrix`: Matrix of prices.
  
- `w::Int`: Window size.
  
- `ϵ::Int`: Constraint parameter.
  
- `horizon::Int`: Number of days to run the algorithm.
  
- `b̂ₜ::AbstractVector=ones(size(prices, 1))/size(prices, 1)`: Initial weights.
  

::: warning Beware!

`prices` should be a matrix of size `n_assets` × `n_periods`.

:::

**Output**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "AMZN", "GOOG", "MSFT"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2020-01-01")["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> model = ppt(prices, 10, 100, 100);

julia> sum(model, dims=1) .|> isapprox(1.) |> all
true
```


**References**
> 
> [A Peak Price Tracking-Based Learning System for Portfolio Selection](https://doi.org/10.1109/TNNLS.2017.2705658)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/PPT.jl#L1-L43" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.rmr-Tuple{AbstractMatrix, Integer, Integer, Any, Any, Any}' href='#OnlinePortfolioSelection.rmr-Tuple{AbstractMatrix, Integer, Integer, Any, Any, Any}'><span class="jlbinding">OnlinePortfolioSelection.rmr</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
rmr(p::AbstractMatrix, horizon::Integer, w::Integer, ϵ, m, τ)
```


Run Robust Median Reversion (RMR) algorithm.

**Arguments**
- `p::AbstractMatrix`: Prices matrix.
  
- `horizon::Integer`: Number of periods to run the algorithm.
  
- `w::Integer`: Window size.
  
- `ϵ`: Reversion threshold.
  
- `m`: Maxmimum number of iterations.
  
- `τ`: Toleration level.
  

**Returns**
- `OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["GOOG", "AAPL", "MSFT", "AMZN"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-31")["adjclose"] for ticker=tickers];

julia> prices = stack(querry, dims=1);

julia> horizon = 5

julia> window = 5

julia> ϵ = 5

julia> m = 7

julia> τ = 1e6

julia> model = rmr(prices, horizon, window, ϵ, m, τ);

julia> model.b
4×5 Matrix{Float64}:
 0.25  1.0         1.0       1.0         1.0
 0.25  0.0         0.0       0.0         0.0
 0.25  0.0         0.0       0.0         0.0
 0.25  1.14513e-8  9.979e-9  9.99353e-9  1.03254e-8
```


**Reference**
> 
> [Robust Median Reversion Strategy for Online Portfolio Selection](https://www.doi.org/10.1109/TKDE.2016.2563433)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/RMR.jl#L37-L85" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.rprt-Union{Tuple{T}, Tuple{AbstractMatrix{T}, Integer}, Tuple{AbstractMatrix{T}, Integer, Integer}, Tuple{AbstractMatrix{T}, Integer, Integer, T}, Tuple{AbstractMatrix{T}, Integer, Integer, T, Integer}, Tuple{AbstractMatrix{T}, Integer, Integer, T, Integer, Union{Nothing, AbstractVector}}} where T<:AbstractFloat' href='#OnlinePortfolioSelection.rprt-Union{Tuple{T}, Tuple{AbstractMatrix{T}, Integer}, Tuple{AbstractMatrix{T}, Integer, Integer}, Tuple{AbstractMatrix{T}, Integer, Integer, T}, Tuple{AbstractMatrix{T}, Integer, Integer, T, Integer}, Tuple{AbstractMatrix{T}, Integer, Integer, T, Integer, Union{Nothing, AbstractVector}}} where T<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.rprt</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
function rprt(
  rel_pr::AbstractMatrix{T},
  horizon::Integer,
  w::Integer=5,
  ϑ::T=0.8,
  𝜖::Integer=50,
  bₜ::Union{Nothing, AbstractVector}=nothing
) where T<:AbstractFloat
```


Run RPRT algorithm.

**Arguments**
- `rel_pr::AbstractMatrix{T}`: A `asset × samples` matrix of relative prices.
  
- `horizon::Integer`: Investment period.
  
- `w::Integer=5`: Window length.
  
- `ϑ::T=0.8`: Mixing parameter.
  
- `𝜖::Integer=50`: Expected profiting level.
  
- `bₜ::Union{Nothing, AbstractVector}=nothing`: Initial portfolio. Default value would lead to a uniform portfolio.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Examples**

```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(3, 6);
julia> horizon = 2
julia> window = 3
julia> v = 0.2
julia> eps = 10
julia> b = [0.5, 0.3, 0.2];

julia> m_rprt = rprt(rel_pr, horizon, window, v, eps, b);

julia> m_rprt.b
3×2 Matrix{Float64}:
 0.5  1.0
 0.3  0.0
 0.2  2.03615e-10

julia> sum(m_rprt.b, dims=1) .|> isapprox(1.) |> all
true
```


**Reference**
> 
> [Reweighted Price Relative Tracking System for Automatic Portfolio Optimization](https://ieeexplore.ieee.org/document/8411138/)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/RPRT.jl#L31-L82" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.sn-Union{Tuple{T}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}}} where T<:AbstractFloat' href='#OnlinePortfolioSelection.sn-Union{Tuple{T}, Tuple{AbstractMatrix{T}, AbstractMatrix{T}}} where T<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.sn</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
sn(weights::AbstractMatrix{T}, rel_pr::AbstractMatrix{T}; init_inv::T=1.) where T<:AbstractFloat
```


Calculate the cumulative wealth of the portfolio during a period of time. Also, see [`mer`](/funcs#OnlinePortfolioSelection.mer-Union{Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T}},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20T}}%20where%20T<:AbstractFloat), [`ann_std`](/funcs#OnlinePortfolioSelection.ann_std-Tuple{AbstractVector{<:AbstractFloat}}), [`apy`](/funcs#OnlinePortfolioSelection.apy-Union{Tuple{S},%20Tuple{AbstractFloat,%20S}}%20where%20S<:Int64), [`ann_sharpe`](/funcs#OnlinePortfolioSelection.ann_sharpe-Union{Tuple{T},%20Tuple{T,%20T,%20T}}%20where%20T<:AbstractFloat), [`mdd`](/funcs#OnlinePortfolioSelection.mdd-Union{Tuple{AbstractVector{T}},%20Tuple{T}}%20where%20T<:AbstractFloat), [`calmar`](/funcs#OnlinePortfolioSelection.calmar-Union{Tuple{T},%20Tuple{T,%20T}}%20where%20T<:AbstractFloat), and [`opsmetrics`](/funcs#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20AbstractVector{T}}}%20where%20{T<:AbstractFloat,%20S<:Int64}).

The formula for calculating the cumulative wealth of the portfolio is as follows:

$${S_n} = {S_0}\prod\limits_{t = 1}^T {\left\langle {{b_t},{x_t}} \right\rangle }$$

where $S_0$ is the initial budget, $n$ is the investment horizon, $b_t$ is the vector of weights of the period $t$, and $x_t$ is the relative price of the $t$-th period.

**Arguments**
- `weights::AbstractMatrix{T}`: the weights of the portfolio.
  
- `rel_pr::AbstractMatrix{T}`: the relative price of the stocks.
  

**Keyword Arguments**
- `init_inv::T=1`: the initial investment.
  

::: warning Beware!

The size of `weights` and `rel_pr` must be `(n_stocks, n_periods)`.

:::

::: tip Note

If `size(rel_pr, 2)` is greater than `size(weights, 2)`, then the last `size(weights, 2)` columns of `rel_pr` will be used.

:::

**Returns**
- `all_sn::Vector{T}`: the cumulative wealth of investment during the investment period.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/metrics.jl#L39-L67" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.spolc-Tuple{AbstractMatrix, AbstractFloat, Integer}' href='#OnlinePortfolioSelection.spolc-Tuple{AbstractMatrix, AbstractFloat, Integer}'><span class="jlbinding">OnlinePortfolioSelection.spolc</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
spolc(x::AbstractMatrix, 𝛾::AbstractFloat, w::Integer)
```


Run loss control strategy with a rank-one covariance estimate for short-term portfolio optimization (SPOLC).

**Arguments**
- `x::AbstractMatrix`: Matrix of relative prices.
  
- `𝛾::AbstractFloat`: Mixing parameter that trades off between the increasing factor and the risk.
  
- `w::Integer`: Window size.
  

::: warning Beware!

`x` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "AMZN", "GOOG", "MSFT"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2019-01-25")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1);

julia> rel_pr = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> model = spolc(rel_pr, 0.025, 5);

julia> model.b
4×15 Matrix{Float64}:
 0.25  0.197923  0.244427  0.239965  …  0.999975    8.49064e-6  2.41014e-6
 0.25  0.272289  0.251802  0.276544     1.57258e-5  0.999983    0.999992
 0.25  0.269046  0.255524  0.240024     6.50008e-6  5.94028e-6  3.69574e-6
 0.25  0.260742  0.248247  0.243466     2.99939e-6  3.04485e-6  1.56805e-6

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```


**Reference**
> 
> [Loss Control with Rank-one Covariance Estimate for Short-term Portfolio Optimization](https://dl.acm.org/doi/abs/10.5555/3455716.3455813)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/SPOLC.jl#L1-L44" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.sspo' href='#OnlinePortfolioSelection.sspo'><span class="jlbinding">OnlinePortfolioSelection.sspo</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
sspo(
  p::AbstractMatrix,
  horizon::Integer,
  w::Integer,
  b̂ₜ::Union{Nothing, AbstractVector}=nothing,
  η::AbstractFloat=0.005,
  γ::AbstractFloat=0.01,
  λ::AbstractFloat=0.5,
  ζ::Integer=500,
  ϵ::AbstractFloat=1e-4,
  max_iter=1e4
)
```


Run Short-term Sparse Portfolio Optimization (SSPO) algorithm.

**Arguments**
- `p::AbstractMatrix`: Prices of the assets.
  
- `horizon::Integer`: Number of investment periods.
  
- `w::Integer`: Window size.
  
- `b̂ₜ::Union{Nothing, AbstractVector}=nothing`: Initial portfolio weights. If `nothing` is passed, then a uniform portfolio will be selected for the first period.
  
- `η::AbstractFloat=0.005`: Learning rate.
  
- `γ::AbstractFloat=0.01`: Regularization parameter.
  
- `λ::AbstractFloat=0.5`: Regularization parameter.
  
- `ζ::Integer=500`: Regularization parameter.
  
- `ϵ::AbstractFloat=1e-4`: Tolerance for the convergence of the algorithm.
  
- `max_iter=1e4`: Maximum number of iterations.
  

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["GOOG", "AAPL", "MSFT", "AMZN"]

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-31")["adjclose"] for ticker=tickers]

julia> prices = stack(querry, dims=1)

julia> h = 5

julia> w = 5

julia> model = sspo(prices, h, w);

julia> model.b
4×5 Matrix{Float64}:
 0.25  9.92018e-9  1.0         1.0  1.0
 0.25  0.0         0.0         0.0  0.0
 0.25  0.0         0.0         0.0  0.0
 0.25  1.0         9.94367e-9  0.0  0.0
```


**Reference**
> 
> [Short-term Sparse Portfolio Optimization Based on Alternating Direction Method of Multipliers](http://jmlr.org/papers/v19/17-558.html)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/SSPO.jl#L26-L83" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.tco' href='#OnlinePortfolioSelection.tco'><span class="jlbinding">OnlinePortfolioSelection.tco</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
tco(
  x::AbstractMatrix,
  w::Integer,
  horizon::Integer,
  𝛾::AbstractFloat,
  η::Integer,
  variant::Type{<:TCOVariant},
  b̂ₜ::Union{Nothing, AbstractVector}=nothing
)
```


Run Transaction Cost Optimization (TCO) algorithm.

**Arguments**
- `x::AbstractMatrix`: Matrix of relative prices.
  
- `w::Integer`: Window size.
  
- `horizon::Integer`: Investment horizon.
  
- `𝛾`: Rate of transaction cost.
  
- `η::Integer`: Smoothing parameter.
  
- `variant::Type{<:TCOVariant}`: Variant of the algorithm. Both `TCO1` and `TCO2` are implemented.
  

**Optional argument**
- `b̂ₜ::Union{Nothing, AbstractVector}=nothing`: The first rebalanced portfolio. If `nothing` is passed, a uniform portfolio will be used.
  

::: warning Beware!

`x` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm).
  

**Example**

```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["MSFT", "TSLA", "GOOGL", "NVDA"];

julia> querry = [get_prices(ticker, startdt="2024-01-01", enddt="2024-03-01")["adjclose"] for ticker in tickers];

julia> pr = stack(querry, dims=1);

julia> r = pr[:, 2:end]./pr[:, 1:end-1];

# TCO1
julia> model = tco(r, 5, 5, 0.04, 10, TCO1, [0.05, 0.05, 0.7, 0.2]);

julia> model.b
4×5 Matrix{Float64}:
 0.05  0.05  0.052937  0.0540085  0.0537137
 0.05  0.05  0.073465  0.0783877  0.0781003
 0.7   0.7   0.669571  0.657286   0.66002
 0.2   0.2   0.204027  0.210318   0.208166

# TCO2
julia> model = tco(r, 5, 5, 0.04, 10, TCO2, [0.05, 0.05, 0.7, 0.2]);

julia> model.b
4×5 Matrix{Float64}:
 0.05  0.0809567  0.0850694  0.0871646  0.0865584
 0.05  0.0809567  0.0830907  0.0890398  0.0885799
 0.7   0.730957   0.756827   0.746137   0.748113
 0.2   0.10713    0.0750128  0.0776584  0.0767483
```


**Reference**
> 
> [Transaction cost optimization for online portfolio selection](https://www.tandfonline.com/doi/full/10.1080/14697688.2017.1357831)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/TCO.jl#L19-L84" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.tppt' href='#OnlinePortfolioSelection.tppt'><span class="jlbinding">OnlinePortfolioSelection.tppt</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
tppt(
  prices::AbstractMatrix,
  horizon::Integer,
  w::Integer,
  ϵ::Integer=100,
  α::AbstractFloat=0.5
)
```


Run Trend Promote Price Tracking (TPPT) algorithm.

**Arguments**
- `prices::AbstractMatrix`: Prices of the assets. Each column is a period and each row is an asset.
  
- `horizon::Integer`: The number of Investment periods.
  
- `w::Integer`: The window size.
  
- `ϵ::Integer`: Constraint parameter.
  
- `α::AbstractFloat`: Exponential moving average parameter.
  

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Example**

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


**References**
> 
> [An online portfolio strategy based on trend promote price tracing ensemble learning algorithm](https://doi.org/10.1016/j.knosys.2021.107957)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/TPPT.jl#L63-L107" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.ttest' href='#OnlinePortfolioSelection.ttest'><span class="jlbinding">OnlinePortfolioSelection.ttest</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
ttest(vec::AbstractVector{<:AbstractVector})
ttest(SB::AbstractVector, Sₜ::AbstractVector, SF::AbstractFloat)
```


**Method 1**

```julia
ttest(vec::AbstractVector{<:AbstractVector})
```


Perform a one sample t-test of the null hypothesis that `n` values with mean `x̄` and sample standard deviation stddev come from a distribution with mean $μ_0$ against the alternative hypothesis that the distribution does not have mean $μ_0$. The t-test with 95% confidence level applies on each pair of vectors in the `vec` vector. Each vector should contain the Annual Percentage Yield (APY) of a different algorithm on various datasets.

::: tip Note

You have to install and import the `HypothesisTests` package to use this function.

:::

**Arguments**
- `vec::AbstractVector{<:AbstractVector}`: A vector of vectors. Each inner vector should be of the same size.
  

**Returns**
- `::Matrix{<:AbstractFloat}`: A matrix of p-values for each pair of algorithms.
  

**Example**

```julia
julia> using OnlinePortfolioSelection, HypothesisTests

julia> apys = [
         [1, 2, 3, 4],
         [2, 7, 0, 1],
         [3, 0, 0, 5]
       ];

julia> ttest(apys)
3×3 Matrix{Float64}:
 0.0  1.0  0.702697
 0.0  0.0  0.843672
 0.0  0.0  0.0
```


**Method 2**

```julia
ttest(SB::AbstractVector, Sₜ::AbstractVector, SF::AbstractFloat)
```


Performs a t-student test to check whether the returns gained by a trading algorithm is due to a simple luck.

::: tip Note

You have to install and import the `GLM` package to use this function.

:::

**Arguments**
- `SB::AbstractVector`: Denotes the daily returns of the benchmark (market index)
  
- `Sₜ::AbstractVector`: Portfolio daily returns
  
- `SF::AbstractFloat`: Daily returns of the risk-free assets (Can be set to Treasury bill value or annual interest rate.)
  
- `::StatsModels.TableRegressionModel`: An object of type `TableRegressionModel` including the values of t-student test analysis.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Tools/tools.jl#L583-L638" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.uniform-Tuple{Int64, Int64}' href='#OnlinePortfolioSelection.uniform-Tuple{Int64, Int64}'><span class="jlbinding">OnlinePortfolioSelection.uniform</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
uniform(n_assets::Int, horizon::Int)
```


Construct uniform portfolios.

**Arguments**
- `n_assets::Int`: The number of assets.
  
- `horizon::Int`: The number of investment periods.
  

**Returns**
- `::OPSAlgorithm`: An object of [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) type.
  

**Example**

```julia
julia> using OnlinePortfolioSelection

julia> model = uniform(3, 10)

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/uniform.jl#L1-L22" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.up-Union{Tuple{AbstractMatrix{T}}, Tuple{T}} where T<:AbstractFloat' href='#OnlinePortfolioSelection.up-Union{Tuple{AbstractMatrix{T}}, Tuple{T}} where T<:AbstractFloat'><span class="jlbinding">OnlinePortfolioSelection.up</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
function up(
  rel_pr::AbstractMatrix{T};
  eval_points::Integer=10^4
) where T<:AbstractFloat
```


Universal Portfolio (UP) algorithm.

Calculate the Universal Portfolio (UP) weights and budgets using the given historical prices and parameters.

**Arguments**
- `rel_pr::AbstractMatrix{T}`: Historical relative prices.
  

**Keyword Arguments**
- `eval_points::Integer=10^4`: Number of evaluation points.
  

::: warning Beware!

`rel_pr` should be a matrix of size `n_assets` × `n_periods`.

:::

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

**Examples**

```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(3, 9);

julia> m_up = up(rel_pr);

julia> m_up.b
3×9 Matrix{Float64}:
 0.333333  0.272709  0.345846  0.385378  0.308659  0.328867  0.280564  0.349619  0.433529
 0.333333  0.288016  0.315603  0.249962  0.252828  0.24165   0.270741  0.2621    0.235743
 0.333333  0.439276  0.338551  0.364661  0.438512  0.429483  0.448695  0.388281  0.330729

julia> sum(m_up.b, dims=1) .|> isapprox(1.) |> all
true
```


**References**
> 
> [Universal Portfolios](https://doi.org/10.1111/j.1467-9965.1991.tb00002.x)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/UP.jl#L1-L44" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.waeg-Tuple{AbstractMatrix, AbstractFloat, AbstractFloat, Integer}' href='#OnlinePortfolioSelection.waeg-Tuple{AbstractMatrix, AbstractFloat, AbstractFloat, Integer}'><span class="jlbinding">OnlinePortfolioSelection.waeg</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
waeg(x::AbstractMatrix, ηₘᵢₙ::AbstractFloat, ηₘₐₓ::AbstractFloat, k::Integer)
```


Run Weak Aggregating Exponential Gradient (WAEG) algorithm.

**Arguments**
- `x::AbstractMatrix`: matrix of relative prices.
  
- `ηₘᵢₙ::AbstractFloat`: minimum learning rate.
  
- `ηₘₐₓ::AbstractFloat`: maximum learning rate.
  
- `k::Integer`: number of EG experts.
  

**Returns**
- `::OPSAlgorithm`: An [`OPSAlgorithm`](/types#OnlinePortfolioSelection.OPSAlgorithm) object.
  

::: warning Beware!

`x` should be a matrix of size `n_assets` × `n_periods`.

:::

**Example**

```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(4, 8);

julia> m = waeg(rel_pr, 0.01, 0.2, 20);

julia> m.b
4×8 Matrix{Float64}:
 0.25  0.238126  0.24158   0.2619    0.261729  0.27466   0.25148   0.256611
 0.25  0.261957  0.259588  0.248465  0.228691  0.24469   0.256674  0.246801
 0.25  0.245549  0.247592  0.254579  0.27397   0.259982  0.272341  0.290651
 0.25  0.254368  0.25124   0.235057  0.23561   0.220668  0.219505  0.205937

julia> sum(m.b, dims=1) .|> isapprox(1.) |> all
true
```


**References**
> 
> [Boosting Exponential Gradient Strategy for Online Portfolio Selection: An Aggregating Experts’ Advice Method](https://doi.org/10.1007/s10614-019-09890-2)
> 



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Algos/WAEG.jl#L25-L63" target="_blank" rel="noreferrer">source</a></Badge>

</details>

