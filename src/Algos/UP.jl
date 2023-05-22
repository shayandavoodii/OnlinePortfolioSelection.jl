"""
    up(
      adj_close::Matrix{Float64};
      eval_points::Int=10^4,
    )

Universal Portfolio (UP) algorithm.

Calculate the Universal Portfolio (UP) weights and budgets
using the given historical prices and parameters.

# Arguments
- `adj_close::Matrix{Float64}`: Historical adjusted close prices.

## Keyword Arguments
- `eval_points::Int=10^4`: Number of evaluation points.

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm(n_assets, b, alg)`: OPSAlgorithm object.

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> typeof(adj_close), size(adj_close)
(Matrix{Float64}, (3, 30))

julia> m_up = up(adj_close);

julia> m_up.b
3×30 Matrix{Float64}:
 0.333333  0.331149  0.33204   0.331716  …  0.326788  0.325788  0.325829  0.326222
 0.333333  0.336058  0.335239  0.336304     0.343405  0.342161  0.342283  0.340693
 0.333333  0.332793  0.33272   0.331981     0.329807  0.332051  0.331888  0.333086

julia> sum(m_up.b, dims=1) .|> isapprox(1.) |> all
true
```

# References
- [1] [Universal Portfolios](https://doi.org/10.1111/j.1467-9965.1991.tb00002.x)
"""
function up(
  adj_close::Matrix{Float64};
  eval_points::Int=10^4
)

  relative_prices     = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  n_assets, n_periods = size(relative_prices)

  # Initialize weights
  weights       = zeros(n_assets, n_periods+1)
  weights[:, 1] = fill(1/n_assets, n_assets)
  W             = mc_simplex(n_assets-1, eval_points)
  m             = size(W, 1)
  S             = reshape(ones(m), m, 1)

  # Update weights
  for t ∈ 1:n_periods
    last_rel = relative_prices[:, t]
    n        = length(last_rel)
    S        = S.*(W*reshape(last_rel, n, 1))
    b        = W'*S

    normalizer!(b)
    weights[:, t+1] = b
  end

  return OPSAlgorithm(n_assets, weights, "UP")
end
