include("../Tools/tools.jl");

struct UP
  n_assets::Int
  b::Matrix{Float64}
  budgets::Vector{Float64}
end

"""
    UP(adj_close::Matrix{Float64}, initial_budget=1., eval_points::Int=10^4, leverage=1., frequency::Int=1, min_history::Int=0)

Universal Portfolio (UP) algorithm.

Calculate the Universal Portfolio (UP) weights and budgets
using the given historical prices and parameters.

# Arguments
- `adj_close::Matrix{Float64}`: Historical adjusted close prices.
- `initial_budget=1.`: Initial budget.
- `eval_points::Int=10^4`: Number of evaluation points.
- `leverage=1.`: Leverage value.

# Returns
- `::UP(n_assets, weights, budgets)`: Universal Portfolio (UP) object.

# References
- [1] [Universal Portfolios](https://doi.org/10.1111/j.1467-9965.1991.tb00002.x)

# Examples
```julia
```

"""
function UP(
  adj_close::Matrix{Float64},
  initial_budget=1.,
  eval_points::Int=10^4,
  leverage=1.
)

  relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  n_assets, n_periods = size(relative_prices)
  # Initialize weights
  weights = zeros(n_assets, n_periods+1)
  weights[:, 1] = ones(n_assets) / n_assets
  W = mc_simplex(n_assets-1, eval_points)
  m = size(W, 1)
  S = reshape(ones(m), m, 1)
  leverage_ = max(leverage, 1/n_periods)
  stretch = (leverage_-1/n_periods)/(1-1/n_periods)
  # Update weights
  for t ∈ axes(weights, 2)[1:end-1]
    n = length(relative_prices[:, t])
    S = S.*(W*reshape(relative_prices[:, t], n, 1))
    b = W'*S
    weights[:, t+1] = b./sum(b)
  end
  # budgets
  budgets = zeros(n_periods+1)
  budgets[1] = initial_budget
  for t ∈ axes(relative_prices, 2)
    budgets[t+1] = budgets[t] * sum(weights[:, t] .* relative_prices[:, t])
  end
  return UP(n_assets, weights, budgets)
end
