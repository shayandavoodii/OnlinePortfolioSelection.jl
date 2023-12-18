module CWMRModelExt

using OnlinePortfolioSelection
using Distributions: Normal
using LinearAlgebra: diag, I, diagm
using JuMP:          Model, @variable, @constraint, @NLobjective, optimizer_with_attributes
using JuMP:          optimize!, value
using Ipopt:         Optimizer

bₜfunc(::Type{CWMRD}, μₜ::AbstractVector, ::AbstractMatrix) = μₜ

function bₜfunc(::Type{CWMRS}, μₜ::AbstractVector, Σₜ::AbstractMatrix)
  b̃ₜ = rand.(Normal.(μₜ, diag(Σₜ)))
  bₜ = projection(b̃ₜ)
  return bₜ
end

function projection(b̃ₜ::AbstractVector)
  n_assets = length(b̃ₜ)
  model = Model(optimizer_with_attributes(Optimizer, "print_level" => 0))
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
  Vₜ::T,
  ϕ::T,
  x̄ₜ::T,
  Wₜ::T,
  Mₜ::T,
  ϵ::T
) where T<:AbstractFloat
  a = 2ϕ*Vₜ^2-2ϕ*x̄ₜ*Vₜ*Wₜ
  b = 2ϕ*ϵ*Vₜ-2ϕ*Vₜ*Mₜ+Vₜ-x̄ₜ*Wₜ
  c = ϵ-Mₜ-ϕ*Vₜ
  OnlinePortfolioSelection.Δfunc(a, b, c)
end

function λₜ₊₁func(
  ::Type{Stdev},
  Vₜ::T,
  ϕ::T,
  x̄ₜ::T,
  Wₜ::T,
  Mₜ::T,
  ϵ::T
) where T<:AbstractFloat
  a = (Vₜ-x̄ₜ*Wₜ+(ϕ^2*Vₜ)/2)^2 - (ϕ^4*Vₜ^2)/4
  b = 2*(ϵ-Mₜ)*(Vₜ-x̄ₜ*Wₜ+(ϕ^2*Vₜ)/2)
  c = (ϵ-Mₜ)^2 - ϕ^2*Vₜ
  OnlinePortfolioSelection.Δfunc(a, b, c)
end

function μₜ₊₁func(
  μₜ::S,
  λₜ₊₁::T,
  Σₜ::AbstractMatrix,
  x̄ₜ::T,
  xₜ::S
) where {S<:AbstractVector, T<:AbstractFloat}
  n_assets = length(μₜ)
  μₜ₊₁ = μₜ - vec(permutedims(xₜ - x̄ₜ*ones(n_assets)) * (λₜ₊₁ * Σₜ))
  return μₜ₊₁
end

function Σₜ₊₁func(
  ::Type{Var},
  Σₜ::AbstractMatrix,
  λₜ₊₁::T,
  xₜ::AbstractVector,
  ϕ::T,
  ::T
) where T<:AbstractFloat
  Σₜ₊₁ = (Σₜ^-1 + 2λₜ₊₁ * ϕ * diagm(xₜ.^2))^-1
  return Σₜ₊₁ |> Matrix
end

function Σₜ₊₁func(
  ::Type{Stdev},
  Σₜ::AbstractMatrix,
  λₜ₊₁::T,
  xₜ::AbstractVector,
  ϕ::T,
  Vₜ::T
) where T<:AbstractFloat
  uₜ = (-λₜ₊₁*ϕ*Vₜ + √(λₜ₊₁^2*ϕ^2*Vₜ^2 + 4*Vₜ))/2
  Σₜ₊₁ = (Σₜ^-1 + λₜ₊₁ * (ϕ/uₜ) * diagm(xₜ.^2))^-1
  return Σₜ₊₁ |> Matrix
end

function normΣₜ₊₁(Σₜ₊₁::AbstractMatrix)
  m = size(Σₜ₊₁, 1)
  return Σₜ₊₁ ./ (m*sum(diag(Σₜ₊₁)))
end

checkuniformity(b::AbstractVector, n_asset::Int) = b == ones(n_asset)/n_asset

modelname(::Type{CWMRD}, ::Type{Var})                    = "CWMR-Var"
modelname(::Type{CWMRD}, ::Type{Stdev})                  = "CWMR-Stdev"
modelname(::Type{CWMRS}, ::Type{Var})                    = "CWMR-Var-s"
modelname(::Type{CWMRS}, ::Type{Stdev})                  = "CWMR-Stdev-s"
modelname(::Type{CWMRD}, ::Type{Var}, ::String)          = "CWMR-Var-Mix"
modelname(::Type{CWMRD}, ::Type{Stdev}, ::String)        = "CWMR-Stdev-Mix"
modelname(::Type{CWMRS}, ::Type{Var}, ::String)          = "CWMR-Var-s-Mix"
modelname(::Type{CWMRS}, ::Type{Stdev}, ::String)        = "CWMR-Stdev-s-Mix"

