setdiag!(A::AbstractMatrix, d::Bool) = A[diagind(A)] .= d

"""
    DCᵥᵢfunc(I::AbstractMatrix, vᵢ::Integer)

Calculate the Degree Centrality of a vertex vᵢ in a graph represented by the
adjacency matrix I.

# Arguments
- `I::AbstractMatrix`: The adjacency matrix of the graph.
- `vᵢ::Integer`: The vertex of interest.

# Returns
- `::Integer`: The degree centrality of vᵢ.

# Examples
```julia
julia> a = rand(3, 3)
3×3 Matrix{Float64}:
 0.200694  0.619398  0.571838
 0.105686  0.273862  0.904177
 0.306708  0.208045  0.269078

julia> DCᵥᵢfunc(a, 3)
1.476015602983394
"""
function DCᵥᵢfunc(I::AbstractMatrix, vᵢ::Integer)
  return sum(I[:, vᵢ]) - I[vᵢ, vᵢ]
end

function doublStochMat(S::AbstractMatrix)
  n = size(S, 1)
  𝜚 = max(maximum(sum(S, dims=1)), maximum(sum(S, dims=2)))
  𝜄 = 𝜚*n-sum(S)
  A = similar(S)
  for i ∈ 1:n
    for j ∈ 1:n
      A[i, j] = 𝜚^-1*S[i, j]+(𝜚*𝜄)^-1*(𝜚-sum(S[i, :]))*(𝜚-sum(S[:, j]))
    end
  end
  return A
end

function Afunc(x::AbstractMatrix, ηₖ::AbstractFloat, n::Integer)
  corrmat = cor(x, dims=2)
  Eₛ      = corrmat .> ηₖ
  setdiag!(Eₛ, false)
  S       = max.(corrmat, ηₖ)
  DC      = sum(Eₛ, dims=1) |> vec
  Vₜₒₚ    = sortperm(DC, rev=true)[1:n]
  Sₜₒₚ    = S[Vₜₒₚ, Vₜₒₚ]
  A       = doublStochMat(Sₜₒₚ)
  return A, Vₜₒₚ
end

v̂ᵢfunc(b̂::AbstractVector, A::AbstractMatrix) = permutedims(A)*b̂

function d̂ᵢᵏfunc(b::AbstractVector, x::AbstractVector)
  n = length(b)
  return -1/n*(x/sum(b.*x))
end

function ŷᵢfunc(v̂ᵢ::AbstractVector, x::AbstractVector, b::AbstractVector, α::AbstractFloat)
  d̂ᵢᵏ = d̂ᵢᵏfunc(b, x)
  return v̂ᵢ.-α*d̂ᵢᵏ
end

function b̂ᵢfunc(ŷᵢ::AbstractVector)
  n_assets = length(ŷᵢ)
  model    = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
  @variable(model, b[i=1:n_assets])
  @constraint(model, sum(b) == 1.)
  @NLobjective(model, Min, sum((b[i] - ŷᵢ[i])^2 for i=1:n_assets))
  optimize!(model)
  return value.(b)
end

