"""
    pred_relpr(::SMAP, prices::AbstractMatrix, w::Integer)
    pred_relpr(::SMAR, prices::AbstractMatrix, w::Integer)
    pred_relpr(model::EMA, prices::AbstractMatrix)
    pred_relpr(::PP, prices::AbstractMatrix, w::Integer)

# Method 1
Predict the price relative to the last `w` days using the Simple Moving Average (SMA) by \
employing close prices. This is equivalent to: \
``\\mathbf{\\hat{x}}_{S, t+1}\\left(w\\right)=frac{\\sum_{k=0}^{w-1}\\mathbf{p}_{t-k}}{w\\mathbf{p}_t}``.

## Arguments
- `::SMAP`: [`SMAP`](@ref) object.
- `prices::AbstractMatrix`: matrix of prices.
- `w::Integer`: window size.

!!! warning "Beware"
    `prices` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `::Vector{<:AbstractFloat}`: Predicted price relative vector of size `n_assets`.

## Example
```julia
julia> using OnlinePortfolioSelection

julia> prices = rand(3, 7)
3×7 Matrix{Float64}:
 0.239096  0.2753    0.139975  0.950548  0.825106  0.17642   0.718449
 0.906723  0.135535  0.760641  0.677338  0.591781  0.867636  0.422376
 0.273307  0.152385  0.638585  0.890082  0.11859   0.784191  0.648333

julia> pred_relpr(SMAP(), prices, 3)
3-element Vector{Float64}:
 0.7980035595621227
 1.485084060218173
 0.7974884049616359
```

# Method 2
Predict the price relative to the last `w` days using the Simple Moving Average (SMA) by \
employing close prices. This is equivalent to: \
``{\\mathbf{1}} + \\frac{{\\mathbf{1}}}{{{{\\mathbf{x}}_t}}} +  \\cdots  + \\frac{{\\mathbf{1}}}{{ \\otimes _{k = 0}^{w - 2}{{\\mathbf{x}}_{t - k}}}}``.

## Arguments
- `::SMAP`: [`SMAR`](@ref) object.
- `rel_pr::AbstractMatrix`: matrix of relative prices.
- `w::Integer`: window size.

!!! warning "Beware"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `::Vector{<:AbstractFloat}`: Predicted price relative vector of size `n_assets`.

## Example
```julia
julia> using OnlinePortfolioSelection

julia> prices = rand(3, 7)
3×7 Matrix{Float64}:
 0.239096  0.2753    0.139975  0.950548  0.825106  0.17642   0.718449
 0.906723  0.135535  0.760641  0.677338  0.591781  0.867636  0.422376
 0.273307  0.152385  0.638585  0.890082  0.11859   0.784191  0.648333

julia> pred_relpr(SMAR(), prices, 3)
3-element Vector{Float64}:
 484.8715760533429
  55.10844520483984
 320.3429376365369
```

# Method 3
Predict the price relative to the last `w` days using the Exponential Moving Average (EMA). \
This is equivalent to: ``{{\\mathbf{\\hat x}}_{E,t + 1}}\\left( \\vartheta  \\right) = \\frac{{\\sum\\limits_{k = 0}^{t - 1} {{{\\left( {1 - \\vartheta } \\right)}^k}} \\vartheta {{\\mathbf{p}}_{t - k}} + {{\\left( {1 - \\vartheta } \\right)}^t}{{\\mathbf{p}}_0}}}{{{{\\mathbf{p}}_t}}}``.

## Arguments
- `model::EMA`: [`EMA`](@ref) object.
- `prices::AbstractMatrix`: matrix of prices.

!!! warning "Beware"
    `prices` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `::Vector{<:AbstractFloat}`: Predicted price relative vector of size `n_assets`.

## Example
```julia
julia> using OnlinePortfolioSelection

julia> prices = rand(3, 7)
3×7 Matrix{Float64}:
 0.537567  0.993001  0.472032  0.17579   0.229753   0.869963  0.258598
 0.65217   0.275331  0.948194  0.655232  0.775169   0.319057  0.155682
 0.659132  0.544562  0.220759  0.115822  0.0839703  0.479326  0.84241

julia> pred_relpr(EMA(0.5), prices)
3-element Vector{Float64}:
 0.8220523618098609
 1.0906091418069135
 0.3469083043928794
```

# Method 4
Predict the price relative to the last `w` days using the Price Prediction (PP). This is \
equivalent to: ``{{\\mathbf{\\hat x}}_{M,t + 1}}\\left( w \\right) = \\frac{{\\mathop {\\max }\\limits_{0 \\leqslant k \\leqslant w - 1} {\\mathbf{p}}_{t - k}^{(i)}}}{{{{\\mathbf{p}}_t}}},\\quad i = 1,2, \\ldots ,d``.

## Arguments
- `model::PP`: [`PP`](@ref) object.
- `prices::AbstractMatrix`: Matrix of prices.
- `w::Integer`: window size.

!!! warning "Beware"
    `prices` should be a matrix of size `n_assets` × `n_periods`.

## Returns
- `::Vector{<:AbstractFloat}`: Predicted price relative vector of size `n_assets`.

## Example
```julia
julia> using OnlinePortfolioSelection

julia> prices = rand(3, 7)
3×7 Matrix{Float64}:
 0.787617  0.956869  0.633786  0.941729  0.474008  0.365784  0.711252
 0.814631  0.174881  0.256391  0.321552  0.40781   0.289347  0.498401
 0.776178  0.385725  0.508909  0.1728    0.37207   0.392623  0.280829

julia> pred_relpr(PP(), prices, 3)
3-element Vector{Float64}:
 1.0
 1.0
 1.3980826646284876
"""
function pred_relpr(::SMAP, prices::AbstractMatrix, w::Integer)
  return sum(prices[:, end-w+1:end], dims=2) ./ (w*prices[:, end]) |> vec
