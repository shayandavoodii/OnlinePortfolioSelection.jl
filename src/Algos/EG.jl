include("../Tools/tools.jl")
include("../Types/Algorithms.jl")

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

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm(n_assets, b, budgets, alg)`: OPSAlgorithm object.

# References
- [1] On-Line Portfolio Selection Using Multiplicative Updates](https://onlinelibrary.wiley.com/doi/10.1111/1467-9965.00058)

# Examples
```julia
julia> typeof(adj_close), size(adj_close)
(Matrix{Float64}, (3, 10))

julia> eg = EG(adj_close);

julia> eg.b
3×10 Matrix{Float64}:
 0.333333  0.333119  0.333296  0.333232  0.33327   0.333276  0.333201  0.333171  0.332832  0.332789
 0.333333  0.333436  0.333274  0.333485  0.333481  0.333359  0.333564  0.333477  0.333669  0.333835
 0.333333  0.333445  0.33343   0.333283  0.333249  0.333365  0.333234  0.333353  0.333499  0.333377

julia> sum(eg.b, dims=1) .|> isapprox(1.0) |> all
true
```
"""
function EG(adj_close::Matrix{Float64}; initial_budget=1., eta=0.05)
  # Calculate relative prices
  @views relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  n_assets, n_periods = size(adj_close)

  # Initialiate Vector of weights
  b = fill(1/n_assets, (n_assets, n_periods))

  # Calculate weights
  for t ∈ 2:n_periods
    @views prev_b = b[:, t-1]
    @views w = prev_b .* exp.(
      eta.*relative_prices[:, t-1]/sum(relative_prices[:, t-1].*prev_b)
    )
    normalizer!(w)
    b[:, t] = w
  end

  # Calculate cumulative return
  Snₜ = Sn(relative_prices, b, initial_budget)

  return OPSAlgorithm(n_assets, b, Snₜ, "EG")
end
