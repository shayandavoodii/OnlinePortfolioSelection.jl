"""
    b̃func(𝐛ₜ, 𝙭ₜ)

Calculate vector b̃ₜ₊₁.

# Arguments
- `𝐛ₜ::Vector`: Vector of weights of the current day.
- `𝙭ₜ::Vector`: Vector of relative prices of the current day.

# Returns
- `Vector`: Vector of weights of the next day.
"""
function b̃func(𝐛ₜ, 𝙭ₜ)
  return (𝐛ₜ .* 𝙭ₜ)./(𝐛ₜ'*𝙭ₜ)
end

"""
    expertspool(
      rel_pr::T,
      rel_vol::T,
      Wₘᵢₙ::S,
      Wₘₐₓ::S
    ) where {T<:AbstractMatrix, S<:Integer}

Create a matrix of weights for each expert strategy.

# Arguments
- `rel_pr::T`: Relative price matrix where it represents proportion of the closing price \
to the opening price of each asset in each day.
- `rel_vol::T`: Relative volume matrix where 𝘷ᵢⱼ represents the tᵗʰ trading volume of \
asset 𝑖 divided by the (t - 1)ᵗʰ trading volume of asset 𝑖.
- `Wₘᵢₙ::S`: Minimum window size.
- `Wₘₐₓ::S`: Maximum window size.

# Returns
- `Matrix{Float64}`: A matrix of weights for each expert strategy.

# Example
```julia
julia> rel_pr = [
  0.993 1.005 0.898 0.992 1.000 0.957
  0.983 0.958 1.006 1.015 1.010 1.001
  0.960 1.029 0.999 1.017 1.025 0.998
  1.000 0.986 1.034 0.998 0.854 1.006
  0.992 0.975 1.022 1.003 1.008 0.995
];

julia> rel_vol = [
  1.336 1.203 0.829 0.666 0.673 2.120
  3.952 1.661 0.805 1.222 1.445 0.912
  0.362 2.498 1.328 1.009 1.954 0.613
  0.900 1.335 0.583 0.753 1.440 1.064
  1.487 1.900 0.676 0.776 1.319 1.788
];

julia> Wₘᵢₙ = 3; Wₘₐₓ = 6;

julia> expertspool(rel_pr, rel_vol, Wₘᵢₙ, Wₘₐₓ)
5×4 Matrix{Float64}:
 0.0       0.0   0.0  0.166667
 0.333333  0.25  0.2  0.166667
 0.333333  0.25  0.2  0.166667
 0.0       0.25  0.4  0.333333
 0.333333  0.25  0.2  0.166667


julia> rel_pr = [
  1.000 0.993 0.995 0.998 1.000 1.002
  1.000 0.958 1.006 1.015 1.010 1.001
  1.000 1.029 0.999 1.017 1.025 0.998
  1.000 0.986 1.034 0.998 0.854 1.006
  1.000 0.975 1.022 1.003 1.008 0.995
];

julia> rel_vol = [
  1.336 1.203 0.829 0.666 0.673 2.120
  3.952 1.661 0.805 1.222 1.445 0.912
  0.362 2.498 1.328 1.009 1.954 0.613
  0.900 1.335 0.583 0.753 1.440 1.064
  1.487 1.900 0.676 0.776 1.319 1.788
];

julia> Wₘᵢₙ = 3; Wₘₐₓ = 6;

julia> expertspool(rel_pr, rel_vol, Wₘᵢₙ, Wₘₐₓ)
5×4 Matrix{Float64}:
 0.0  0.0       0.0   0.0
 0.0  0.0       0.0   0.0
 0.5  0.333333  0.25  0.2
 0.0  0.333333  0.5   0.4
 0.5  0.333333  0.25  0.4

julia> rel_pr = [
  1.000 1.000 1.000 1.000 1.000 1.000
  1.000 1.000 1.000 1.000 1.000 1.000
  1.000 1.000 1.000 1.000 1.000 1.000
  1.000 1.000 1.000 1.000 1.000 1.000
  1.000 1.000 1.000 1.000 1.000 1.000
];

julia> rel_vol = [
  1.336 1.203 0.829 0.666 0.673 2.120
  3.952 1.661 0.805 1.222 1.445 0.912
  0.362 2.498 1.328 1.009 1.954 0.613
  0.900 1.335 0.583 0.753 1.440 1.064
  1.487 1.900 0.676 0.776 1.319 1.788
];

julia> Wₘᵢₙ = 3; Wₘₐₓ = 6;

julia> expertspool(rel_pr, rel_vol, Wₘᵢₙ, Wₘₐₓ)
5×4 Matrix{Float64}:
 0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2
 0.2  0.2  0.2  0.2
```
"""
function expertspool(
  rel_pr::T,
  rel_vol::T,
  Wₘᵢₙ::S,
  Wₘₐₓ::S
) where {T<:AbstractMatrix, S<:Integer}
  size(rel_pr)==size(rel_vol) || DimensionMismatch("Relative price and relative volume \
  matrices must be of the same size.") |> throw
  n_assets, n_days = size(rel_pr)
  n_days==Wₘₐₓ || DomainError("Adequate amount of data not available. Need \
  $(Wₘₐₓ) days of data. Only $(n_days) days of data available.") |> throw

  # Number of experts
  k = Wₘₐₓ-Wₘᵢₙ+1
  if all(rel_pr.≥1)
    return ones(n_assets, k)/n_assets
  end
  # In each column of rel_pr, look for values that are less than 1 and get their index.
  # Among the found indexes, look for ones that have the highest relative volume in
  # each column
  idx_assets = findassets(rel_pr, rel_vol)
  sum(idx_assets[1:Wₘᵢₙ])==0 && DomainError("Please increase minimum window size (Wₘᵢₙ). \
  No assets could pass the filters successfully with the given data. Note that increasing \
  the Wₘᵢₙ migh not solve the problem. So, increase it till you do not get this error. \
  Another way is to incorporate more stocks.") |> throw

  Γ = Wₘᵢₙ:Wₘₐₓ
  Bₜ = zeros(n_assets, k)
  for i ∈ 1:k
    for idx ∈ idx_assets[1:Γ[i]]
      if idx!=0
        Bₜ[idx, i] += 1
      end
    end
    n_chosen_assets = sum(idx_assets[1:Γ[i]].>0)
    Bₜ[:, i] ./= n_chosen_assets
  end

  return Bₜ
end

function findassets(rel_pr, rel_vol)
  _, n_days = size(rel_pr)
  idx = zeros(Int, n_days)
  for day ∈ 1:n_days
    below1 = rel_pr[:, day].<1
    if sum(below1)==0
      continue
    else
      max_ = maximum(rel_vol[below1, day])
      idx[day] = findfirst(rel_vol[:, day].==max_)
    end
  end
  return idx
end

"""
    ∇fₜfunc(rel_pr, Bₜ, b̃ₜ₋₁, theta_t, λ)

Calculate the gradient of the loss function.

# Arguments
- `rel_pr::AbstractMatrix{T}`: Relative price matrix where it represents proportion of \
the closing price to the opening price of each asset in each day.
- `Bₜ::AbstractMatrix{T}`: A matrix of weights for each expert strategy.
- `b̃ₜ₋₁::Vector`: Vector of weights of the previous day.
- `theta_t::Vector`: Vector of weights that investor assigns to each expert strategy.
- `λ::T`: Trade-off parameter in the loss function.

# Returns
- `Vector`: Gradient of the loss function for each expert strategy.
"""
function ∇fₜfunc(rel_pr, Bₜ, b̃ₜ₋₁, theta_t, λ)
  Bₜ = permutedims(Bₜ)
  Bᵀ = transpose(Bₜ)
  xₜ = rel_pr[:, end]
  numerator_ = xₜ'*Bᵀ
  denominator_ = theta_t'*Bₜ*(xₜ')'
  second_term = λ*theta_t'-b̃ₜ₋₁'*Bᵀ
  return -numerator_/denominator_ + second_term
