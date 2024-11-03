module KTPTModelExt

using OnlinePortfolioSelection
using OnlinePortfolioSelection: positify!, normalizer!
using Lasso
using Ipopt: Optimizer
using JuMP:  Model, @variable, @constraint, @objective, optimizer_with_attributes
using JuMP:  optimize!, value
using LinearAlgebra: diagm, norm

p̃ₜ₊₁func(p::AbstractMatrix) = maximum(p, dims=2) |> vec

yₜ₊₁func(p̃ₜ₊₁::AbstractVector, p̂ₜ::AbstractVector, ν::AbstractFloat) = ν*p̃ₜ₊₁ .+ (1-ν)*p̂ₜ

"""
    ẑₜfunc(yₜ₊₁::AbstractVector, Pₜ::AbstractMatrix, ϑ::AbstractFloat, 𝛾::AbstractFloat)

# Arguments
- `yₜ₊₁::AbstractVector`: The vector of size `n_assets` at time `t+1`.
- `Pₜ::AbstractMatrix`: The matrix of size
"""
function ẑₜfunc(yₜ₊₁::AbstractVector, Pₜ::AbstractMatrix)
  w = size(Pₜ, 2)
  m  = fit(GammaLassoPath, Pₜ, yₜ₊₁, α=0.99)
  coefs = coef(m)
  ẑₜ::Vector{Float64} = coefs.nzval[1:w]
  return ẑₜ
end

function projection(b̂ₜ₊₁::AbstractVector)
  d = length(b̂ₜ₊₁)
  model = Model(optimizer_with_attributes(Optimizer, "print_level" => 0))
  @variable(model, b[1:d])
  @constraint(model, b .>= 0)
  @constraint(model, sum(b) == 1)
  @objective(model, Min, sum((b .- b̂ₜ₊₁).^2))
  optimize!(model)
  return value.(b)
end

ŷₜ₊₁func(Pₜ::AbstractMatrix, ẑₜ::AbstractVector) = Pₜ*ẑₜ |> vec

signp(val::Real) = val > 0 ? 1 : 0

givewindow(m::AbstractMatrix, t::Integer, w::Integer) = t<2w+1 ? m[:, 1:t] : m[:, t-2w+2:t]

"""
    λₜ₊₁func(P̃::AbstractMatrix, coeff::AbstractFloat, t::Integer, w::Integer)

# Arguments
- `t::Integer`: The current day index.
- `w::Integer`: Window size.
"""
function λₜ₊₁func(P̃::AbstractMatrix, coeff::AbstractFloat, t::Integer, w::Integer)
  d, _       = size(P̃)
  P̃ₜ         = givewindow(P̃, t, w)
  P̃ₜ₋₁       = givewindow(P̃, t-1, w)
  P̃ₜ₋₂       = givewindow(P̃, t-2, w)
  if t-2≤2w+1
    sizes = size.([P̃ₜ₋₂, P̃ₜ₋₁, P̃ₜ], 2)
    minsizes = minimum(sizes)
    P̃ₜ         = P̃[:, end-minsizes+1:end]
    P̃ₜ₋₁       = P̃ₜ₋₁[:, end-minsizes+1:end]
    P̃ₜ₋₂       = P̃ₜ₋₂[:, end-minsizes+1:end]
  end
  firstterm  = coeff*ones(d)'
  secondterm = signp.((P̃ₜ - P̃ₜ₋₁).*(P̃ₜ₋₂ - P̃ₜ₋₁))
  thirdterm  = ones(2w-1)
  return firstterm * (secondterm * thirdterm)
end

ιfunc!(v::AbstractVector) = v[v.>1] .= 1.

function p̂ₜ₊₁func(λₜ₊₁::AbstractFloat, xₜ::AbstractVector, p̃ₜ₊₁::AbstractVector, ŷₜ₊₁::AbstractVector)
  val = λₜ₊₁./(2xₜ)
  ιfunc!(val)
  return val.*p̃ₜ₊₁ .+ (1 .- val).*ŷₜ₊₁
end

b̃ₜfunc(b̂ₜ::AbstractVector) = b̂ₜ .- mean(b̂ₜ)

x̃ₜ₊₁func(x̂ₜ₊₁::AbstractVector) = b̃ₜfunc(x̂ₜ₊₁)

function K̂ₜfunc(b̃ₜ::AbstractVector, x̃ₜ₊₁::AbstractVector, q::Integer)
  diagvals = @. exp(-(abs(b̃ₜ-x̃ₜ₊₁))^(1/q))
  return diagm(diagvals)
end

function bₜ₊₁func(x̃ₜ₊₁::AbstractVector, b̂ₜ₊₁::AbstractVector, K̂ₜ::AbstractMatrix, η::Integer)
  if norm(x̃ₜ₊₁)==0.
    bₜ₊₁ = b̂ₜ₊₁
  else
    bₜ₊₁ = b̂ₜ₊₁ .+ η*K̂ₜ*x̃ₜ₊₁
  end
  return bₜ₊₁
