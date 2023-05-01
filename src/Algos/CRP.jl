include("../Tools/tools.jl")

"""@docs
    crp(adj_close::Matrix{T}, init_budg=1) where T<:Float64

Run Constant Rebalanced Portfolio (CRP) algorithm.

# Arguments
- `adj_close::Matrix{Float64}`: adjusted close prices
- `init_budg::Float64`: initial budget

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm(n_assets, b, alg)`: OPSAlgorithm object

# References
- [1] [Universal Portfolios](https://onlinelibrary.wiley.com/doi/10.1111/j.1467-9965.1991.tb00002.x)

# Example
```julia
julia> using OnlinePortfolioSelection

julia> typeof(adj_close), size(adj_close)
(Matrix{Float64}, (3, 10))

julia> m_crp = crp(adj_close);

julia> m_crp.b
3×10 Matrix{Float64}:
 0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333
 0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333
 0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333  0.333333

julia> sum(m_crp.b, dims=1) .|> isapprox(1.) |> all
true
```
"""
function crp(adj_close::Matrix{T}; init_budg=1.) where T<:Float64
  # Calculate relative prices
  @views relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  n_assets, n_periods = size(adj_close)

  # Calculate initial weights
  b = fill(1/n_assets, (n_assets, n_periods))

  return OPSAlgorithm(n_assets, b, "CRP")
end
