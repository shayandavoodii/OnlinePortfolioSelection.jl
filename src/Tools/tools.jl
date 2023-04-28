const METHODS1 = (:CORN, :DRICORN, :DRICORNK)

function simplex_proj(b::Vector)
  n_assets = length(b)
  cond = false
  sorted_b = sort(b, rev=true)
  tmpsum = 0.
  for i in 1:n_assets-1
    tmpsum += sorted_b[i]
    tmax = (tmpsum - 1.)/i
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

function mc_simplex(d, points)
  a = sort(rand(points, d), dims=2)
  a = [zeros(points) a ones(points)]
  diff(a, dims=2)
end

"""
    invest(
      method::Symbol,
      horizon::Int,
      weights::Matrix{T},
      reltv_pr::Matrix{T},
      initial_budget
    ) where T<:Float64

  Invest the budget in the assets according to the given weights in the given horizon.

  # Arguments
  - `method::Symbol`: The method that is used for investment.
  - `horizon::Int`: The number of periods that the investment is made.
  - `weights::Matrix{T}`: The weights of the assets in each period.
  - `reltv_pr::Matrix{T}`: The relative prices of the assets in each period.
  - `initial_budget`: The initial budget.

  # Returns
  - `budgets::Vector{T}`: The budget during the investment horizon.
"""
function invest(
  method::Symbol,
  horizon::Int,
  weights::Matrix{T},
  reltv_pr::Matrix{T},
  initial_budget
) where T<:Float64

  if method ∈ METHODS1
    return budg_dur_time(horizon, weights, reltv_pr, initial_budget)
  end
end

function budg_dur_time(
  horizon::Int,
  weights::Matrix{T},
  reltv_pr::Matrix{T},
  initial_budget
) where T<:Float64
  # Calculate budgets
  budgets = zeros(T, horizon+1)
  budgets[1] = initial_budget
  for t in 1:horizon
    @views budgets[t+1] = budgets[t] * sum(reltv_pr[:, end-horizon+t] .* weights[:, t])
  end
  return budgets
end

"""
    Sn(
      rel_pr::AbstractMatrix{T},
      w::AbstractMatrix{T},
      init_budg
    ) where T<:Float64

Calculate the cumulative return of portfolio.

# Arguments
- `rel_pr::AbstractMatrix{T}`: The relative prices of the assets in each period.
- `w::AbstractMatrix{T}`: The weights of the assets in each period.
- `init_budg`: The initial budget.

!!! warning "Beware!"
    `rel_pr` and `w` should be a matrix of size `n_assets` × `n_periods`.
"""
function Sn(
  rel_pr::AbstractMatrix{T},
  w::AbstractMatrix{T},
  init_budg
) where T<:Float64

  n_periods = size(rel_pr, 2)
  budgets = zeros(T, n_periods+1)
  budgets[1] = init_budg
  for t ∈ 1:n_periods
    budgets[t+1] = S(budgets[t], w[:, t], rel_pr[:, t])
  end

  return budgets
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
