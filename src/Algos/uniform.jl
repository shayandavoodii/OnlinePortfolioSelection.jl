"""
    uniform(rel_price::AbstractMatrix)

Construct uniform portfolios.

# Arguments
- `rel_price::AbstractMatrix`: relative price matrix.

!!! warning "Beware!"
    `rel_price` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of [`OPSAlgorithm`](@ref) type.

# Example
```julia
julia> using OnlinePortfolioSelection

julia> rel_price = [1.1 1.05 1.2; 1.02 0.88 1.06; 0.99 1.3 0.9];

julia> model = uniform(rel_price);

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```
"""
function uniform(rel_price::AbstractMatrix)
  n_assets, n_days = size(rel_price)
  b = ones(n_assets, n_days) / n_assets
  return OPSAlgorithm(n_assets, b, "1/N")
end
