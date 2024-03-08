"""
    spolc(x::AbstractMatrix, 𝛾::AbstractFloat, w::Integer)

Run loss control strategy with a rank-one covariance estimate for short-term portfolio \
optimization (SPOLC).

# Arguments
- `x::AbstractMatrix`: Matrix of relative prices.
- `𝛾::AbstractFloat`: Constraint parameter.
- `w::Integer`: Window size.

!!! warning "Beware!"
    `x` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of [`OPSAlgorithm`](@ref).

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "AMZN", "GOOG", "MSFT"];

julia> querry = [get_prices(ticker, startdt="2019-01-01", enddt="2019-01-25")["adjclose"] for ticker in tickers];

julia> prices = stack(querry, dims=1);

julia> rel_pr = prices[:, 2:end] ./ prices[:, 1:end-1];

julia> model = spolc(rel_pr, 0.025, 5);

julia> model.b
4×15 Matrix{Float64}:
 0.25  0.197923  0.244427  0.239965  …  0.999975    8.49064e-6  2.41014e-6
 0.25  0.272289  0.251802  0.276544     1.57258e-5  0.999983    0.999992
 0.25  0.269046  0.255524  0.240024     6.50008e-6  5.94028e-6  3.69574e-6
 0.25  0.260742  0.248247  0.243466     2.99939e-6  3.04485e-6  1.56805e-6

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```

# Reference
> [Loss Control with Rank-one Covariance Estimate for Short-term Portfolio Optimization](https://dl.acm.org/doi/abs/10.5555/3455716.3455813)
"""
function spolc(x::AbstractMatrix, 𝛾::AbstractFloat, w::Integer)
  𝛾>0 || ArgumentError("`𝛾` should be greater than 0. $𝛾 is passed.") |> throw
  w>1 || ArgumentError("`w` should be more than 1. $w is passed.") |> throw
  n_assets, T = size(x)
  b = similar(x)
  b[:, 1] .= 1/n_assets
  q = zeros(length(x))
  for t ∈ 1:T-1
    if t==1
      q = x[:, 1]
      b̂ = simplexproj(q, 1)
    elseif t<w+1
      q = x[:, t]
      b̂ = simplexproj(q, 1)
    else
      xbefore = x[:, t-w+1:t]
      b̂ = main(xbefore, 𝛾)
    end
    b[:, t+1] = b̂
  end
  return OPSAlgorithm(n_assets, b, "SPOLC")
end

function simplexproj(v::AbstractVector, b::Integer)
  while maximum(abs.(v))>1e6
    @. v = v/2
  end
  u = sort(v, rev=true)
  sv = cumsum(u)
  ρ = findlast(u.>(sv.-b)./(1:length(u)))
  θ = (sv[ρ] - b)/ρ
  w = max.(v .- θ, 0)
  return w
end

function main(x::AbstractMatrix, 𝛾::AbstractFloat)
  n_assets, n_days = size(x)
  H = zeros(n_assets+1, n_assets+1)
  U_tmp,Sig_tmp,V_tmp = svd(x)
  S = diagm(Sig_tmp)
  tol = maximum((n_days, n_days))*S[1]*eps(eltype(x))
  r = sum(S .> tol)
  U = U_tmp[:, 1:r]
  V = V_tmp[:, 1:r]
  S = S[1:r]
  Sig = diagm(S)
  Sig1 = Sig.^(2)
  Sig2 = Sig1.-Sig*V'*ones(n_days, n_days)*V*Sig/n_days
  ζ = Sig1[1, 1]/sqrt(tr(Sig2))/n_assets/(n_days-1)
  Htmp2 = U[:, 1]*ζ*U[:, 1]'
  H[1:n_assets, 1:n_assets] = Htmp2
  f = vcat(zeros(n_assets), 1)
  A = vcat(-x, ones(1, n_days))
  return ẑfunc(𝛾, H, f, A)
end

function ẑfunc(𝛾::AbstractFloat, H::AbstractMatrix, f::AbstractVector, A::AbstractMatrix)
  n_assets = size(A, 1)
  model = Model(optimizer_with_attributes(Optimizer, "print_level" => 0))
  @variable(model, z[1:n_assets])
  @constraint(model, z'*A .<= 0)
  @constraint(model, 0. .≤ z[1:n_assets] .≤ 1.)
  @constraint(model, sum(z)==1)
  @objective(model, Min, 𝛾*z'*H*z+f'*z)
  optimize!(model)
  return value.(z)[1:end-1]
end
