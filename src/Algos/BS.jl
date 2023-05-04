"""
    bs(adj_close::Matrix{T}; last_n::Int=0) where {T<:Float64}

Run the Best So Far algorithm on the given data.

# Arguments
- `adj_close::Matrix{T}`: A matrix of adjusted closing prices of assets.
- `last_n::Int`: The number of periods to look back for the performance of each asset. If `last_n` is 0, then the performance is calculated from the first period to the previous period.

!!! warning "Beware!"
    The `adj_close` matrix should be in the order of assets x periods.

# Returns
- `::OPSAlgorithm(n_assets, b, alg)`: An instance of `OPSAlgorithm`.

# References
- [KERNEL-BASED SEMI-LOG-OPTIMAL EMPIRICAL PORTFOLIO SELECTION STRATEGIES](https://doi.org/10.1142/S0219024907004251)

# Example
```julia
julia> using OnlinePortfolioSelection

julia> adj_close = rand(5, 10);

julia> model = bs(adj_close, last_n=2);

julia> model.b
5×10 Matrix{Float64}:
 0.2  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0
 0.2  0.0  0.0  1.0  0.0  1.0  0.0  0.0  0.0  0.0
 0.2  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.2  1.0  1.0  0.0  0.0  0.0  1.0  0.0  1.0  1.0
 0.2  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```
"""
function bs(adj_close::Matrix{T}; last_n::Int=0) where {T<:Float64}
  n_assets, n_periods = size(adj_close)

  # Calculate relative prices
  relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]

  b = zeros(T, n_assets, n_periods)
  # For the first period, assign 1/n_assets to each asset
  b[:, 1] .= one(T)/n_assets
  for t ∈ 2:n_periods

    # Calculate the performance of each asset
    if t==2
      # If the period is the second period, then the performance is the relative
      # price of the first period
      perf_each_ast = relative_prices[:, 1]
    else
      if last_n≠0
        if t-1-last_n≤1
          # Otherwise, the performance is the product of relative prices from the
          # first period to the previous period
          perf_each_ast = prod(relative_prices[:, 1:t-1], dims=2)
        else
          perf_each_ast = prod(relative_prices[:, t-1-last_n:t-1], dims=2)
        end
      else
        # Otherwise, the performance is the product of relative prices from the
        # first period to the previous period
        perf_each_ast = prod(relative_prices[:, 1:t-1], dims=2)
      end

      # Get the last column of the `perf_each_ast`
      perf_each_ast = last(perf_each_ast, n_assets)
    end

    # Assign 1. to the best performing asset
    b[argmax(perf_each_ast), t] = 1.
  end

  return OPSAlgorithm(n_assets, b, "Best So Far")
end
