
# Types {#Types}
<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.EGA' href='#OnlinePortfolioSelection.EGA'><span class="jlbinding">OnlinePortfolioSelection.EGA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
EGA{T<:AbstractFloat}<:EGMFramework
```


EGA variant of the EGM algorithm.

**Fields**
- `gamma1::T`: momentum parameter
  
- `gamma2::T`: momentum parameter
  

**Example**

```julia
julia> model = EGA(0.99, 0.)
EGA{Float64}(0.99, 0.0)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/EGM.jl#L39-L53" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.EGE' href='#OnlinePortfolioSelection.EGE'><span class="jlbinding">OnlinePortfolioSelection.EGE</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
EGE{T<:AbstractFloat}<:EGMFramework
```


EGE variant of the EGM algorithm.

**Fields**
- `gamma1::T`: momentum parameter
  

**Example**

```julia
julia> model = EGE(0.99)
EGE{Float64}(0.99)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/EGM.jl#L3-L16" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.EGR' href='#OnlinePortfolioSelection.EGR'><span class="jlbinding">OnlinePortfolioSelection.EGR</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
EGR{T<:AbstractFloat}<:EGMFramework
```


EGR variant of the EGM algorithm.

**Fields**
- `gamma2::T`: momentum parameter
  

**Example**

```julia
julia> model = EGR(0.)
EGR{Float64}(0.0)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/EGM.jl#L21-L34" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.EMA' href='#OnlinePortfolioSelection.EMA'><span class="jlbinding">OnlinePortfolioSelection.EMA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
EMA{T<:AbstractFloat}<:TrendRep
```


Exponential Moving Average trend representation. Formula:

$${{\mathbf{\hat x}}_{E,t + 1}}\left( \vartheta  \right) = \frac{{\sum\limits_{k = 0}^{t - 1} {{{\left( {1 - \vartheta } \right)}^k}} \vartheta {{\mathbf{p}}_{t - k}} + {{\left( {1 - \vartheta } \right)}^t}{{\mathbf{p}}_0}}}{{{{\mathbf{p}}_t}}}$$

**Fields**
- `v::T`: Smoothing factor.
  

**Examples**

```julia
julia> using OnlinePortfolioSelection

julia> ema = EMA(0.5)
EMA{Float64}(0.5)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/AICTR.jl#L41-L60" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.KMDLOG' href='#OnlinePortfolioSelection.KMDLOG'><span class="jlbinding">OnlinePortfolioSelection.KMDLOG</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
KMDLOG<:ClusLogVariant
```


`KMDLOG` is a concrete type used to represent the KMDLOG Model. Also, see [`KMNLOG`](/types#OnlinePortfolioSelection.KMNLOG).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/Clustering.jl#L10-L14" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.KMNLOG' href='#OnlinePortfolioSelection.KMNLOG'><span class="jlbinding">OnlinePortfolioSelection.KMNLOG</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
KMNLOG<:ClusLogVariant
```


