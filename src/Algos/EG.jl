struct EG
  n_asset::Int
  b::Matrix{Float64}
  budgets::Vector{Float64}
end;

function EG(adj_close::Matrix{Float64}, initial_budget=1, eta=0.5)
  # Calculate relative prices
  @views relative_prices = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]

  n_assets = size(adj_close, 1)
  n_periods = size(adj_close, 2)

  # Initialiate Vector of weights
  b = fill(1/n_assets, (n_assets, n_periods))

  # Calculate weights
  for t in axes(adj_close, 2)[2:end]
    prev_b = @view b[:, t-1]
    @views w = prev_b .* exp.(
      eta.*relative_prices[:, t-1]/sum(relative_prices[:, t-1].*b[:, t-1])
    )

    b[:, t] = w/sum(w)
  end

  # Calculate budgets
  budget = zeros(n_periods)
  budget[1] = initial_budget

  for t in 1:n_periods-1
    budget[t+1] = budget[t] * sum(relative_prices[:, t] .* b[:, t])
  end

  EG(n_assets, b, budget)
end;

using CSV
using DataFrames
df = CSV.read(raw"E:\Python Forks\universal-portfolios\universal\data\sp500.csv", DataFrame);
df = df[1:20, 1:2];
df = Matrix(df);
df = permutedims(df);

crp = EG(df)
crp.budgets
