function sₜ(Sₜ₋₁::T, bₜ::AbstractVector{T}, xₜ::AbstractVector{T}) where T<:Float64
  return Sₜ₋₁ * sum(bₜ.*xₜ)
end

"""
    fᵢ(adj_price::Matrix{T}) where T<:Float64

Fit regression on the adjusted close price data of stocks and return the gradient of the \
regression.

# Arguments
- `adj_price::Matrix{T}`: Adjusted close price data.

# Returns
- `fᵢ::Vector{T}`: Gradient of the regression.
"""
function fᵢ(adj_price::AbstractMatrix{T}) where T<:Float64
  n_assets, n_days = size(adj_price)
  t = 1:n_days
  # Fit a linear regression on each row of the adjusted price matrix against t and store \
  # the gradients in aᵢ Vector.
  aᵢ = zeros(T, n_assets)
  for i ∈ 1:n_assets
    aᵢ[i] = adj_price[i, :] \ t
  end
  return aᵢ
end

"""
    predict(η::T, aᵢ::Vector{T}, adj_price::Matrix{T}, α::T) where T<:Float64

Predict the price of each asset at time t+1.

# Arguments
- `η::T`: Threshold value.
- `aᵢ::Vector{T}`: Gradient of the regression.
- `adj_price::Matrix{T}`: Adjusted close price data.
- `α::T`: Decay factor.
"""
function predict(η::T, aᵢ::AbstractVector{T}, adj_price::AbstractMatrix{T}, α::T) where T<:Float64
  n_assets, n_days = size(adj_price)
  p̂ₜ₊₁ = zeros(T, n_assets)
  for asset ∈ 1:n_assets
    # @show aᵢ[asset]
    # throw(2)
    if aᵢ[asset] > η
      p̂ₜ₊₁[asset] = maximum(adj_price[asset, :])
    else
      MA = ones(T, n_days)
      MA[1] = adj_price[asset, 1]
      for t ∈ 2:n_days
        MA[t] = α * adj_price[asset, t] + (1 - α) * MA[t-1]
      end
      p̂ₜ₊₁[asset] = MA[end]
    end
  end
  return p̂ₜ₊₁
end

function next_pr_rel(adj_close::T, pred_price::T) where T<:AbstractVector
  return pred_price ./ adj_close
end

function optimization(b::T, pr_rel::T) where T<:AbstractVector
  γ = γfunc(b, pr_rel)
  return b .+ (pr_rel .- mean(pr_rel))*γ
end

function γfunc(b, pr_rel)
  bᵀx̂ₜ = sum(b .* pr_rel)
  euclidean_norm = norm(pr_rel .- mean(pr_rel))
  return max(0, (eps() - bᵀx̂ₜ) / euclidean_norm)
end

function portfolio_projection(b̂::T, pred_rel::T) where T<:AbstractVector
  # Find the b that has the minimum distance to b̂ and return it.
  n_assets = length(b̂)
  model = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
  @variable(model, 0. <= b[i=1:n_assets] <= 1.)
  @constraint(model, sum(b) == 1.)
  @constraint(model, sum(b .* pred_rel) ≥ eps())
  @NLobjective(model, Min, sum((b[i] - b̂[i])^2 for i=1:n_assets))
  optimize!(model)
  return value.(b)
end

"""
    load(adj_close::AbstractMatrix{T}, α::T, ω::S, horizon::S, η::T) where {T<:Float64, S<:Int}

Run LOAD algorithm.

# References
- [A local adaptive learning system for online portfolio selection](https://doi.org/10.1016/j.knosys.2019.104958)
"""
function load(adj_close::AbstractMatrix{T}, α::T, ω::S, horizon::S, η::T) where {T<:Float64, S<:Int}
  n_assets, n_days = size(adj_close)
  n_days > 1 || DomainError("The number of days must be greater than 1.") |> throw
  n_assets > 1 || DomainError("The number of assets must be greater than 1.") |> throw
  horizon > 0 || DomainError("The horizon must be greater than 0.") |> throw
  ω > 0 || DomainError("The window size must be greater than 0.") |> throw
  α > 0 || DomainError("The decay factor must be greater than 0.") |> throw
  η > 0 || DomainError("The threshold value must be greater than 0.") |> throw
  horizon < n_days || DomainError("The horizon must be less than number of columns of \
  `adj_close` matrix. Either provide more data or decrease the value of `horizon`.") |> throw
  train_adj_close = @views adj_close[:, 1:end-horizon]
  ω ≤ size(train_adj_close, 2) || DomainError("The window size must be less than or equal to the \
  number of training period. Either provide more data or decrease the value of `ω` or \
  decrease the `horizon` value") |> throw

  Sₜ = ones(T, horizon+1)
  rel_pr = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  b = ones(T, n_assets, horizon)/n_assets
  for t ∈ 1:horizon
    bₜ = b[:, t]
    train = adj_close[:, end-horizon+t-ω:end-horizon+t-1]
    Sₜ[t+1] = sₜ(Sₜ[t], bₜ, rel_pr[:, end-horizon+t-1])
    @assert size(train, 2) == ω
    aᵢ = fᵢ(train)
    @assert length(aᵢ) == n_assets
    p̂ₜ₊₁ = predict(η, aᵢ, train, α)
    @assert length(p̂ₜ₊₁) == n_assets
    pr_rel = next_pr_rel(adj_close[:, end-horizon+t-1], p̂ₜ₊₁)
    @assert length(pr_rel) == n_assets
    b̂ₜ₊₁ = optimization(bₜ, pr_rel)
    @assert sum(b̂ₜ₊₁) ≈ 1
    if t == horizon
      break
    end
    b[:, t+1] = portfolio_projection(b̂ₜ₊₁, pr_rel)
    @assert sum(b[:, t+1]) ≈ 1
  end
  return OPSAlgorithm(n_assets, b, "LOAD")
end

startdt, enddt = "2020-04-01", "2023-04-27";
querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];
prices = reduce(hcat, querry);
prices = permutedims(prices)
r = load(rand(7, 13), 0.1, 2, 8, 0.02)
r.b
using LinearAlgebra
