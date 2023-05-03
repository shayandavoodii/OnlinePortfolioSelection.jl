# COV_EXCL_START
function simplex_proj(b::Vector{Float64})
  n_assets = length(b)
  cond     = false
  sorted_b = sort(b, rev=true)
  tmpsum   = 0.
  for i ∈ 1:n_assets-1
    tmpsum += sorted_b[i]
    tmax    = (tmpsum - 1.)/i
    if tmax≥sorted_b[i+1]
      cond = true
      break
    end
  end

  if !cond
    tmax = (tmpsum + sorted_b[n_assets-1] - 1.)/n_assets
  end

  return max.(b .- tmax, 0.)
end
# COV_EXCL_STOP

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
function normalizer!(mat::Matrix{T}) where T<:Float64
  @inbounds @simd for idx_col ∈ axes(mat, 2)
    @views normalizer!(mat[:, idx_col])
  end
end

"""
    normalizer!(vec::Vector)::Vector{Float64}

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
