"""
    kₜₜ₋ₖfunc(p::AbstractMatrix, w::Integer, t::Integer)

Calculate the slope value of the assets in ``t``'th period and ``t-k``'th period, where \
``k`` is in ``1:w-1``.

# Arguments
- `p::AbstractMatrix`: Prices of the assets. Each column is a period and each row is an asset.
- `w::Integer`: The window size.
- `t::Integer`: The current period index.

# Returns
- `kₜₜ₋ₖ::AbstractMatrix`: The slope value of the assets in ``t``'th period and ``t-k``'th period, \
where ``k`` is in ``1:w-1``.
"""
function kₜₜ₋ₖfunc(p::AbstractMatrix, w::Integer, t::Integer)
  kₜₜ₋ₖ = similar(p)
  for k ∈ 1:w-1
    kₜₜ₋ₖ[:, k] .= (p[:, t].-p[:, t-k])/(t-(t-k))
  end
  return kₜₜ₋ₖ
end

"""
    p̂ₜ₊₁func(kₜ::AbstractMatrix, p::AbstractMatrix, w::Integer, α::AbstractFloat=0.5)

Calculate the expected price of the assets in ``t+1``'th period.

# Arguments
- `kₜ::AbstractMatrix`: The slope value of the assets in ``t``'th period and ``t-k``'th period, \
  where ``k`` is in ``1:w-1``.
- `p::AbstractMatrix`: Prices of the assets in the recent window.
- `w::Integer`: The window size.
- `α::AbstractFloat`: Exponential moving average parameter.

# Returns
- `p̂ₜ₊₁::AbstractVector`: The expected price of the assets in ``t+1``'th period.
"""
function p̂ₜ₊₁func(kₜ::AbstractMatrix, p::AbstractMatrix, w::Integer, α::AbstractFloat=0.5)
  size(p, 2) == w || DimensionMismatch("p must have $w columns. Got $(size(p, 2))") |> throw
  n_assets = size(p, 1)
  idx_over_zero         = vec(sum(kₜ, dims=2)).>0.
  idx_under_zero        = vec(sum(kₜ, dims=2)).<0.
  idx_equal_zero        = vec(sum(kₜ, dims=2)).==0.
  p̂ₜ₊₁                  = similar(kₜ, n_assets)
  p̂ₜ₊₁[idx_under_zero] .= maximum(p[idx_under_zero, :], dims=2)
  p̂ₜ₊₁[idx_equal_zero] .= p[idx_equal_zero, end]
  p̂ₜ₊₁[idx_over_zero]  .= sum(α*(1-α)^(w-i) *p[idx_over_zero, w-i] for i=0:w-1)
  return p̂ₜ₊₁
end

function portfolio_projection(x̂ₜ₊₁::T, bₜ::T, ϵ::Integer) where {T<:AbstractVector}
  n_assets = length(bₜ)
  model = Model(optimizer_with_attributes(Optimizer, "print_level" => 0))
  @variable(model, 0. <= b[i=1:n_assets] <= 1.)
  @constraint(model, sum(b) == 1.)
  @NLconstraint(model, sum(item^2 for item=(b - bₜ)) ≤ ϵ)
  @objective(model, Max, sum(b[i] * x̂ₜ₊₁[i] for i=1:n_assets))
  optimize!(model)
  return value.(b)
end

"""
    tppt(
      prices::AbstractMatrix,
      horizon::Integer,
      w::Integer,
      ϵ::Integer=100,
      α::AbstractFloat=0.5
    )

Run Trend Promote Price Tracking (TPPT) algorithm.

# Arguments
- `prices::AbstractMatrix`: Prices of the assets. Each column is a period and each row is \
  an asset.
- `horizon::Integer`: The number of Investment periods.
- `w::Integer`: The window size.
- `ϵ::Integer`: Constraint parameter.
- `α::AbstractFloat`: Exponential moving average parameter.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-12")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1);

julia> horizon, w = 3, 3;

julia> model = tppt(prices, horizon, w);

julia> model.b
3×3 Matrix{Float64}:
 0.333333  1.52594e-6  7.35766e-7
 0.333333  5.30452e-6  3.90444e-6
 0.333333  0.999993    0.999995
```

# References
> [An online portfolio strategy based on trend promote price tracing ensemble learning algorithm](https://doi.org/10.1016/j.knosys.2021.107957)
"""
function tppt(
  prices::AbstractMatrix,
  horizon::Integer,
  w::Integer,
  ϵ::Integer=100,
  α::AbstractFloat=0.5
)

  n_assets, n_samples = size(prices)
  ϵ > 0 || DomainError("ϵ must be positive. Got $ϵ") |> throw
  horizon > 0 || DomainError("horizon must be positive. Got $horizon") |> throw
  w > 0 || DomainError("w must be positive. Got $w") |> throw
  α > 0 || DomainError("α must be positive. Got $α") |> throw
  n_samples>horizon+w-1-1 || DomainError("number of `prices`'s columns must be greater than \
  `horizon`+`w`-2. Got $n_samples") |> throw
  T                   = eltype(prices)
  b                   = zeros(T, n_assets, horizon)
  b[:, 1]            .= 1/n_assets
  for t ∈ 1:horizon-1
    idx_today  = n_samples-horizon+t
    kₜₜ₋ₖ      = kₜₜ₋ₖfunc(prices, w, idx_today)
    p̂ₜ₊₁       = p̂ₜ₊₁func(kₜₜ₋ₖ, prices[:, idx_today-w+1:idx_today], w, α)
    x̂ₜ₊₁       = p̂ₜ₊₁./prices[:, idx_today]
    b[:, t+1] .= portfolio_projection(x̂ₜ₊₁, b[:, t], ϵ)
  end
  any(b.<0.) && b|> positify! |> normalizer!
  return OPSAlgorithm(n_assets, b, "TPPT")
end
