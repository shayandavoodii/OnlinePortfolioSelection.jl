"""
    crp(adj_close::Matrix{T}) where T<:Float64

Run Constant Rebalanced Portfolio (CRP) algorithm.

# Arguments
- `adj_close::Matrix{Float64}`: adjusted close prices

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm(n_assets, b, alg)`: OPSAlgorithm object

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

# References
> [Universal Portfolios](https://onlinelibrary.wiley.com/doi/10.1111/j.1467-9965.1991.tb00002.x)
"""
function crp(adj_close::Matrix{T}) where T<:Float64
  n_assets, n_periods = size(adj_close)

  # Calculate initial weights
  b = fill(1/n_assets, (n_assets, n_periods))

  return OPSAlgorithm(n_assets, b, "CRP")
end
