include("../Tools/tools.jl")

"""
    CRP

An object of type `CRP`.

# Fields
- `n_asset::Int`: number of assets
- `b::Matrix{T}`: Matrix of weights
- `budgets::Vector{T}`: budget

!!! note
    The rows of `b` represent the assets and the columns represent the time periods.

```math
{S_n} = {S_0}\\prod\\limits_{t = 1}^T {\\left\\langle {{b_t},{x_t}} \\right\\rangle }
```

where ``S₀`` is the initial budget, ``n`` is the investment horizon, ``b_t`` is the vector \
of weights of the portfolio at time ``t`` and ``x_t`` is the vector of relative prices of \
the assets at time ``t``.
"""
struct CRP{T<:Float64}
  n_assets::Int
  b::Matrix{T}
  budgets::Vector{T}
end

"""
    CRP(adj_close::Matrix{T}, initial_budget=1) where T<:Float64

Run Constant Rebalanced Portfolio (CRP) algorithm.

# Arguments
- `adj_close::Matrix{Float64}`: adjusted close prices
- `initial_budget::Float64`: initial budget

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::CRP`: CRP object

# References
- [1] [Universal Portfolios](https://onlinelibrary.wiley.com/doi/10.1111/j.1467-9965.1991.tb00002.x)

# Example
```julia
julia> typeof(adj_close), size(adj_close)
(Matrix{Float64}, (3, 10))

julia> crp = CRP(adj_close);

julia> crp.b
3×10 Matrix{Float64}:
 0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333
 0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333
 0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333

julia> sum(crp.b, dims=1) .|> isapprox(1.) |> all
true
```
"""
function CRP(adj_close::Matrix{T}; initial_budget=1.) where T<:Float64
  # Calculate relative prices
  @views relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  n_assets, n_periods = size(adj_close)

  # Calculate initial weights
  b = fill(1/n_assets, (n_assets, n_periods))

  # Calculate budgets
  Snₜ = Sn(relative_prices, b, initial_budget)

  return CRP(n_assets, b, Snₜ)
end
