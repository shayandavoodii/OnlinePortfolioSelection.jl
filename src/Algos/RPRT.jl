function 𝝋hatₜ₊₁func(xₜ::AbstractVector, ϑ::AbstractFloat, 𝝋hatₜ::AbstractVector)
  iszero(𝝋hatₜ) && return xₜ
  𝜸ₜ₊₁ = 𝜸ₜ₊₁func(xₜ, 𝝋hatₜ, ϑ)
  return @. 𝜸ₜ₊₁ + (1 - 𝜸ₜ₊₁) * (𝝋hatₜ / xₜ)
end

@inline 𝜸ₜ₊₁func(xₜ::AbstractVector, 𝝋hatₜ::AbstractVector, ϑ::AbstractFloat) =
  @. ϑ*xₜ / (ϑ*xₜ + 𝝋hatₜ)

@inline Dₜ₊₁funct(x̂ₛₘₐₜ₊₁::AbstractVector) = diagm(x̂ₛₘₐₜ₊₁)

function bₜ₊₁func(
  b̂ₜ::AbstractVector,
  λ̂ₜ₊₁::AbstractFloat,
  Dₜ₊₁::AbstractMatrix,
  𝝋hatₜ₊₁::AbstractVector
)
  return b̂ₜ .+ λ̂ₜ₊₁ .* Dₜ₊₁ * permutedims(𝝋hatₜ₊₁ .- mean(𝝋hatₜ₊₁))' |> vec
end

function λ̂ₜ₊₁func(𝝋hatₜ₊₁::AbstractVector, b̂::AbstractVector, 𝜖::Integer)
  cond    = norm(𝝋hatₜ₊₁ .- mean(𝝋hatₜ₊₁))^2
  if cond==0
    λ̂ₜ₊₁ = 0.
  else
    λ̂ₜ₊₁ = max(0., 𝜖 - sum(b̂.*𝝋hatₜ₊₁)) / cond
  end
  return λ̂ₜ₊₁
end

"""
    function rprt(
      rel_pr::AbstractMatrix{T},
      horizon::Integer,
      w::Integer=5,
      ϑ::T=0.8,
      𝜖::Integer=50,
      bₜ::Union{Nothing, AbstractVector}=nothing
    ) where T<:AbstractFloat

Run RPRT algorithm.

# Arguments
- `rel_pr::AbstractMatrix{T}`: A `asset × samples` matrix of relative prices.
- `horizon::Integer`: Investment period.
- `w::Integer=5`: Window length.
- `ϑ::T=0.8`: Mixing parameter.
- `𝜖::Integer=50`: Expected profiting level.
- `bₜ::Union{Nothing, AbstractVector}=nothing`: Initial portfolio. Default value would \
  lead to a uniform portfolio.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Examples
```julia
julia> using OnlinePortfolioSelection

julia> rel_pr = rand(3, 6);
julia> horizon = 2
julia> window = 3
julia> v = 0.2
julia> eps = 10
julia> b = [0.5, 0.3, 0.2];

julia> m_rprt = rprt(rel_pr, horizon, window, v, eps, b);

julia> m_rprt.b
3×2 Matrix{Float64}:
 0.5  1.0
 0.3  0.0
 0.2  2.03615e-10

julia> sum(m_rprt.b, dims=1) .|> isapprox(1.) |> all
true
```

# Reference
> [Reweighted Price Relative Tracking System for Automatic Portfolio Optimization](https://ieeexplore.ieee.org/document/8411138/)
"""
function rprt(
  rel_pr::AbstractMatrix{T},
  horizon::Integer,
  w::Integer=5,
  ϑ::T=0.8,
  𝜖::Integer=50,
  bₜ::Union{Nothing, AbstractVector}=nothing
) where T<:AbstractFloat

  ϑ>0 || ArgumentError("`ϑ` should be greater than 0. $ϑ is passed") |> throw
  𝜖>0 || ArgumentError("`𝜖` should be greater than 0. $𝜖 is passed") |> throw
  w>2 || ArgumentError("`w` should be greater than 2. $w is passed") |> throw
  horizon>0 || ArgumentError("`horizon` should be greater than 0. $horizon is passed") |> throw
  n_assets, n_samples = size(rel_pr)
  n_samples-horizon-w+2+1>0 || ArgumentError("The passed values for `horizon` and `w` are \
    not suitable for the number of samples that you've passed. Either increase the samples \
    or decrease the `horizon` and/or `w`. Considering your specified values for `w` and `ϑ`, \
    you should have at least $(horizon+w-2) samples."
  ) |> throw
  if isnothing(bₜ)
    bₜ = fill(1/n_assets, n_assets)
  else
    length(bₜ) == n_assets || ArgumentError("The length of `bₜ` should be equal to the number \
      of assets. $(length(bₜ)) is passed"
    ) |> throw
    sum(bₜ) ≈ 1. || ArgumentError("The sum of `bₜ` should be equal to 1. $(sum(bₜ)) is passed") |> throw
  end
  b̂ = similar(rel_pr, n_assets, horizon)
  b̂[:, 1] .= bₜ
  𝝋hatₜ₊₁  = zeros(T, n_assets)
  @inbounds for t ∈ 1:horizon-1
    x̂ₛₘₐₜ₊₁ = pred_relpr(SMAR(), rel_pr[:, end-horizon-w+2+t:end-horizon+t], w)
    Dₜ₊₁    = Dₜ₊₁funct(x̂ₛₘₐₜ₊₁)
    𝝋hatₜ₊₁ = 𝝋hatₜ₊₁func(rel_pr[:, end-horizon+t], ϑ, 𝝋hatₜ₊₁)
    λ̂ₜ₊₁    = λ̂ₜ₊₁func(𝝋hatₜ₊₁, b̂[:, t], 𝜖)
    bₜ₊₁    = bₜ₊₁func(b̂[:, t], λ̂ₜ₊₁, Dₜ₊₁, 𝝋hatₜ₊₁)
    b̂[:, t+1] = b̂ₜ₊₁func(bₜ₊₁)
  end
  any(b̂.<0) && b̂ |> positify! |> normalizer!

  return OPSAlgorithm(n_assets, b̂, "RPRT")
end
