abstract type CWMRVariant end
abstract type PtfDisVariants end

struct CWMRD<:CWMRVariant end
struct CWMRS<:CWMRVariant end
struct CWMRMix<:CWMRVariant end

struct Var<:PtfDisVariants end
struct Stdev<:PtfDisVariants end

using Distributions
using JuMP
using Ipopt

bₜfunc(::Type{CWMRD}, μₜ::AbstractVector, Σₜ::AbstractMatrix) = μₜ

function bₜfunc(::Type{CWMRS}, μₜ::AbstractVector, Σₜ::AbstractMatrix)
  b̃ₜ = rand.(Normal.(μₜ, diag(Σₜ)))
  bₜ = projection(b̃ₜ)
  return bₜ
end

function projection(b̃ₜ::AbstractVector)
  n_assets = length(b̃ₜ)
  model = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
  @variable(model, 0. ≤ b[i=1:n_assets] ≤ 1.)
  @constraint(model, sum(b) == 1.)
  @NLobjective(model, Min, sum((b[i] - b̃ₜ[i])^2 for i=1:n_assets))
  optimize!(model)
  return value.(b)
end

function calcvars(
  μₜ::AbstractVector,
  Σₜ::AbstractMatrix,
  xₜ::AbstractVector
)
  n_assets = length(μₜ)
  Mₜ = sum(μₜ.*xₜ)
  xₜᵀ = permutedims(xₜ)
  Vₜ = xₜᵀ * Σₜ * permutedims(xₜᵀ) |> only
  Wₜ = xₜᵀ * Σₜ * ones(n_assets, 1) |> only
  x̄ₜ = sum(diag(Σₜ) .* xₜ)./sum(diag(Σₜ))

  return Mₜ, Vₜ, Wₜ, x̄ₜ
end

function λₜ₊₁func(
  ::Type{Var},
  Vₜ::AbstractFloat,
  ϕ::AbstractFloat,
  x̄ₜ::AbstractFloat,
  Wₜ::AbstractFloat,
  Mₜ::AbstractFloat,
  ϵ::AbstractFloat
)
  a = 2ϕ*Vₜ^2-2ϕ*x̄ₜ*Vₜ*Wₜ
  b = 2ϕ*ϵ*Vₜ-2ϕ*Vₜ*Mₜ+Vₜ-x̄ₜ*Wₜ
  c = ϵ-Mₜ-ϕ*Vₜ
  Δfunc(a, b, c)
end

function λₜ₊₁func(
  ::Type{Stdev},
  Vₜ::AbstractFloat,
  ϕ::AbstractFloat,
  x̄ₜ::AbstractFloat,
  Wₜ::AbstractFloat,
  Mₜ::AbstractFloat,
  ϵ::AbstractFloat
)
  a = (Vₜ-x̄ₜ*Wₜ+(ϕ^2*Vₜ)/2)^2 - (ϕ^4*Vₜ^2)/4
  b = 2*(ϵ-Mₜ)*(Vₜ-x̄ₜ*Wₜ+(ϕ^2*Vₜ)/2)
  c = (ϵ-Mₜ)^2 - ϕ^2*Vₜ
  Δfunc(a, b, c)
end

function Δfunc(a::T, b::T, c::T) where T<:AbstractFloat
  Δ = b^2-4*a*c
  if iszero(Δ)
    γ = -b/(2a)
    return max(0., γ)
  elseif Δ > 0
    γₜ₁ = (-b+sqrt(Δ))/(2a)
    γₜ₂ = (-b-sqrt(Δ))/(2a)
    return max(0., γₜ₁, γₜ₂)
  else
    return 0.
  end
end

function μₜ₊₁func(μₜ::AbstractVector, λₜ₊₁::AbstractFloat, Σₜ::AbstractMatrix, x̄ₜ::AbstractFloat, xₜ::AbstractVector)
  n_assets = length(μₜ)
  μₜ₊₁ = μₜ - vec(permutedims(xₜ - x̄ₜ*ones(n_assets)) * (λₜ₊₁ * Σₜ))
  return μₜ₊₁
end

function Σₜ₊₁func(
  ::Type{Var},
  Σₜ::AbstractMatrix,
  λₜ₊₁::AbstractFloat,
  xₜ::AbstractVector,
  ϕ::AbstractFloat,
  Vₜ::AbstractFloat
)
  Σₜ₊₁ = (Σₜ^-1 + 2λₜ₊₁ * ϕ * diagm(xₜ.^2))^-1
  return Σₜ₊₁
end

function Σₜ₊₁func(
  ::Type{Stdev},
  Σₜ::AbstractMatrix,
  λₜ₊₁::AbstractFloat,
  xₜ::AbstractVector,
  ϕ::AbstractFloat,
  Vₜ::AbstractFloat
)
  uₜ = (-λₜ₊₁*ϕ*Vₜ + √(λₜ₊₁^2*ϕ^2*Vₜ^2 + 4*Vₜ))/2
  Σₜ₊₁ = (Σₜ^-1 + λₜ₊₁ * (ϕ/uₜ) * diagm(xₜ.^2))^-1
  return Σₜ₊₁
end

function normΣₜ₊₁(Σₜ₊₁::AbstractMatrix)
  m = size(Σₜ₊₁, 1)
  return Σₜ₊₁ ./ (m*sum(diag(Σₜ₊₁)))
end

function cwmr(rel_pr::AbstractMatrix, ϕ::AbstractFloat, ϵ::AbstractFloat, variant::Type{<:CWMRVariant}, ptfdis::Type{<:PtfDisVariants})
  0. ≤ ϵ ≤ 1. || ArgumentError("ϵ must be in [0, 1]") |> throw
  n_assets, n_days = size(rel_pr)
  μₜ = ones(n_assets)/n_assets
  Σₜ = I(n_assets)*(1/n_assets^2)
  b = similar(rel_pr, n_assets, n_days)
  for t ∈ 1:n_days
    b[:, t] = bₜfunc(variant, μₜ, Σₜ)
    Mₜ, Vₜ, Wₜ, x̄ₜ = calcvars(μₜ, Σₜ, rel_pr[:, t])
    λₜ₊₁ = λₜ₊₁func(ptfdis, Vₜ, ϕ, x̄ₜ, Wₜ, Mₜ, ϵ)
    μₜ₊₁ = μₜ₊₁func(μₜ, λₜ₊₁, Σₜ, x̄ₜ, rel_pr[:, t])
    Σₜ₊₁ = Σₜ₊₁func(ptfdis, Σₜ, λₜ₊₁, rel_pr[:, t], ϕ, Vₜ)
    Σₜ₊₁ = normΣₜ₊₁(Σₜ₊₁)
    μₜ₊₁ = projection(μₜ₊₁)
    μₜ = μₜ₊₁
    Σₜ = Σₜ₊₁
  end
  if any(b .< 0.)
    b = max.(b, 0.)
    normalizer!(b)
  end
  return b
end

r = cwmr(rand(3, 10).+3, 0.5, 0.1, CWMRS, Var)
sum(r, dims=1) .|> isapprox(1.) |> all