end

function pred_relpr(::SMAR, rel_pr::AbstractMatrix, w::Integer)
  T          = eltype(rel_pr)
  n_assets   = size(rel_pr, 1)
  reversed_rp= @view rel_pr[:, end:-1:end-w+2]
  term = [ones(T, n_assets) 1 ./ cumprod(reversed_rp, dims=2)]
  return 1/w * cumsum(term, dims=2)[:, end]
end

function pred_relpr(model::EMA, prices::AbstractMatrix, _::Integer)
  n_assets, t = size(prices)
  ϑ           = model.v
  x̂           = zeros(eltype(prices), n_assets)
  for k ∈ 1:t-1
    x̂ += (1-ϑ)^k * ϑ * prices[:, end-k+1]
  end
  x̂ += (1-ϑ)^t * prices[:, 1]
  return x̂./prices[:, end]
end

function pred_relpr(::PP, prices::AbstractMatrix, w::Integer)
  return maximum(prices[:, end-w+1:end], dims=2)./prices[:, end] |> vec
end

"""
    simplex(d::S, points::S) where {S<:Int}

Generate a simplex with the size of `points` × (`d`+1).

# Arguments
- `d::Int`: The dimension of the simplex.
- `points::Int`: The number of points in the simplex.

# Returns
- `::Matrix{Float64}`: The simplex.

# Example
```julia
julia> res = simplex(2, 1)
1×3 Matrix{Float64}:
 0.14692  0.00824556  0.844835

julia> sum(res, dims=2)
1×1 Matrix{Float64}:
 1.0
```
"""
function simplex(d::S, points::S)::Matrix{Float64} where {S<:Int}
  a = sort(rand(points, d), dims=2)
  a = [zeros(points) a ones(points)]
  return diff(a, dims=2)
end

"""
    normalizer!(mat::Matrix{T}) where T<:Float64

Force normilize the given matrix column by column.

# Arguments
- `mat::Matrix{T}`: The matrix that is going to be normalized.

# Returns
- `::Nothing`: The matrix is normalized in place.

# Example
```julia
julia> mat = rand(3, 3);

julia> normalizer!(mat)

julia> sum(mat, dims=1) .|> isapprox(1.0) |> all
true
```
"""
function normalizer!(mat::AbstractMatrix{T}) where T<:Float64
  @inbounds @simd for idx_col ∈ axes(mat, 2)
    @views normalizer!(mat[:, idx_col])
  end