end

function OnlinePortfolioSelection.ktpt(
  prices::AbstractMatrix,
  horizon::S,
  w::S,
  q::S,
  η::S,
  ν::T,
  p̂ₜ::AbstractVector,
  b̂ₜ::Union{Nothing, AbstractVector{T}}
) where {S<:Integer, T<:AbstractFloat}
  n_assets, n_samples = size(prices)
  horizon>0 || ArgumentError("The horizon should be greater than 0. It's '$horizon'") |> throw
  w>1       || ArgumentError("The window size should be greater than 1. It's '$w'") |> throw
  q>1       || ArgumentError("The value of `q` should be greater than 1. It's '$q'") |> throw
  η>0       || ArgumentError("The value of `η` should be greater than 0. It's '$η'") |> throw
  0≤ν≤1     || ArgumentError("The value of `ν` should be in the range [0, 1]. It's '$ν'") |> throw
  length(p̂ₜ)==size(prices, 1) || ArgumentError("The size of `p̂ₜ` should be equal to the \
  number of assets. It's '$(length(p̂ₜ))'") |> throw
  isnothing(b̂ₜ) || length(b̂ₜ)==size(prices, 1) || ArgumentError("The size of `b̂ₜ` should be \
  equal to the number of assets. It's '$(length(b̂ₜ))'") |> throw
  n_samples-horizon+1-2w>0 || ArgumentError("Either provide more data samples, or decrease \
  the horizon ($horizon), or decrease the window size ($w). The expression \
  'n_samples-horizon+1-2w' should evaluate to a positive number (currently \
  $(n_samples-horizon+1-2w)).") |> throw
  size(prices, 2)≥n_samples-horizon+1-2w || ArgumentError("The number of samples should be \
  greater than or equal to the expression 'n_samples-horizon+1-2w'. The expression \
  'n_samples-horizon+1-2w' should evaluate to a positive number (currently \
  $(n_samples-horizon+1-2w)).") |> throw
  n_samples-horizon+1>0 || ArgumentError("the expression `n_samples-horizon>-1` should stand \
  still. Either decrease the `horizon` value or increase the number of samples.") |> throw
  x    = prices[:, 2:end] ./ prices[:, 1:end-1]
  b̂ₜ₊₁ = similar(prices, n_assets, horizon)
  if isnothing(b̂ₜ)
    b̂ₜ₊₁[:, 1] .= 1/n_assets
  else
    sum(b̂ₜ)==1. || ArgumentError("Sum of the passed weights should sum to 1. Its '$(sum(b̂ₜ))'") |> throw
    b̂ₜ₊₁[:, 1] .= b̂ₜ
  end
  _1 = n_samples-horizon+1
  for t ∈ 1:horizon-1
    # The index of the current time
    t_ = n_samples-horizon+t
    if t_<w
      # Vector of size `n_assets`
      p̃ₜ₊₁ = p̃ₜ₊₁func(prices[:, _1:t_])
    else
      p̃ₜ₊₁ = p̃ₜ₊₁func(prices[:, t_-w+1:t_])
    end
    # Vector of size `n_assets`
    yₜ₊₁ = yₜ₊₁func(p̃ₜ₊₁, p̂ₜ, ν)
    if t_<w
      # Vector of size `n_assets`
      ẑₜ = ẑₜfunc(yₜ₊₁, prices[:, 1:t_])
    else
      ẑₜ = ẑₜfunc(yₜ₊₁, prices[:, t_-w+1:t_])
    end
    # A vector of size `n_assets`
    ŷₜ₊₁  = ŷₜ₊₁func(prices[:, t_-w+1:t_], ẑₜ)
    coeff = 1/(2w-1)n_assets
    λₜ₊₁  = λₜ₊₁func(prices, coeff, t_, w)
    p̂ₜ₊₁  = p̂ₜ₊₁func(λₜ₊₁, x[:, t_], p̃ₜ₊₁, ŷₜ₊₁)
    x̂ₜ₊₁  = p̂ₜ₊₁./prices[:, t_]
    b̃ₜ    = b̃ₜfunc(b̂ₜ₊₁[:, t])
    x̃ₜ₊₁  = x̃ₜ₊₁func(x̂ₜ₊₁)
    K̂ₜ    = K̂ₜfunc(b̃ₜ, x̃ₜ₊₁, q)
    bₜ₊₁  = bₜ₊₁func(x̃ₜ₊₁, b̂ₜ₊₁[:, t], K̂ₜ, η)
    b̂ₜ₊₁[:, t+1] .= projection(bₜ₊₁)
  end
  any(b̂ₜ₊₁.<0.) && b̂ₜ₊₁ |> positify! |> normalizer!
  return OPSAlgorithm(n_assets, b̂ₜ₊₁, "KTPT")
end

end #module
