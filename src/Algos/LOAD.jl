"""
    fᵢ(adj_price::AbstractMatrix{T}) where T<:Float64

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
    predict(η::T, aᵢ::AbstractVector{T}, adj_price::AbstractMatrix{T}, α::T) where T<:Float64

Predict the price of each asset at time t+1.

# Arguments
- `η::T`: Threshold value.
- `aᵢ::Vector{T}`: Gradient of the regression.
- `adj_price::Matrix{T}`: Adjusted close price data.
- `α::T`: Decay factor.

# Returns
- `p̂ₜ₊₁::Vector{T}`: Predicted price of each asset at time t+1.
"""
function predict(η::T, aᵢ::AbstractVector{T}, adj_price::AbstractMatrix{T}, α::T) where T<:Float64
  n_assets, n_days = size(adj_price)
  p̂ₜ₊₁ = zeros(T, n_assets)
  for asset ∈ 1:n_assets
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

"""
    next_pr_rel(adj_close::T, pred_price::T) where T<:AbstractVector

Calculate the relative price of each asset at time t+1.

# Arguments
- `adj_close::T`: Adjusted close price of each asset at time t.
- `pred_price::T`: Predicted price of each asset at time t+1.

# Returns
- `pr_rel::T`: Relative price of each asset at time t+1.
"""
function next_pr_rel(adj_close::T, pred_price::T) where T<:AbstractVector
  return pred_price ./ adj_close
end

"""
    optimization(b::T, pr_rel::T, ϵ::S) where {T<:AbstractVector, S<:Float64}

Calculate the weights of each asset at time t+1.

# Arguments
- `b::T`: Weights of each asset at time t.
- `pr_rel::T`: Relative price of each asset at time t+1.
- `ϵ::S`: Expected return threshold value.

# Returns
- `b̂::T`: Weights of each asset at time t+1.
"""
function optimization(b::T, pr_rel::T, ϵ::S) where {T<:AbstractVector, S<:Float64}
  γ = γfunc(b, pr_rel, ϵ)
  return b .+ (pr_rel .- mean(pr_rel))*γ
end

function γfunc(b::T, pr_rel::T, ϵ::S) where {T<:AbstractVector, S<:Float64}
  bᵀx̂ₜ = sum(b .* pr_rel)
  euclidean_norm = norm(pr_rel .- mean(pr_rel))
  return max(0, (ϵ - bᵀx̂ₜ) / euclidean_norm)
end

"""
    portfolio_projection(b̂::T, pred_rel::T, ϵ::S) where {T<:AbstractVector, S<:Real}

Calculate the weights of each asset at time t+1 by solving a quadratic optimization problem.
Since the output of `optimization` may not satisfy the simplex constraint, we project the \
output onto the simplex (this is officially included in the LOAD algorithm).

# Arguments
- `b̂::T`: Weights of each asset at time t+1.
- `pred_rel::T`: Relative price of each asset at time t+1.
- `ϵ::Real`: Expected return threshold value.

# Returns
- `b::T`: Weights of each asset at time t+1.
"""
function portfolio_projection(b̂::T, pred_rel::T, ϵ::S) where {T<:AbstractVector, S<:Real}
  # Find the b that has the minimum distance to b̂ and return it.
  n_assets = length(b̂)
  model = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
  @variable(model, 0. <= b[i=1:n_assets] <= 1.)
  @constraint(model, sum(b) == 1.)
  @constraint(model, sum(b .* pred_rel) ≥ ϵ)
  @NLobjective(model, Min, sum((b[i] - b̂[i])^2 for i=1:n_assets))
  optimize!(model)
  return value.(b)
end

"""
    load(adj_close::AbstractMatrix{T}, α::T, ω::S, horizon::S, η::T, ϵ::T=1.5) where {T<:Float64, S<:Int}

Run LOAD algorithm.

# Arguments
- `adj_close::AbstractMatrix{T}`: Adjusted close price data.
- `α::T`: Decay factor. (0 < α < 1)
- `ω::S`: Window size. (ω > 0)
- `horizon::S`: Investment horizon. (n_periods > horizon > 0)
- `η::T`: Threshold value. (η > 0)
- `ϵ::T=1.5`: Expected return threshold value.

!!! warning "Beware!"
    `adj_close` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of type `OPSAlgorithm` containing the weights of each asset for \
each period.
- `Sₜ::Vector{Float64}`: Cumulative wealth for each period.

# Example
```julia
# Get data
julia> using YFinance
julia> startdt, enddt = "2022-04-01", "2023-04-27";
julia> querry = [
          get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers
       ];
julia> prices = reduce(hcat, querry);
julia> prices = permutedims(prices);

julia> using OnlinePortfolioSelection

julia> model, s = load(prices, 0.5, 30, 5, 0.1);

julia> model.b
5×5 Matrix{Float64}:
 0.2  2.85298e-8  0.0        0.0       0.0
 0.2  0.455053    0.637299   0.694061  0.653211
 0.2  0.215388    0.0581291  0.0       0.0
 0.2  0.329559    0.304572   0.305939  0.346789
 0.2  6.06128e-9  0.0        0.0       0.0

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true

julia> s
6-element Vector{Float64}:
 1.0
 0.9879822754225864
 0.9853561439014098
 0.9836737048568326
 0.971437501096619
 0.9660091217094392
```

# References
> [A local adaptive learning system for online portfolio selection](https://doi.org/10.1016/j.knosys.2019.104958)
"""
function load(adj_close::AbstractMatrix{T}, α::T, ω::S, horizon::S, η::T; ϵ::T=1.5) where {T<:Float64, S<:Int}
  n_assets, n_days = size(adj_close)
  n_days > 1 || DomainError("The number of days must be greater than 1.") |> throw
  n_assets > 1 || DomainError("The number of assets must be greater than 1.") |> throw
  horizon > 0 || DomainError("The horizon must be greater than 0.") |> throw
  ω > 0 || DomainError("The window size must be greater than 0.") |> throw
  α > 0 || DomainError("The decay factor must be greater than 0.") |> throw
  η > 0 || DomainError("The threshold value must be greater than 0") |> throw
  horizon < n_days || DomainError("The horizon must be less than number of columns of \
  `adj_close` matrix. Either provide more data or decrease the value of `horizon`.") |> throw
  train_adj_close = @views adj_close[:, 1:end-horizon]
  ω ≤ size(train_adj_close, 2) || DomainError("The window size must be less than or equal to the \
  number of training period. Either provide more data or decrease the value of `ω` or \
  decrease the `horizon` value") |> throw

  rel_pr = adj_close[:, 2:end] ./ adj_close[:, 1:end-1]
  b = ones(T, n_assets, horizon)/n_assets
  for t ∈ 1:horizon
    bₜ = b[:, t]
    train = adj_close[:, end-horizon+t-ω:end-horizon+t-1]
    aᵢ = fᵢ(train)
    p̂ₜ₊₁ = predict(η, aᵢ, train, α)
    pr_rel = next_pr_rel(adj_close[:, end-horizon+t-1], p̂ₜ₊₁)
    b̂ₜ₊₁ = optimization(bₜ, pr_rel, ϵ)
    if t == horizon
      break
    end
    b[:, t+1] = portfolio_projection(b̂ₜ₊₁, pr_rel, ϵ)
    b[:, t+1] = max.(b[:, t+1], 0)
    normalizer!(b, t+1)
  end
  return OPSAlgorithm(n_assets, b, "LOAD")
end
