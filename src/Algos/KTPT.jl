using JuMP, Ipopt, LinearAlgebra, Statistics

p̃ₜ₊₁func(p::AbstractMatrix) = maximum(p, dims=2) |> vec

yₜ₊₁func(p̃ₜ₊₁::AbstractVector, p̂ₜ::AbstractVector, ν::AbstractFloat) = ν*p̃ₜ₊₁ .+ (1-ν)*p̂ₜ

function ẑₜfunc(yₜ₊₁::AbstractVector, Pₜ::AbstractMatrix, ϑ::AbstractFloat, 𝛾::AbstractFloat)
  w     = size(Pₜ, 2)
  model = Model(optimizer_with_attributes(Optimizer, "print_level" => 0))
  @variable(model, z[1:w])
  @expression(model, firstterm, √(sum((yₜ₊₁ - vec(Pₜ*z')).^2))^2)
  @expression(model, secondterm, 2ϑ*𝛾*sum(abs, z))
  @expression(model, thirdterm, (1-ϑ)*𝛾*√(sum(z.^2)))
  @objective(model, Min, firstterm + secondterm + thirdterm)
  optimize!(model)
  return value.(z)
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

ŷₜ₊₁func(Pₜ::AbstractMatrix, ẑₜ::AbstractVector) = Pₜ*ẑₜ' |> vec

signp(val::Real) = val > 0

function λₜ₊₁func(P̃::AbstractMatrix, coeff::AbstractFloat)
  d, t       = size(P̃)
  firstterm  = coeff*ones(d)'
  secondterm = signp.((P̃[:, t].-P̃[:, t-1]).*(P̃[:, t-2].-P̃[:, t-1])) * ones(Int((coeff*d)^-1))''
  return firstterm * secondterm
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

function bₜ₊₁func(x̃ₜ₊₁::AbstractVector, b̂ₜ₊₁::AbstractVector, K̂ₜ::AbstractMatrix, η::AbstractFloat)
  if norm(x̃ₜ₊₁)==0.
    bₜ₊₁ = b̂ₜ₊₁
  else
    bₜ₊₁ = b̂ₜ₊₁ .+ η*K̂ₜ*x̃ₜ₊₁
  end
  return bₜ₊₁
end

function ktpt(
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
  x    = prices[:, 2:end] ./ prices[:, 1:end-1]
  b̂ₜ₊₁ = similar(prices, n_assets, horizon)
  if isnothing(b̂ₜ)
    b̂ₜ₊₁[:, 1] .= 1/n_assets
  else
    b̂ₜ₊₁[:, 1] .= b̂ₜ
  end
  _1 = n_samples-horizon+1
  for t ∈ 1:horizon
    t_ = n_samples-horizon+t
    if t<w
      p̃ₜ₊₁ = p̃ₜ₊₁func(prices[:, _1:t_])
    else
      p̃ₜ₊₁ = p̃ₜ₊₁func(prices[:, t_-w+1:t_])
    end
    yₜ₊₁ = yₜ₊₁func(p̃ₜ₊₁, p̂ₜ, ν)
    if t<w
      ẑₜ = ẑₜfunc(yₜ₊₁, prices[:, _1:t_], η, 1)
    else
      ẑₜ = ẑₜfunc(yₜ₊₁, prices[:, t_-w+1:t_], η, 1)
    end
    ŷₜ₊₁ = ŷₜ₊₁func(prices[:, t_-w+1:t_], ẑₜ)
    if t<2w+1
      λₜ₊₁ = λₜ₊₁func(prices[:, t_-3:t_], η)
    else
      λₜ₊₁ = λₜ₊₁func(prices[:, t_-2w:t_], η)
    end
    p̂ₜ₊₁ = p̂ₜ₊₁func(λₜ₊₁, x[:, t_], p̃ₜ₊₁, ŷₜ₊₁)
    x̂ₜ₊₁ = p̂ₜ₊₁./prices[:, t_]
    b̃ₜ   = b̃ₜfunc(b̂ₜ₊₁[:, t])
    x̃ₜ₊₁ = x̃ₜ₊₁func(x̂ₜ₊₁)
    K̂ₜ   = K̂ₜfunc(b̃ₜ, x̃ₜ₊₁, q)
    bₜ₊₁ = bₜ₊₁func(x̃ₜ₊₁, b̂ₜ₊₁[:, t], K̂ₜ, η)
    b̂ₜ₊₁[:, t] .= projection(bₜ₊₁)
  end
  return b̂ₜ₊₁
end

p = rand(4, 100);
h = 10;
w = 5;
q = 6;
η = 1000;
ν = 0.5;
p̂ = rand(4);
b̂ = nothing;
ktpt(p, h, w, q, η, ν, p̂, b̂)

# TODO
#[ ] There should be a procedure to find the suitable 𝛾 value (page 7)
