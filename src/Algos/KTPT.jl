using JuMP, Ipopt, LinearAlgebra

p̃ₜ₊₁func(p::AbstractMatrix) = maximum(p, dims=2) |> vec

yₜ₊₁func(p̃ₜ₊₁::AbstractVector, p̂ₜ::AbstractVector, ν::AbstractFloat) = ν*p̃ₜ₊₁ .+ (1-ν)*p̂ₜ

function ẑₜfunc(yₜ₊₁::AbstractVector, Pₜ::AbstractMatrix, ϑ::AbstractFloat, γ::AbstractFloat)
  w = size(Pₜ, 2)
  model = Model(Ipopt.Optimizer)
  @variable(model, z[1:w])
  @expression(model, firstterm, √(sum((yₜ₊₁ - vec(Pₜ*z')).^2))^2)
  @expression(model, secondterm, 2ϑ*γ*sum(abs, z))
  @expression(model, thirdterm, (1-ϑ)*γ*√(sum(z.^2)))
  @objective(model, Min, firstterm + secondterm + thirdterm)
  optimize!(model)
  return value.(z)
end

ŷₜ₊₁func(Pₜ::AbstractMatrix, ẑₜ::AbstractVector) = Pₜ*ẑₜ' |> vec

signp(val) = val > 0

function λₜ₊₁func(P̃::AbstractMatrix, coeff::AbstractFloat)
  d, t = size(P̃)
  firstterm = coeff*ones(d)'
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

x̃ₜ₊₁func(x̂ₜ₊₁::AbstractVector) = x̂ₜ₊₁ .- mean(x̂ₜ₊₁)

function K̂ₜfunc(b̃ₜ::AbstractVector, x̃ₜ₊₁::AbstractVector, q)
  diagvals = exp.(-(abs.(b̃ₜ.-x̃ₜ₊₁)).^(1/q))
  return diagm(diagvals)
end