end

"""
    Lₜfunc(∇fₜ, ζ, g)

Calculate the loss function.

# Arguments
- `∇fₜ::Vector`: Gradient of the loss function for each expert strategy.
- `ζ`: A constant.
- `g`: A constant.

# Returns
- `Vector`: Loss function for each expert strategy.
"""
function Lₜfunc(∇fₜ, ζ, g)
  return 0.5((∇fₜ)/(ζ*g) .+ 1)
end

"""
    θₜ₊₁func(Lₜ, η, θₜ)

Calculate the weights that investor assigns to each expert strategy for the next day.

# Arguments
- `Lₜ::Vector`: Loss function for each expert strategy.
- `η`: Learning rate.
- `θₜ::Vector`: Vector of weights that investor assigns to each expert strategy for the \
current day.

# Returns
- `Vector`: Vector of weights that investor assigns to each expert strategy for the next day.
"""
function θₜ₊₁func(Lₜ, η, θₜ)
  Zₜ = θₜ.*exp.(-η*vec(Lₜ)) |> sum
  θₜ₊₁ = (θₜ.*exp.(-η*vec(Lₜ)))/Zₜ
  return θₜ₊₁
end

"""
    weights(Bₜ₊₁, θₜ₊₁)

Calculate the final weights of the portfolio for the next day.

# Arguments
- `Bₜ₊₁::AbstractMatrix{T}`: A matrix of weights for each expert strategy.
- `θₜ₊₁::Vector`: Vector of weights that investor assigns to each expert strategy.

# Returns
- `Vector`: Vector of weights of the portfolio for the next day.
"""
function weights(Bₜ₊₁, θₜ₊₁)
  return θₜ₊₁'*Bₜ₊₁'
end

sub(tupe) = tupe[1] - tupe[2]

