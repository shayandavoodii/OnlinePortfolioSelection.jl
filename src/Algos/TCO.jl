@inline x̃ₜ₊₁func(::Type{TCO1}, x::AbstractMatrix, ::Integer) = TCO1(x[:, end])
@inline x̃ₜ₊₁func(::Type{TCO2}, x::AbstractMatrix, w::Integer) = TCO2(pred_relpr(SMAR(), x, w))

function vₜv̄ₜfunc(var::TCOVariant, b̂ₜ::AbstractVector)
  vₜ = var.f ./sum(b̂ₜ .* var.f)
  v̄ₜ = mean(vₜ)
  return vₜ, v̄ₜ
end

b̃func(η, vₜ, v̄ₜ) = η*(vₜ.-v̄ₜ)

@inline bₜ₊₁func(b̂ₜ::AbstractVector, b̃::AbstractVector, λ::AbstractFloat) = @. b̂ₜ+sign(b̃)*max(abs(b̃)-λ, 0.)

b̂ₜfunc(xₜ::AbstractVector, bₜ::AbstractVector) = xₜ.*bₜ/sum(xₜ.*bₜ)

methodname(::Type{TCO1}) = "TCO1"
methodname(::Type{TCO2}) = "TCO2"

"""
    tco(
      x::AbstractMatrix,
      w::Integer,
      horizon::Integer,
      𝛾::AbstractFloat,
      η::Integer,
      variant::Type{<:TCOVariant},
      b̂ₜ::Union{Nothing, AbstractVector}=nothing
    )

Run Transaction Cost Optimization (TCO) algorithm.

# Arguments
- `x::AbstractMatrix`: Matrix of relative prices.
- `w::Integer`: Window size.
- `horizon::Integer`: Investment horizon.
- `𝛾`: Rate of transaction cost.
- `η::Integer`: Smoothing parameter.
- `variant::Type{<:TCOVariant}`: Variant of the algorithm. Both `TCO1` and `TCO2` are implemented.

## Optional argument
- `b̂ₜ::Union{Nothing, AbstractVector}=nothing`: The first rebalanced portfolio. If `nothing` \
  is passed, a uniform portfolio will be used.

!!! warning "Beware!"
    `x` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["MSFT", "TSLA", "GOOGL", "NVDA"];

julia> querry = [get_prices(ticker, startdt="2024-01-01", enddt="2024-03-01")["adjclose"] for ticker in tickers];

julia> pr = stack(querry, dims=1);

julia> r = pr[:, 2:end]./pr[:, 1:end-1];

# TCO1
julia> model = tco(r, 5, 5, 0.04, 10, TCO1, [0.05, 0.05, 0.7, 0.2]);

julia> model.b
4×5 Matrix{Float64}:
 0.05  0.05  0.052937  0.0540085  0.0537137
 0.05  0.05  0.073465  0.0783877  0.0781003
 0.7   0.7   0.669571  0.657286   0.66002
 0.2   0.2   0.204027  0.210318   0.208166

# TCO2
julia> model = tco(r, 5, 5, 0.04, 10, TCO2, [0.05, 0.05, 0.7, 0.2]);

julia> model.b
4×5 Matrix{Float64}:
 0.05  0.0809567  0.0850694  0.0871646  0.0865584
 0.05  0.0809567  0.0830907  0.0890398  0.0885799
 0.7   0.730957   0.756827   0.746137   0.748113
 0.2   0.10713    0.0750128  0.0776584  0.0767483
```

# Reference
> [Transaction cost optimization for online portfolio selection](https://www.tandfonline.com/doi/full/10.1080/14697688.2017.1357831)
"""
function tco(
  x::AbstractMatrix,
  w::Integer,
  horizon::Integer,
  𝛾::AbstractFloat,
  η::Integer,
  variant::Type{<:TCOVariant},
  b̂ₜ::Union{Nothing, AbstractVector}=nothing
)
  n_assets, n_samples = size(x)
  n_samples-w≥horizon || ArgumentError("`n_samples-w` must be greater than or equal to \
  `horizon`. `n_samples` is the number of observations ($(n_samples))") |> throw
  horizon>0 || ArgumentError("`horizon` must be greater than 0. $horizon is passed.") |> throw
  w>1       || ArgumentError("`w` must be greater than 1. $w is passed.") |> throw
  η>0       || ArgumentError("`η` must be greater than 0. $η is passed.") |> throw
  0<𝛾≤1     || ArgumentError("Transaction rate (𝛾) should be in 0<𝛾≤1. $𝛾 is passed.") |> throw
  𝛾>0.05 && @warn "Tha passed transaction rate ($𝛾) is considered to be high. Due to the nature \
  of the algorithm, there might be no difference between the result of the algorithm, whether \
  it is `OTC1` or `OTC2`. The values lower than or equal to 0.05 are recommended."
  if isnothing(b̂ₜ)
    b̂ₜ = fill(1/n_assets, n_assets)
  else
    sum(b̂ₜ) ≈ 1.0 || ArgumentError("The sum of `b̂ₜ` must be equal to 1.0.") |> throw
    length(b̂ₜ) == n_assets || ArgumentError("The length of `b̂ₜ` must be equal to `n_assets` \
    ($(n_assets)).") |> throw
  end
  b        = similar(x, n_assets, horizon)
  b[:, 1] .= b̂ₜ
  λ        = 10*𝛾
  for t ∈ 1:horizon-1
    obj       = x̃ₜ₊₁func(variant, x[:, end-horizon-w+t+1:end-horizon+t], w)
    vₜ, v̄ₜ    = vₜv̄ₜfunc(obj, b̂ₜ)
    b̃         = b̃func(η, vₜ, v̄ₜ)
    bₜ₊₁      = bₜ₊₁func(b̂ₜ, b̃, λ)
    b[:, t+1] = normptf(bₜ₊₁)
    b̂ₜ        = b̂ₜfunc(x[:, end-horizon+t], b[:, t+1])
  end
  any(b.<0.) && b |> positify! |> normalizer!
  return OPSAlgorithm(n_assets, b, methodname(variant))
end
