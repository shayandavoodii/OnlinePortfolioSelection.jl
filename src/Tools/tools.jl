function simplex_proj(b::Vector{Float64})
  n_assets = length(b)
  cond     = false
  sorted_b = sort(b, rev=true)
  tmpsum   = 0.
  for idx_assetᵢ ∈ 1:n_assets-1
    tmpsum += sorted_b[idx_assetᵢ]
    tmax    = (tmpsum - 1.)/idx_assetᵢ
    if tmax≥sorted_b[idx_assetᵢ+1]
      cond = true
      break
    end
  end

  if !cond
    tmax = (tmpsum + sorted_b[n_assets-1] - 1.)/n_assets
  end

  return max.(b .- tmax, 0.)
end

"""
    mc_simplex(d::S, points::S) where {S<:Int}

Generate a simplex with the size of `points` × (`d`+1).

# Arguments
- `d::Int`: The dimension of the simplex.
- `points::Int`: The number of points in the simplex.

# Returns
- `::Matrix{Float64}`: The simplex.

# Example
```julia
julia> res = mc_simplex(2, 1)
1×3 Matrix{Float64}:
 0.14692  0.00824556  0.844835

julia> sum(res, dims=2)
1×1 Matrix{Float64}:
 1.0
```
"""
function mc_simplex(d::S, points::S)::Matrix{Float64} where {S<:Int}
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
