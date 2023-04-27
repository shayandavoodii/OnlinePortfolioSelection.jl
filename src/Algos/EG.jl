struct EG
  n_asset::Int
  b::Matrix{Float64}
  budgets::Vector{Float64}
end

"""
    EG(adj_close::Matrix{Float64}, initial_budget=1, eta=0.05)

Exponential Gradient (EG) algorithm.

Calculate the Exponential Gradient (EG) weights and budgets
using the given historical prices and parameters and return
an EG object.

# Arguments
- `adj_close::Matrix{Float64}`: Historical adjusted close prices.
- `initial_budget=1.`: Initial budget.
- `eta=0.05`: Learning rate.

# Returns
- `::EG(n_assets, weights, budgets)`: Exponential Gradient (EG) object.

# References
- [1] [On-Line Portfolio Selection Using Multiplicative Updates](https://doi.org/10.1111/1467-9965.00058)
"""
function EG(adj_close::Matrix{Float64}, initial_budget=1, eta=0.05)
  # Calculate relative prices
  @views relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  n_assets, n_periods = size(adj_close)
  # Initialiate Vector of weights
  b = fill(1/n_assets, (n_assets, n_periods))
  # Calculate weights
  for t ∈ axes(adj_close, 2)[2:end]
    prev_b = @view b[:, t-1]
    @views w = prev_b .* exp.(
      eta.*relative_prices[:, t-1]/sum(relative_prices[:, t-1].*b[:, t-1])
    )
    b[:, t] = w/sum(w)
  end
  # Calculate budgets
  budget = zeros(n_periods)
  budget[1] = initial_budget
  for t ∈ 1:n_periods-1
    budget[t+1] = budget[t] * sum(relative_prices[:, t] .* b[:, t])
  end
  return EG(n_assets, b, budget)
end