"""
mrvol(
      rel_pr::AbstractMatrix{T},
      rel_vol::AbstractMatrix{T},
      horizon::S,
      Wₘᵢₙ::S,
      Wₘₐₓ::S,
      λ::T,
      η::T
    ) where {T<:AbstractFloat, S<:Integer}

Run MRvol algorithm.

# Arguments
- `rel_pr::AbstractMatrix{T}`: Relative price matrix where it represents proportion of \
the closing price to the opening price of each asset in each day.
- `rel_vol::AbstractMatrix{T}`: Relative volume matrix where 𝘷ᵢⱼ represents the tᵗʰ \
trading volume of asset 𝑖 divided by the (t - 1)ᵗʰ trading volume of asset 𝑖.
- `horizon::S`: Investment horizon. The last `horizon` days of the data will be used to \
run the algorithm.
- `Wₘᵢₙ::S`: Minimum window size.
- `Wₘₐₓ::S`: Maximum window size.
- `λ::T`: Trade-off parameter in the loss function.
- `η::T`: Learning rate.

# Returns
- `OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> startdt, enddt = "2019-01-01", "2020-01-01";

julia> querry_open_price = [get_prices(ticker, startdt=startdt, enddt=enddt)["open"] for ticker in tickers];

julia> open_pr = reduce(hcat, querry_open_price) |> permutedims;

julia> querry_close_pr = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker in tickers];

julia> close_pr = reduce(hcat, querry_close_pr) |> permutedims;

julia> querry_vol = [get_prices(ticker, startdt=startdt, enddt=enddt)["vol"] for ticker in tickers];

julia> vol = reduce(hcat, querry_vol) |> permutedims;

julia> rel_pr = (close_pr ./ open_pr)[:, 2:end];

julia> rel_vol = vol[:, 2:end] ./ vol[:, 1:end-1];

julia> size(rel_pr) == size(rel_vol)
true

julia> horizon = 100; Wₘᵢₙ = 4; Wₘₐₓ = 10; λ = 0.05; η = 0.01;

julia> r = mrvol(rel_pr, rel_vol, horizon, Wₘᵢₙ, Wₘₐₓ, λ, η);

julia> r.b
3×100 Matrix{Float64}:
 0.333333  0.0204062  0.0444759  …  0.38213   0.467793
 0.333333  0.359864   0.194139      0.213264  0.281519
 0.333333  0.61973    0.761385      0.404606  0.250689
```

# References
- [1] [Online portfolio selection of integrating expert strategies based on mean reversion and trading volume](https://doi.org/10.1016/j.eswa.2023.121472)
"""
function mrvol(
  rel_pr::AbstractMatrix{T},
  rel_vol::AbstractMatrix{T},
  horizon::S,
  Wₘᵢₙ::S,
  Wₘₐₓ::S,
  λ::T,
  η::T
) where {T<:AbstractFloat, S<:Integer}
  n_assets, n_days = size(rel_pr)
  n_days-horizon≥Wₘₐₓ || DomainError("Adequate amount of data not available. Need \
  $(n_days-horizon-Wₘₐₓ) more days of data.") |> throw
  size(rel_pr)==size(rel_vol) || DimensionMismatch("Relative price and relative volume \
  matrices must be of the same size.") |> throw
  Wₘᵢₙ > 0 || DomainError("Minimum window size must be greater than zero.") |> throw
  Wₘₐₓ > 0 || DomainError("Maximum window size must be greater than zero.") |> throw
  Wₘᵢₙ < Wₘₐₓ || DomainError("Minimum window size must be less than maximum window size.") |> throw
  1 ≥ λ ≥ 0 || DomainError("λ must be ∈ [0, 1].") |> throw
  horizon > 0 || DomainError("Horizon must be greater than zero.") |> throw
  η > 0 || DomainError("η must be greater than zero.") |> throw

  k = Wₘₐₓ-Wₘᵢₙ+1
  b = ones(n_assets, horizon)/n_assets
  θ = ones(k)/k
  idx_today = n_days-horizon+1
  for t = idx_today+1:n_days
    g = sub(extrema(rel_pr[:, t-Wₘₐₓ:t-1]))
    b̃ₜ = b̃func(b[:, t-idx_today], rel_pr[:, t-1])
    Bₜ₊₁ = expertspool(rel_pr[:, t-Wₘₐₓ:t-1], rel_vol[:, t-Wₘₐₓ:t-1], Wₘᵢₙ, Wₘₐₓ)
    ∇fₜ = ∇fₜfunc(rel_pr[:, t-Wₘₐₓ:t-1], Bₜ₊₁, b̃ₜ, θ, λ)
    Lₜ = Lₜfunc(∇fₜ, 1, g)
    θₜ₊₁ = θₜ₊₁func(Lₜ, η, θ)
    b[:, t-idx_today+1] = weights(Bₜ₊₁, θₜ₊₁)
    θ = θₜ₊₁
  end

  return OPSAlgorithm(n_assets, b, "MRvol")
end
