"""
    Lₜfunc(𝐛::AbstractMatrix, xₜ::AbstractVector, γ::Real)::AbstractVector

Compute loss of each expert.

# Arguments
- `𝐛::AbstractMatrix`: matrix of experts weights.
- `xₜ::AbstractVector`: vector of relative prices at time t.
- `γ::Real`: Regular term coefficient of the basic expert's loss function.

# Returns
- `::AbstractVector`: vector of losses of each expert.
"""
function Lₜfunc(𝐛::AbstractMatrix, xₜ::AbstractVector, γ::AbstractFloat)::AbstractVector
  n2 = norm(𝐛)^2
  return -log.(xₜ'*𝐛).+γ*n2 |> vec
end

"""
    ∏ₖ(η, 𝜵, 𝘄ₜ)

Compute the expert weights projection.

# Arguments
- `η::AbstractFloat`: step size.
- `𝜵::AbstractVector`: vector of gradient of losses of each expert.
- `𝘄ₜ::AbstractVector`: vector of weights of experts at time t.

# Returns
- `::AbstractVector`: vector of weights of experts at time t+1.
"""
function ∏ₖ(η, 𝜵, 𝘄ₜ)
  k = length(𝘄ₜ)
  y = 𝘄ₜ .- η*𝜵
  model = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
  @variable(model, 0. <= 𝘄ₜ₊₁[i=1:k] <= 1.)
  @constraint(model, sum(𝘄ₜ₊₁) == 1.)
  @NLobjective(model, Min, sum((𝘄ₜ₊₁[i] - y[i])^2 for i=1:k))
  optimize!(model)
  return value.(𝘄ₜ₊₁)
end

"""
    bₜ₊₁func(𝘄ₜ₊₁::AbstractVector, 𝐛::AbstractMatrix)::AbstractVector

Compute weights of portfolio for the next period.

# Arguments
- `𝘄ₜ₊₁::AbstractVector`: vector of weights of experts at time t+1.
- `𝐛::AbstractMatrix`: Matrix of experts opinions.

# Returns
- `::AbstractVector`: vector of weights of portfolio at time t+1.
"""
function bₜ₊₁func(𝘄ₜ₊₁::AbstractVector, 𝐛::AbstractMatrix)::AbstractVector
  return 𝐛*(𝘄ₜ₊₁')' |> vec
end

"""
    cwogd(
      rel_pr::AbstractMatrix,
      γ::AbstractFloat,
      H;
      bj::AbstractMatrix=diagm(ones(size(rel_pr, 1)))
    )

Run the CW-OGD algorithm.

# Positional Arguments
- `rel_pr::AbstractMatrix`: Relative price matrix where it represents proportion of the \
closing price to the opening price of each asset in each day.
- `γ::AbstractFloat`: Regular term coefficient of the basic expert's loss function.
- `H::AbstractFloat`: Constant for calculating step sizes.

# Keyword Arguments
- `bj::AbstractMatrix=diagm(ones(size(rel_pr, 1)))`: Matrix of experts opinions. Each column \
of this matrix must have just one positive element == 1. and others are zero. Also, sum of \
each column must be equal to 1. and number of rows must be equal to number of rows of `rel_pr`.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of [`OPSAlgorithm`](@ref) type.

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> startdt, enddt = "2019-01-01", "2019-01-10";

julia> querry_open_price = [get_prices(ticker, startdt=startdt, enddt=enddt)["open"] for ticker in tickers];

julia> open_pr = reduce(hcat, querry_open_price) |> permutedims;

julia> querry_close_pr = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> close_pr = reduce(hcat, querry_close_pr) |> permutedims;

julia> rel_pr = close_pr ./ open_pr
3×6 Matrix{Float64}:
 1.01956  0.987568  1.02581  0.994822  1.00796   1.01335
 1.01577  0.973027  1.02216  1.00413   0.997671  1.00395
 1.0288   0.976042  1.03692  0.997097  1.00016   0.993538

julia> gamma = 0.1; H = 0.5;

julia> model = cwogd(rel_pr, gamma, H);

julia> model.b
3×5 Matrix{Float64}:
 0.333333  0.351048  0.346241  0.338507  0.350524
 0.333333  0.321382  0.309454  0.320351  0.311853
 0.333333  0.32757   0.344305  0.341142  0.337623

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```

Or using a custom matrix of experts opinions:

```julia
julia> b1 = [
          0.0 1.0 0.0
          1.0 0.0 0.0
          0.0 0.0 1.0
        ]

julia> model = cwogd(rel_pr, gamma, H, bj=b1);

julia> model.b
3×6 Matrix{Float64}:
 0.333333  0.329802  0.347517  0.34271   0.334976  0.346992
 0.333333  0.322351  0.3104    0.298472  0.309369  0.300871
 0.333333  0.347847  0.342083  0.358819  0.355655  0.352137

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```

# References
> [[1] Combining expert weights for online portfolio selection based on the gradient descent algorithm.](https://doi.org/10.1016/j.knosys.2021.107533)
"""
function cwogd(
  rel_pr::AbstractMatrix,
  γ::AbstractFloat,
  H;
  bj::AbstractMatrix=diagm(ones(size(rel_pr, 1)))
)
  𝐛ʲ=bj
  n_assets, n_days = size(rel_pr)
  sum(𝐛ʲ.>0., dims=1) |> vec |> isequal(ones(size(𝐛ʲ, 2))) || ArgumentError("𝐛ʲ must be a \
  Matrix in which each column has just one positive element == 1. and others are zero.") |> throw
  sum(𝐛ʲ, dims=1) .|> isapprox(1.) |> all || ArgumentError("𝐛ʲ must be a matrix in which \
  sum of each column == 1.") |> throw
  size(𝐛ʲ, 1) == n_assets || ArgumentError("𝐛ʲ must be a matrix in which number of rows == \
  number of rows of `rel_pr`.") |> throw
  0≤γ≤1 || DomainError(γ, "γ must be in [0,1].") |> throw
  H>0 || DomainError(H, "H must be positive.") |> throw

  η  = 1/H
  b  = ones(n_assets, n_days)/n_assets
  k  = size(𝐛ʲ, 2)
  𝘄ₜ = ones(k)/k
  for t ∈ 2:n_days
    Lₜ     = Lₜfunc(𝐛ʲ, rel_pr[:,t-1], γ)
    𝘄ₜ₊₁   = ∏ₖ(η, Lₜ, 𝘄ₜ)
    𝘄ₜ     = 𝘄ₜ₊₁
    bₜ₊₁   = bₜ₊₁func(𝘄ₜ₊₁, 𝐛ʲ)
    bₜ₊₁   = max.(0, bₜ₊₁) |> normalizer!
    b[:,t] = bₜ₊₁
  end
  return OPSAlgorithm(n_assets, b, "CW-OGD")
end
