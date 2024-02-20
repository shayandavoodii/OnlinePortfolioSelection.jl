"""
    function up(
      rel_pr::AbstractMatrix{T};
      eval_points::Integer=10^4
    ) where T<:AbstractFloat

Universal Portfolio (UP) algorithm.

Calculate the Universal Portfolio (UP) weights and budgets
using the given historical prices and parameters.

# Arguments
- `rel_pr::AbstractMatrix{T}`: Historical relative prices.

## Keyword Arguments
- `eval_points::Integer=10^4`: Number of evaluation points.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(3, 9);

julia> m_up = up(rel_pr);

julia> m_up.b
3×9 Matrix{Float64}:
 0.333333  0.272709  0.345846  0.385378  0.308659  0.328867  0.280564  0.349619  0.433529
 0.333333  0.288016  0.315603  0.249962  0.252828  0.24165   0.270741  0.2621    0.235743
 0.333333  0.439276  0.338551  0.364661  0.438512  0.429483  0.448695  0.388281  0.330729

julia> sum(m_up.b, dims=1) .|> isapprox(1.) |> all
true
```

# References
> [Universal Portfolios](https://doi.org/10.1111/j.1467-9965.1991.tb00002.x)
"""
function up(
  rel_pr::AbstractMatrix{T};
  eval_points::Integer=10^4
) where T<:AbstractFloat

  n_assets, n_periods = size(rel_pr)

  # Initialize weights
  b        = similar(rel_pr)
  b[:, 1] .= 1/n_assets
  W        = simplex(n_assets-1, eval_points)
  m        = size(W, 1)
  S        = ones(T, m, 1)

  # Update weights
  @inbounds for t ∈ 1:n_periods-1
    last_rel   = rel_pr[:, t]
    S          = S.*(W*reshape(last_rel, n_assets, 1))
    b[:, t+1]  = W'*S
  end
  normalizer!(b)
  return OPSAlgorithm(n_assets, b, "UP")
end