end

function normalizer!(mat::AbstractMatrix{T}, idx_col::S) where {T<:Float64, S<:Int}
  normalizer!(@views mat[:, idx_col])
end

"""
    normalizer!(vec::AbstractVector)::Vector{Float64}

Force normilize the given vector.

This function is used to normalize the weights of assets in situations where the sum of \
the weights is not exactly 1. (in some situation the sum of the weights is 0.999999999 or \
1.000000001 due to inexactness of Ipopt solver)

# Arguments
- `vec::Vector{Float64}`: The vector that is going to be normalized.

# Returns
- `::Nothing`: The vector is normalized in place.

# methods

"""
normalizer!(vec::AbstractVector)::Vector{Float64} = vec ./= sum(vec)

"""
    S(prev_s, w::T, rel_pr::T) where {T<:Vector{Float64}}

Calculate the budget of the current period.

# Arguments
- `prev_s::Float64`: Budget of the previous period.
- `w::Vector{Float64}`: Weights of assets.
- `rel_pr::Vector{Float64}`: Relative prices of assets in the current period.

# Returns
- `Float64`: Budget of the current period.
"""
S(prev_s, w::T, rel_pr::T) where {T<:Vector{Float64}} = prev_s*sum(w.*rel_pr)

"""
    rolling(f::Function, m::Matrix{T}, window::Int)

Rolling window function. Applies `f` to each window of `m` of size `window`.

!!! warning "Beware!"
    Keep in mind that `m` is a matrix, in which each column represents an asset
    and each row represents a sample. Therefore, the window is applied to each
    asset.

# Arguments
- `f::Function`: function to apply to each window for each asset (Applies on a Vector{T})
- `m::Matrix{T}`: matrix to apply the rolling window to
- `window::Int`: size of the window

# Returns
- `res::Matrix{T}`: matrix of the results of applying `f` to each window for each asset

# Example
```julia
julia> test = [
       1. 2. 3.
       4. 5. 6.
       7. 8. 9.
       10. 11. 12.
      ];

julia> rolling(mean, test, 3)
2×3 Matrix{Float64}:
 4.0  5.0  6.0
 7.0  8.0  9.0
```
"""
function rolling(f::Function, m::Matrix{T}, window::Int) where T
  n, k = size(m)
  n-window ≥ 0 || ArgumentError("Window size is too large. Decrease it. \
    Also, you can leave `window` value as is, and instead increase the number of samples."
  ) |> throw
  res  = Matrix{T}(undef, n-window+1, k)
  @inbounds @simd for idx_col ∈ 1:k
    for idx_row ∈ 1:n-window+1
      res[idx_row, idx_col] = f(m[idx_row:idx_row+window-1, idx_col])
    end
  end

  return res
end;

function rolling(f::Function, v::Vector{T}, window::Int) where T
  n   = length(v)
  res = Vector{T}(undef, n-window+1)
  @inbounds @simd for idx ∈ 1:n-window+1
    res[idx] = f(v[idx:idx+window-1])
  end

  return res
end;

"""
    shift(m::AbstractMatrix, window::Int)

Shifts `m` (a matrix) by `window` rows.

!!! warning "Beware!"
    Keep in mind that `m` is a matrix, in which each column represents an asset
    and each row represents a sample. Therefore, the window is applied to each
    asset.

# Arguments
- `m::AbstractMatrix`: matrix to shift
- `window::Int`: number of rows to shift

# Example
```julia
julia> test = [
       1. 2. 3.
       4. 5. 6.
       7. 8. 9.
       10. 11. 12.
      ];

julia> shift(test, 2)
2×3 Matrix{Float64}:
 1.0  2.0  3.0
 4.0  5.0  6.0
```
"""
shift(m::AbstractMatrix, window::Int) = m[1:end-window, :]

