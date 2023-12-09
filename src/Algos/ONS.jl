using LinearAlgebra, JuMP, Ipopt

function bₜ₋₁func(β::Integer, pτ::AbstractMatrix, rₜ::AbstractMatrix)
  n_assets, t = size(pτ)
  res = zeros(n_assets)
  for τ ∈ 1:t
    res .+= ∇f(pτ[:,τ], rₜ[:,τ])
  end
  return (1+1/β).*res
end

function ∇f(pₜ::AbstractVector, rₜ::AbstractVector)
  return rₜ./sum(pₜ.*rₜ)
end

function Aₜ₋₁func(pₜ::AbstractMatrix, rₜ::AbstractMatrix)
  n_assets, t = size(pₜ)
  ∇ = 0.
  for τ ∈ 1:t
    ∇ += ∇²f(pₜ[:,τ], rₜ[:,τ])
  end
  return ∇.+I(n_assets) |> Matrix
end

function ∇²f(pₜ::AbstractVector, rₜ::AbstractVector)
  return sum(-∇f(pₜ, rₜ).*∇f(pₜ, rₜ))
end

function pₜfunc(Aₜ₋₁::AbstractMatrix, bₜ₋₁::AbstractVector, 𝛿::AbstractFloat)
  q = 𝛿*Aₜ₋₁^-1 * bₜ₋₁
  model = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
  @variable(model, 0 <= p[1:length(bₜ₋₁)] <= 1)
  @constraint(model, sum(p) == 1)
  @objective(model, Min, (q-p)'*Aₜ₋₁*(q-p))
  optimize!(model)
  return value.(p)
end

"""
    ons(rel_pr::AbstractMatrix, β::Integer=1, 𝛿::AbstractFloat=1/8, η::AbstractFloat=0.)

Run Online Newton Step algorithm.

# Arguments
- `rel_pr::AbstractMatrix`: relative prices.
- `β::Integer=1`: Hyperparameter.
- `𝛿::AbstractFloat=1/8`: Heuristic tuning parameter.
- `η::AbstractFloat=0.`: Learning rate.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-12")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1);

julia> rel_pr = prices[:, 2:end]./prices[:, 1:end-1];

julia> model = ons(rel_pr, 1, 0.005, 0.1);

julia> model.b
3×6 Matrix{Float64}:
 0.333333  0.333327  0.333293  0.333295  0.333319  0.333375
 0.333333  0.333302  0.333221  0.333182  0.333205  0.333184
 0.333333  0.333371  0.333486  0.333524  0.333475  0.333441
```

# References
> [Algorithms for Portfolio Management based on the Newton Method](https://doi.org/10.1145/1143844.1143846)
"""
function ons(rel_pr::AbstractMatrix, β::Integer=1, 𝛿::AbstractFloat=1/8, η::AbstractFloat=0.)
  η≥0 || ArgumentError("η must be non-negative") |> throw
  β>0 || ArgumentError("β must be positive") |> throw
  0<𝛿≤1 || ArgumentError("𝛿 must be in (0,1]") |> throw

  n_assets, t = size(rel_pr)
  p = zeros(n_assets, t)
  p[:,1] = ones(n_assets)/n_assets
  for τ ∈ 2:t
    bₜ₋₁ = bₜ₋₁func(β, p[:,1:τ-1], rel_pr[:,1:τ-1])
    Aₜ₋₁ = Aₜ₋₁func(p[:,1:τ-1], rel_pr[:,1:τ-1])
    pₜ = pₜfunc(Aₜ₋₁, bₜ₋₁, 𝛿)
    p[:,τ] = (1-η)*pₜ.+(η/n_assets)
  end
  return OPSAlgorithm(n_assets, p, "ONS")
end
