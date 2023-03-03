include("../tools.jl");

Base.@kwdef mutable struct UP
  n_assets::Int
  t::Int
  n_eval::Int = 10_000
  leverage::Float64 = 1.0
  W::Matrix{Float64} = ones(n_assets, t) ./ n_assets
  S::Matrix{Float64} = ones(n_assets, 1)
end;

"""
  init_weights(n_assets::Int)

Initialize the weights of the portfolio.

# Arguments
- `n_assets::Int`: Number of assets in the portfolio.

# Returns
- `::Vector{Float64}`: Array of weights.
"""
function init_weights!(up::UP, n_assets::Int)
  up.W .= ones(n_assets) ./ n_assets
end;

# !error DimensionMismatch: array could not be broadcast to match destination
# n_samlpes = 100
# size(mc_simplex(n_samlpes - 1, up.n_eval)) = (99, 10001)
# size(up.W) = (5,)
function init_step!(up::UP, X::Matrix{Float64})
  n_samlpes = size(X, 2)
  up.W .= mc_simplex(n_samlpes-1, up.n_eval)
  leverage = max(up.leverage, 1.0 / n_samlpes)
  stretch = (leverage - 1.0 / n_samlpes) / (1.0 - 1.0 / n_samlpes)
  up.W .= (up.W - 1.0 / n_samlpes) * stretch + 1.0 / n_samlpes
end;

function step(up::UP, close_t::Vector{Float64})
  b = up.S .* (up.W .* close_t)
  b ./ sum(b)
end;

function weights(X::Matrix{Float64})
  B = zeros(size(X))
  up = UP(n_assets=size(X, 1))
  init_step!(up, X)
  last_b = up.W
  for t in 1:size(X, 2)
    B[:, t] = last_b
    last_b = step(up, X)
  end
  B
end;

using CSV, DataFrames
df = CSV.read(raw"src\sp500.csv", DataFrame);
df = Matrix(df[1:100, 1:5])
df = permutedims(df)

weights(df)