"""
    shift(v::AbstractVector, window::Int)

Shifts `v` (a vector) by `window` rows.

# Arguments
- `v::AbstractVector`: vector to shift
- `window::Int`: number of elements to shift

# Returns
- `v_shifted::Vector`: shifted vector

# Example
```julia
julia> test = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

julia> shift(test, 2)
8-element Vector{Int64}:
  1
  2
  3
  4
  5
  6
  7
  8
```
"""
shift(v::AbstractVector, window::Int) = v[1:end-window]

"""
    shift(f::Function, window::Int, v::Vararg{AbstractVector, N}) where N

Shifts each vector in `v` by `window` number of elements and applies `f` to the \
shifted vectors.

# Arguments
- `f::Function`: function to apply to each shifted vector
- `window::Int`: number of elements to shift
- `v::Vararg{AbstractVector, N}`: vectors to shift and broadcast `f` to

# Returns
- `::Vector`: result of broadcasting the `f` function to the shifted vectors

# Example
```julia
julia> test1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

julia> test2 = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];

julia> shift(*, 2, test1, test2)
8-element Vector{Int64}:
 10
 18
 24
 28
 30
 30
 28
 24
```
"""
function shift(f::Function, window::Int, v::Vararg{AbstractVector, N}) where N
  isequal(length.(v)...) || DimensionMismatch("All vectors must have the same length \
    The lengths are:\n$(length.(v))
  ") |> throw
  v = shift.(v, window)
  return broadcast(f, v...)
end

"""
    rcorrelation(m1::AbstractMatrix, m2::AbstractMatrix, window::Int)

Calculate the rolling correlation between `m1` and `m2` with a window of size `window`.

!!! warning "Beware!"
    Keep in mind that `m1` and `m2` are matrices, in which each column represents an asset
    and each row represents a sample. Therefore, the window is applied to each
    asset.

# Arguments
- `m1::AbstractMatrix`: first matrix to calculate the rolling correlation
- `m2::AbstractMatrix`: second matrix to calculate the rolling correlation
- `window::Int`: size of the window

# Returns
- `rcor::Array{Float64, 3}`: rolling correlation matrix
"""
function rcorrelation(m1::AbstractMatrix, m2::AbstractMatrix, window::Int)
  s_m1, s_m2        = size(m1), size(m2)
  nperiods, nassets = s_m1
  m₁, m₂            = rolling.(mean, [m1, m2], window)
  m₁², m₂²          = rolling.(mean, [m1.^2, m2.^2], window)
  rcor              = Array{Float64, 3}(undef, nassets, nassets, nperiods-(2*window)+1)
  idx               = s_m1[1]-s_m2[1]+1

  for idx_assetᵢ ∈ 1:nassets
    for idx_assetⱼ ∈ 1:nassets
      xx            = m₁²[:, idx_assetᵢ] .- m₁[:, idx_assetᵢ].^2
      yy            = m₂²[:, idx_assetⱼ] .- m₂[:, idx_assetⱼ].^2
      xy            = m1[idx:end, idx_assetᵢ] .* m2[:, idx_assetⱼ]
      numerator_    = rolling(mean, xy, window) .- m₁[idx:end, idx_assetᵢ].*m₂[:, idx_assetⱼ]
      denominator_  = sqrt.(xx[idx:end].*yy)
      rcor[idx_assetᵢ, idx_assetⱼ, :] = numerator_ ./ denominator_
    end
  end

  return rcor, m₁[idx:end, :]
end

function bAdjusted(wₜ, relprₜ)
  return (wₜ .* relprₜ)/sum(wₜ .* relprₜ)
end

function progressbar(io, ntimes::S, current::S) where S<:Int
  val = current/ntimes
  val_rounded = round(S, val*10)
  bars = "████" ^ val_rounded
  remainder = "    " ^ (10 - val_rounded)
  joined = bars*remainder
  percentage = round(val*100, digits=2)
  printstyled(io, "┣$(joined)┫ $percentage% |$current/$ntimes \r")
end

function Δfunc(a::T, b::T, c::T) where T<:AbstractFloat
  Δ = b^2-4*a*c
  if iszero(Δ)
    γ = -b/(2a)
    return max(0., γ)
  elseif Δ > 0
    γₜ₁ = (-b+sqrt(Δ))/(2a)
    γₜ₂ = (-b-sqrt(Δ))/(2a)
    return max(0., γₜ₁, γₜ₂)
  else
    return 0.
  end
end

"""
    positify(x::AbstractVecOrMat)
    positify!(x::AbstractVecOrMat)

# Method 1

```julia
positify(x::AbstractVecOrMat)
```
Maintain the positive elements of `x` and set the negative elements to 0.

# Arguments
- `x::VecOrMat`: A vector or matrix.

# Returns
- `::VecOrMat`: A vector or matrix with positive elements.

# Example
```julia
julia> x = [-1, 2, -3, 4];

julia> positify(x)
4-element Vector{Int64}:
 0
 2
 0
 4

julia> x = [-1.1 2.2 -3.3 4.4; 5.5 -6.6 7.7 -8.8]
2×4 Matrix{Float64}:
 -1.1   2.2  -3.3   4.4
  5.5  -6.6   7.7  -8.8

julia> positify(x)
2×4 Matrix{Float64}:
 0.0  2.2  0.0  4.4
 5.5  0.0  7.7  0.0
```

# Method 2

```julia
positify!(x::AbstractVecOrMat)
```

Modifies `x` in place by maintaining the positive elements and setting the negative \
elements to 0.

# Example
```julia
julia> x = [-1, 2, -3, 4];

julia> positify!(x)
4-element Vector{Int64}:
 0
 2
 0
 4

julia> x
4-element Vector{Int64}:
 0
 2
 0
 4
```

As can bee seen, the `x` got modified inplace.
"""
positify(x::AbstractVecOrMat) = max.(x, 0)
positify!(x::AbstractVecOrMat) = x .= max.(x, 0)

# COV_EXCL_START
function __LogVecOrMat__(mat, filename="output")
  open("C:/Users/Shayan/Desktop/$filename.txt", "a+") do io
    show(io, "text/plain", mat)
  end
end
# COV_EXCL_STOP

"""
    ttest(vec::AbstractVector{<:AbstractVector})
    ttest(SB::AbstractVector, Sₜ::AbstractVector, SF::AbstractFloat)

# Method 1

```julia
ttest(vec::AbstractVector{<:AbstractVector})
```

Perform a one sample t-test of the null hypothesis that `n` values with mean `x̄` and sample \
standard deviation stddev come from a distribution with mean ``μ\\_0`` against the alternative \
hypothesis that the distribution does not have mean ``μ\\_0``. The t-test with 95% confidence \
level applies on each pair of vectors in the `vec` vector. Each vector should contain the \
Annual Percentage Yield (APY) of a different algorithm on various datasets.

!!! note
    You have to install and import the `HypothesisTests` package to use this function.

## Arguments
- `vec::AbstractVector{<:AbstractVector}`: A vector of vectors. Each inner vector should be \
of the same size.

## Returns
- `::Matrix{<:AbstractFloat}`: A matrix of p-values for each pair of algorithms.

## Example
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

# Method 2

```julia
ttest(SB::AbstractVector, Sₜ::AbstractVector, SF::AbstractFloat)
```

Performs a t-student test to check whether the returns gained by a trading algorithm is due \
to a simple luck.

!!! note
    You have to install and import the `GLM` package to use this function.

## Arguments
- `SB::AbstractVector`: Denotes the daily returns of the benchmark (market index)
- `Sₜ::AbstractVector`: Portfolio daily returns
- `SF::AbstractFloat`: Daily returns of the risk-free assets (Can be set to Treasury bill \
  value or annual interest rate.)

- `::StatsModels.TableRegressionModel`: An object of type `TableRegressionModel` including \
  the values of t-student test analysis.
"""
function ttest end