"""
    dmr(
      x::AbstractMatrix,
      horizon::Integer,
      α::Union{Nothing, AbstractVector{<:AbstractFloat}},
      n::Integer,
      w::Integer,
      η::AbstractFloat=0.
    )

Run Distributed Mean Reversion (DMR) strategy.

# Arguments
- `x::AbstractMatrix`: A matrix of asset price relatives.
- `horizon::Integer`: Investment horizon.
- `α::Union{Nothing, AbstractVector{<:AbstractFloat}}`: Vector of step sizes. If `nothing` \
  is passed, the algorithm itself determines the values.
- `w::Integer`: Window size.
- `η::AbstractFloat=0.`: Threshold.

# Returns
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> assets = [
         "MSFT", "META", "GOOG", "AAPL", "AMZN", "TSLA", "NVDA", "PYPL", "ADBE", "NFLX", "MMM", "ABT", "ABBV", "ABMD", "ACN", "ATVI", "ADSK", "ADP", "AZN", "AMGN", "AVGO", "BA"
       ]

julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2021-01-01")["adjclose"] for ticker=assets]

julia> prices = stack(querry, dims=1)

julia> x = prices[:, 2:end]./prices[:, 1:end-1]

julia> eta = 0.

julia> alpha = nothing

julia> n = 10

julia> w = 4

julia> horizon = 50

julia> model = dmr(x, horizon, eta, alpha, n, w);

julia> model.b
22×50 Matrix{Float64}:
 0.0454545  0.0910112   0.0909008    …  0.0907232    0.090959     0.0909736
 0.0454545  0.00706777  0.00706777      0.00706777   0.00706777   0.0978817
 0.0454545  0.0954079   0.095159        0.00432265   0.00432265   0.0955929
 0.0454545  0.0964977   0.0962938       0.0960025    0.0967765    0.0966751
 0.0454545  0.00476753  0.0957164       0.0956522    0.0957777    0.00476753
 0.0454545  0.00550015  0.00550015   …  0.00550015   0.00550015   0.00550015
 0.0454545  0.00426904  0.0952782       0.0949815    0.0945237    0.00426904
 0.0454545  0.00317911  0.00317911      0.00317911   0.00317911   0.00317911
 0.0454545  0.0944016   0.00350562      0.00350562   0.0938131    0.00350562
 0.0454545  0.00150397  0.00150397      0.0921901    0.0918479    0.0912083
 0.0454545  0.0956671   0.0959533    …  0.0960898    0.0962863    0.0960977
 0.0454545  0.00365637  0.0945089       0.00365637   0.00365637   0.00365637
 0.0454545  0.0909954   0.000375678     0.000375678  0.000375678  0.000375678
 0.0454545  0.00487068  0.00487068      0.0958842    0.00487068   0.0951817
 0.0454545  0.0970559   0.00595991      0.096872     0.0972911    0.0973644
 0.0454545  0.00523895  0.00523895   …  0.00523895   0.00523895   0.0963758
 0.0454545  0.00764483  0.00764483      0.00764483   0.00764483   0.00764483
 0.0454545  0.0971981   0.0971457       0.0974226    0.0975877    0.0973244
 0.0454545  0.00218155  0.0930112       0.0934464    0.00218155   0.00218155
 0.0454545  0.0914433   0.0915956       0.000654204  0.000654204  0.000654204
 0.0454545  0.0937513   0.00289981   …  0.00289981   0.0937545    0.00289981
 0.0454545  0.00669052  0.00669052      0.00669052   0.00669052   0.00669052
```

# Reference
> [Distributed mean reversion online portfolio strategy with stock network](https://doi.org/10.1016/j.ejor.2023.11.021)
"""
function dmr(
  x::AbstractMatrix,
  horizon::Integer,
  α::Union{Nothing, AbstractVector{<:AbstractFloat}},
  n::Integer,
  w::Integer,
  η::AbstractFloat=0.
)
  m, n_periods = size(x)
  n<m || DimensionMismatch("The number of assets should be greater than the number of top \
  asstets. The number of passed assets are $m and the number of top assets are $n.") |> throw
  1>η≥0 || DomainError("`η` should be in [0, 1).") |> throw
  horizon>0 || DomainError("`horizon` should be positive.") |> throw
  w>0 || DomainError("`w` should be positive.") |> throw
  n>0 || DomainError("`n` should be positive.") |> throw
  n_periods-horizon-w+1≥0 || DomainError("The number of periods should be greater than or \
  equal to `$(horizon+w-1)`. The number of passed periods are $n_periods, `horizon` is \
  $horizon and `w` is $w.") |> throw
  if isnothing(α)
    α = 1 ./[k+1000 for k ∈ 1:horizon-1]
  else
    length(α) == horizon-1 || DimensionMismatch("The length of `α` should be equal to `horizon-1`.") |> throw
    all(α.>0) || DomainError("All elements of `α` should be positive.") |> throw
  end
  b        = similar(x, m, horizon)
  b[:, 1] .= 1/m
  b̂        = zeros(m, n+1)
  rndvals  = rand(m)
  for k ∈ 1:horizon-1
    b̂[:, 1] = rndvals/sum(rndvals)
    A, Vₜₒₚ = Afunc(x[:, end-horizon-w+k+1:end-horizon+k], η, n)
    for i ∈ 1:n
      v̂ᵢ           = v̂ᵢfunc(b̂[Vₜₒₚ, i], A)
      ŷᵢ           = ŷᵢfunc(v̂ᵢ, x[Vₜₒₚ, end-horizon+k], b[Vₜₒₚ, k], α[k])
      b̂[Vₜₒₚ, i+1] = b̂ᵢfunc(ŷᵢ)
    end
    b[:, k+1] = sum(b̂/(n+1), dims=2)
    b̂        .= 0.
  end
  return OPSAlgorithm(m, b, "DMR")
end
