include("../Tools/tools.jl")
include("../Types/Algorithms.jl")

"""
    CRP(adj_close::Matrix{T}, initial_budget=1) where T<:Float64

Run Constant Rebalanced Portfolio (CRP) algorithm.

# Arguments
- `adj_close::Matrix{Float64}`: adjusted close prices
- `initial_budget::Float64`: initial budget

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm(n_assets, b, budgets, alg)`: OPSAlgorithm object

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

  return OPSAlgorithm(n_assets, b, Snₜ, "CRP")
end
