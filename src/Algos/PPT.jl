"""
    ppt(
      prices::AbstractMatrix,
      w::Int,
      ϵ::Int,
      horizon::Int,
      b̂ₜ::AbstractVector=ones(size(prices, 1))/size(prices, 1)
    )

Run the Price Peak Tracking algorithm.

# Arguments
- `prices::AbstractMatrix`: Matrix of prices.
- `w::Int`: Window size.
- `ϵ::Int`: Constraint parameter.
- `horizon::Int`: Number of days to run the algorithm.
- `b̂ₜ::AbstractVector=ones(size(prices, 1))/size(prices, 1)`: Initial weights.

!!! warning "Beware!"
    `prices` should be a matrix of size `n_assets` × `n_periods`.

# Output
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "AMZN", "GOOG", "MSFT"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2020-01-01")["adjclose"] for ticker in tickers];

julia> prices = stack(querry) |> permutedims;

julia> model = ppt(prices, 10, 100, 100);

julia> sum(model, dims=1) .|> isapprox(1.) |> all
true
```

# References
> [A Peak Price Tracking-Based Learning System for Portfolio Selection](https://doi.org/10.1109/TNNLS.2017.2705658)
"""
function ppt(
  prices::AbstractMatrix,
  w::Int,
  ϵ::Int,
  horizon::Int,
  b̂ₜ::AbstractVector=ones(size(prices, 1))/size(prices, 1)
)
  w>0 || ArgumentError("w must be positive.") |> throw
  ϵ>0 || ArgumentError("ϵ must be positive.") |> throw
  n_assets, n_obs = size(prices)
  n_obs-w≥horizon || ArgumentError("`n_obs-w` must be greater than or equal to `horizon`. \
  `n_obs` is the number of observations ($(n_obs))") |> throw
  sum(b̂ₜ) ≈ 1.0 || ArgumentError("The sum of `b̂ₜ` must be equal to 1.0.") |> throw
  length(b̂ₜ) == n_assets || ArgumentError("The length of `b̂ₜ` must be equal to `n_assets` \
  ($(n_assets)).") |> throw
  b = similar(prices, n_assets, horizon)
  b[:,1] = b̂ₜ
  for t ∈ 1:horizon-1
    pₜ       = @view prices[:,t+w-1]
    b̂ₜ       = @view b[:,t]
    p̂ₜ₊₁     = p̂ₜ₊₁func(prices[:,t:t+w-1])
    x̂ₜ₊₁     = p̂ₜ₊₁ ./ pₜ
    x̂ₜ₊₁⊥    = x̂ₜ₊₁⊥func(x̂ₜ₊₁)
    ĉₜ₊₁     = ĉₜ₊₁func(x̂ₜ₊₁⊥, ϵ)
    b̃ₜ₊₁     = b̂ₜ .+ ĉₜ₊₁
    bₜ₊₁     = b̂ₜ₊₁func(b̃ₜ₊₁)
    bₜ₊₁     = max.(0., bₜ₊₁) |> normalizer!
    b[:,t+1] = bₜ₊₁
  end
  return OPSAlgorithm(n_assets, b, "PPT")
end

function p̂ₜ₊₁func(pₜ::AbstractMatrix)
  maximum(pₜ, dims=2) |> vec
end

function x̂ₜ₊₁⊥func(x̂ₜ₊₁::AbstractVector)
  d = length(x̂ₜ₊₁)
  return permutedims(x̂ₜ₊₁) * (I-(ones(d, 1)/d * ones(1, d)/d)) |> vec
end

function ĉₜ₊₁func(x̂ₜ₊₁⊥::AbstractVector, ϵ::Int)
  d = length(x̂ₜ₊₁⊥)
  T = eltype(x̂ₜ₊₁⊥)
  if all(x̂ₜ₊₁⊥.!==0.)
    return (ϵ*x̂ₜ₊₁⊥)/norm(x̂ₜ₊₁⊥)
  else
    return zeros(T, d)
  end
end

function b̂ₜ₊₁func(b̃ₜ₊₁)
  n_assets = length(b̃ₜ₊₁)
  model = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
  @variable(model, 0. ≤ b[i=1:n_assets] ≤ 1.)
  @constraint(model, sum(b) == 1.)
  @NLobjective(model, Min, sum((b[i] - b̃ₜ₊₁[i])^2 for i=1:n_assets))
  optimize!(model)
  return value.(b)
end
