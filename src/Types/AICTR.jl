abstract type TrendRep end

"""
    SMAP<:TrendRep

Simple Moving Average trend representation **using the close prices**. Formula:

```math
\\mathbf{\\hat{x}}_{S, t+1}\\left(w\\right)= \\frac{\\sum_{k=0}^{w-1}\\mathbf{p}_{t-k}}{w\\mathbf{p}_t}
```

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> sma = SMAP()
SMA()
```
"""
struct SMAP<:TrendRep end

"""
SMAR<:TrendRep

Simple Moving Average trend representation **using the relative prices**. Formula:

```math
{\\mathbf{1}} + \\frac{{\\mathbf{1}}}{{{{\\mathbf{x}}_t}}} +  \\cdots  + \\frac{{\\mathbf{1}}}{{ \\otimes _{k = 0}^{w - 2}{{\\mathbf{x}}_{t - k}}}}
```

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> sma = SMAR()
SMAR()
```
"""
struct SMAR<:TrendRep end

"""
    EMA{T<:AbstractFloat}<:TrendRep

Exponential Moving Average trend representation. Formula:

```math
{{\\mathbf{\\hat x}}_{E,t + 1}}\\left( \\vartheta  \\right) = \\frac{{\\sum\\limits_{k = 0}^{t - 1} {{{\\left( {1 - \\vartheta } \\right)}^k}} \\vartheta {{\\mathbf{p}}_{t - k}} + {{\\left( {1 - \\vartheta } \\right)}^t}{{\\mathbf{p}}_0}}}{{{{\\mathbf{p}}_t}}}
```

# Fields
- `v::T`: Smoothing factor.

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> ema = EMA(0.5)
EMA{Float64}(0.5)
```
"""
struct EMA{T<:AbstractFloat}<:TrendRep
  v::T
end

"""
    PP<:TrendRep

Pick Price trend representation. Formula:

```math
{{\\mathbf{\\hat x}}_{M,t + 1}}\\left( w \\right) = \\frac{{\\mathop {\\max }\\limits_{0 \\leqslant k \\leqslant w - 1} {\\mathbf{p}}_{t - k}^{(i)}}}{{{{\\mathbf{p}}_t}}},\\quad i = 1,2, \\ldots ,d
```

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> pp = PP()
PP()
```
"""
struct PP<:TrendRep end
