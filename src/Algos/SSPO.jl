function bₒ₊₁func(λ, γ, η, gₒ::AbstractVector, ρₒ, φₜ::AbstractVector)
  n_assets   = length(gₒ)
  firstterm  = (λ/γ*I(n_assets) .+ fill(η, n_assets, n_assets))^-1
  secondterm = λ/γ*gₒ.+fill(η-ρₒ, n_assets).-φₜ
  return firstterm*secondterm
end

function gₒ₊₁func(bₒ₊₁::AbstractVector, γ)
  secondterm = abs.(bₒ₊₁).-γ
  secondterm[secondterm.<0] .= 0.
  return sign.(bₒ₊₁).*secondterm
end

ρₒ₊₁(ρₒ, η, bₒ₊₁::AbstractVector) = ρₒ+η*(sum(bₒ₊₁)-1)

function normptf(bₜ₊₁::AbstractVector, ζ)
  n_assets = length(bₜ₊₁)
  model    = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
  @variable(model, 0. ≤ b[i=1:n_assets] ≤ 1.)
  @constraint(model, sum(b) == 1.)
  @NLobjective(model, Min, sum((b[i] - ζ*bₜ₊₁[i])^2 for i=1:n_assets))
  optimize!(model)
  return value.(b)
end

"""
    sspo(
      p::AbstractMatrix,
      horizon::Integer,
      w::Integer,
      b̂ₜ::Union{Nothing, AbstractVector}=nothing,
      η::AbstractFloat=0.005,
      γ::AbstractFloat=0.01,
      λ::AbstractFloat=0.5,
      ζ::Integer=500,
      ϵ::AbstractFloat=1e-4,
      max_iter=1e4
    )

Run Short-term Sparse Portfolio Optimization (SSPO) algorithm.

# Arguments
- `p::AbstractMatrix`: Prices of the assets.
- `horizon::Integer`: Number of investment periods.
- `w::Integer`: Window size.
- `b̂ₜ::Union{Nothing, AbstractVector}=nothing`: Initial portfolio weights. If `nothing` is \
  passed, then a uniform portfolio will be selected for the first period.
- `η::AbstractFloat=0.005`: Learning rate.
- `γ::AbstractFloat=0.01`: Regularization parameter.
- `λ::AbstractFloat=0.5`: Regularization parameter.
- `ζ::Integer=500`: Regularization parameter.
- `ϵ::AbstractFloat=1e-4`: Tolerance for the convergence of the algorithm.
- `max_iter=1e4`: Maximum number of iterations.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["GOOG", "AAPL", "MSFT", "AMZN"]

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-31")["adjclose"] for ticker=tickers]

julia> prices = stack(querry, dims=1)

julia> h = 5

julia> w = 5

julia> model = sspo(prices, h, w);

julia> model.b
4×5 Matrix{Float64}:
 0.25  9.92018e-9  1.0         1.0  1.0
 0.25  0.0         0.0         0.0  0.0
 0.25  0.0         0.0         0.0  0.0
 0.25  1.0         9.94367e-9  0.0  0.0
```

# Reference
> [Short-term Sparse Portfolio Optimization Based on Alternating Direction Method of Multipliers](http://jmlr.org/papers/v19/17-558.html)
"""
function sspo(
  p::AbstractMatrix,
  horizon::Integer,
  w::Integer,
  b̂ₜ::Union{Nothing, AbstractVector}=nothing,
  η::AbstractFloat=0.005,
  γ::AbstractFloat=0.01,
  λ::AbstractFloat=0.5,
  ζ::Integer=500,
  ϵ::AbstractFloat=1e-4,
  max_iter=1e4
)
  n_assets, n_samples = size(p)
  if isnothing(b̂ₜ)
    b̂ₜ = ones(size(p, 1))/size(p, 1)
  else
    sum(b̂ₜ)≈1. || ArgumentError("Initial portfolio weights must sum to 1. Got $(sum(b̂ₜ)).") |> throw
    all(b̂ₜ.>0) || ArgumentError("Initial portfolio weights must be positive.") |> throw
    length(b̂ₜ) == n_assets || ArgumentError("Initial portfolio weights must have the same \
    length as the number of assets.") |> throw
  end
  horizon>0 || ArgumentError("`horizon` must be positive. Got $horizon.") |> throw
  w>0 || ArgumentError("`w` must be positive. Got $w.") |> throw
  η>0 || ArgumentError("`η` must be positive. Got $η.") |> throw
  γ>0 || ArgumentError("`γ` must be positive. Got $γ.") |> throw
  λ>0 || ArgumentError("`λ` must be positive. Got $λ.") |> throw
  ζ>0 || ArgumentError("`ζ` must be positive. Got $ζ.") |> throw
  ϵ>0 || ArgumentError("`ϵ` must be positive. Got $ϵ.") |> throw
  max_iter>0 || ArgumentError("`max_iter` must be positive. Got $max_iter.") |> throw
  n_samples≥horizon+w-1 || ArgumentError("The number of samples must be greater than \
  or equal to `horizon+w-1`. Got $n_samples.") |> throw

  b̂       = similar(p, n_assets, horizon)
  b̂[:, 1] = b̂ₜ
  for t ∈ 1:horizon-1
    Pₘₐₓ  = maximum(p[:, end-horizon-w+t+1:end-horizon+t], dims=2) |> vec
    φₜ    = -1.1*log.(Pₘₐₓ./p[:, end-horizon+t]).-1
    b = g = b̂ₜ
    ρₒ    = 0
    o     = 1
    while abs(sum(b)-1)≥ϵ || o≤max_iter
      b  = bₒ₊₁func(λ, γ, η, g, ρₒ, φₜ)
      g  = gₒ₊₁func(b, γ)
      ρₒ = ρₒ₊₁(ρₒ, η, b)
      o += 1
    end
    b̂ₜ        = normptf(b, ζ)
    b̂[:, t+1] = b̂ₜ
  end
  any(b̂.<0) && b̂ |> positify! |> normalizer!
  return OPSAlgorithm(n_assets, b̂, "SSPO")
end
