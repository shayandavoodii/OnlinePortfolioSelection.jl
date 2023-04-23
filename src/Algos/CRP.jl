struct CRP
  n_asset::Int
  b::Matrix{Float64}
  budgets::Vector{Float64}
end;

function CRP(adj_close::Matrix{Float64}, initial_budget=1)
  # Calculate relative prices
  @views relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]

  n_assets, n_periods = size(adj_close)

  # Calculate b (initial weights)
  b = fill(1/n_assets, (n_assets, n_periods))

  # Calculate budgets
  budget = zeros(n_periods)
  budget[1] = initial_budget

  for t in 1:n_periods-1
    @views budget[t+1] = budget[t] * sum(relative_prices[:, t] .* b[:, t])
  end

  CRP(n_assets, b, budget)
end;