function OnlinePortfolioSelection.cwmr(
  rel_pr::AbstractMatrix,
  ϕ::AbstractFloat,
  ϵ::AbstractFloat,
  variant::Type{<:OnlinePortfolioSelection.CWMRVariant},
  ptfdis::Type{<:OnlinePortfolioSelection.PtfDisVariant}
)
  0. ≤ ϵ ≤ 1. || ArgumentError("ϵ must be in [0, 1]") |> throw
  0. ≤ ϕ || ArgumentError("ϕ must be non-negative") |> throw
  n_assets, n_days = size(rel_pr)
  μₜ = ones(n_assets)/n_assets
  Σₜ = I(n_assets)*(1/n_assets^2) |> Matrix
  b = similar(rel_pr, n_assets, n_days)
  for t ∈ 1:n_days
    b[:, t] = bₜfunc(variant, μₜ, Σₜ)
    Mₜ, Vₜ, Wₜ, x̄ₜ = calcvars(μₜ, Σₜ, rel_pr[:, t])
    λₜ₊₁ = λₜ₊₁func(ptfdis, Vₜ, ϕ, x̄ₜ, Wₜ, Mₜ, ϵ)
    μₜ₊₁ = μₜ₊₁func(μₜ, λₜ₊₁, Σₜ, x̄ₜ, rel_pr[:, t]) |> projection
    Σₜ₊₁ = Σₜ₊₁func(ptfdis, Σₜ, λₜ₊₁, rel_pr[:, t], ϕ, Vₜ) |> normΣₜ₊₁
    μₜ = μₜ₊₁
    Σₜ = Σₜ₊₁
  end
  if any(b .< 0.)
    b = max.(b, 0.)
    OnlinePortfolioSelection.normalizer!(b)
  end
  OPSAlgorithm(n_assets, b, modelname(variant, ptfdis))
end

function OnlinePortfolioSelection.cwmr(
  rel_pr::AbstractMatrix,
  ϕ::AbstractVector,
  ϵ::AbstractVector,
  variant::Type{<:OnlinePortfolioSelection.CWMRVariant},
  ptfdis::Type{<:OnlinePortfolioSelection.PtfDisVariant};
  adt_ptf::Union{Nothing, AbstractVector{<:AbstractMatrix}}=nothing
)
  n_assets, n_days = size(rel_pr)
  isnothing(adt_ptf) || all(x->size(x)==(n_assets, n_days), adt_ptf) || ArgumentError("The \
  size of each element of adt_ptf must be ($n_assets, $n_days)") |> throw
  all(0. .≤ ϵ .≤ 1.) || ArgumentError("All og the ϵ elements must be in [0, 1]") |> throw
  all(0. .≤ ϕ) || ArgumentError("All of the ϕ elements must be non-negative") |> throw
  if !isnothing(adt_ptf)
    for exp ∈ adt_ptf
      res = sum(exp)==n_days
      res || ArgumentError("For each element within `adt_ptf`, the sum of the columns must \
      be uniform. Got $(sum(exp, dims=1))") |> throw
      res = checkuniformity(exp[:, 1], n_assets)
      res || ArgumentError("The first portfolio (column) of each element of adt_ptf must be \
      uniform. Got $(exp[:, 1])") |> throw
    end
  end

  if isnothing(adt_ptf)
    adt_ptf = [eg(rel_pr).b]
  end
  repeatedϕ = repeat(ϕ, inner=length(ϵ))
  repeatedϵ = repeat(ϵ, length(ϕ))
  n_experts = length(repeatedϕ) + length(adt_ptf)
  Q = cwmr.(Ref(rel_pr), repeatedϕ, repeatedϵ, variant, ptfdis)
  Q = getproperty.(Q, :b)
  Q = [Q; adt_ptf]
  b = similar(rel_pr, n_assets, n_days)
  SₜQⱼxⁿ = ones(n_experts)
  for t ∈ 1:n_days
    numer = zeros(n_assets)
    for (idx, expert) ∈ enumerate(Q)
      @. numer += expert[:, t] * SₜQⱼxⁿ[idx]
    end
    denumer = sum(SₜQⱼxⁿ)
    b[:, t] = numer/denumer
    for (idx, expert) ∈ enumerate(Q)
      SₜQⱼxⁿ[idx] *= sum(expert[:, t].*rel_pr[:, t])
    end
  end
  return OPSAlgorithm(n_assets, b, modelname(variant, ptfdis, "CWMRMix"))
end

end #module