`KMNLOG` is a concrete type used to represent the KMNLOG Model. Also, see [`KMDLOG`](/types#OnlinePortfolioSelection.KMDLOG).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/Clustering.jl#L3-L7" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.OPSAlgorithm' href='#OnlinePortfolioSelection.OPSAlgorithm'><span class="jlbinding">OnlinePortfolioSelection.OPSAlgorithm</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
OPSAlgorithm{T<:AbstractFloat}
```


An object that contains the result of running the algorithm.

**Fields**
- `n_asset::Int`: Number of assets in the portfolio.
  
- `b::Matrix{T}`: Weights of the created portfolios.
  
- `alg::String`: Name of the algorithm.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/Algorithms.jl#L1-L10" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.OPSMetrics' href='#OnlinePortfolioSelection.OPSMetrics'><span class="jlbinding">OnlinePortfolioSelection.OPSMetrics</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
OPSMetrics{T<:AbstractFloat}
```


A struct to store the metrics of the OPS algorithm. This object is returned by the [`opsmetrics`](/funcs#OnlinePortfolioSelection.opsmetrics-Union{Tuple{S},%20Tuple{T},%20Tuple{AbstractMatrix{T},%20AbstractMatrix{T},%20AbstractVector{T}}}%20where%20{T<:AbstractFloat,%20S<:Int64}) function.

**Fields**
- `Sn::Vector{T}`: The cumulative wealth of investment during the investment period.
  
- `MER::T`: The investments&#39;s Mean excess return (MER).
  
- `IR::T`: The Information Ratio (IR) of portfolio for the investment period.
  
- `APY::T`: The Annual Percentage Yield (APY) of investment.
  
- `Ann_Std::T`: The Annualized Standard Deviation (σₚ) of investment.
  
- `Ann_Sharpe::T`: The Annualized Sharpe Ratio (SR) of investment.
  
- `MDD::T`: The Maximum Drawdown (MDD) of investment.
  
- `Calmar::T`: The Calmar Ratio of investment.
  
- `AT::T`: The Average Turnover (AT) of the investment.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/Metrics.jl#L1-L16" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.PAMR' href='#OnlinePortfolioSelection.PAMR'><span class="jlbinding">OnlinePortfolioSelection.PAMR</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
PAMR<: PAMRModel
```


Create a PAMR object. Also, see [`PAMR1`](/types#OnlinePortfolioSelection.PAMR1), and [`PAMR2`](/types#OnlinePortfolioSelection.PAMR2).

**Example**

```julia
model = PAMR()
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/PAMR.jl#L3-L12" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.PAMR1' href='#OnlinePortfolioSelection.PAMR1'><span class="jlbinding">OnlinePortfolioSelection.PAMR1</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
PAMR1{T<:AbstractFloat}<: PAMRModel
```


Create a PAMR1 object. Also, see [`PAMR`](/types#OnlinePortfolioSelection.PAMR), and [`PAMR2`](/types#OnlinePortfolioSelection.PAMR2).

**Keyword Arguments**
- `C::AbstractFloat=1.`: Aggressiveness parameter.
  

**Example**

```julia
model = PAMR1(C=0.02)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/PAMR.jl#L15-L27" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.PAMR2' href='#OnlinePortfolioSelection.PAMR2'><span class="jlbinding">OnlinePortfolioSelection.PAMR2</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
PAMR2{T<:AbstractFloat}<: PAMRModel
```


Create a PAMR2 object. Also, see [`PAMR`](/types#OnlinePortfolioSelection.PAMR), and [`PAMR1`](/types#OnlinePortfolioSelection.PAMR1).

**Keyword Arguments**
- `C::AbstractFloat=1.`: Aggressiveness parameter.
  

**Example**

```julia
model = PAMR2(C=0.02)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/PAMR.jl#L32-L44" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.PP' href='#OnlinePortfolioSelection.PP'><span class="jlbinding">OnlinePortfolioSelection.PP</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
PP<:TrendRep
```


Pick Price trend representation. Formula:

$${{\mathbf{\hat x}}_{M,t + 1}}\left( w \right) = \frac{{\mathop {\max }\limits_{0 \leqslant k \leqslant w - 1} {\mathbf{p}}_{t - k}^{(i)}}}{{{{\mathbf{p}}_t}}},\quad i = 1,2, \ldots ,d$$

**Examples**

```julia
julia> using OnlinePortfolioSelection

julia> pp = PP()
PP()
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/AICTR.jl#L65-L81" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.SMAP' href='#OnlinePortfolioSelection.SMAP'><span class="jlbinding">OnlinePortfolioSelection.SMAP</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
SMAP<:TrendRep
```


Simple Moving Average trend representation **using the close prices**. Formula:

$$\mathbf{\hat{x}}_{S, t+1}\left(w\right)= \frac{\sum_{k=0}^{w-1}\mathbf{p}_{t-k}}{w\mathbf{p}_t}$$

**Examples**

```julia
julia> using OnlinePortfolioSelection

julia> sma = SMAP()
SMA()
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/AICTR.jl#L3-L19" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='OnlinePortfolioSelection.SMAR' href='#OnlinePortfolioSelection.SMAR'><span class="jlbinding">OnlinePortfolioSelection.SMAR</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



SMAR&lt;:TrendRep

Simple Moving Average trend representation **using the relative prices**. Formula:

$${\mathbf{1}} + \frac{{\mathbf{1}}}{{{{\mathbf{x}}_t}}} +  \cdots  + \frac{{\mathbf{1}}}{{ \otimes _{k = 0}^{w - 2}{{\mathbf{x}}_{t - k}}}}$$

**Examples**

```julia
julia> using OnlinePortfolioSelection

julia> sma = SMAR()
SMAR()
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/4292bacd11a45ba9c2a4deada9719ded463fe2bc/src/Types/AICTR.jl#L22-L38" target="_blank" rel="noreferrer">source</a></Badge>

</details>

