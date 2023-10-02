"""
    bk(rel_price::Matrix{T}, K::S, L::S, c) where {T<:Float64, S<:Int}

Run the Best-Known-Constant Rebalanced Portfolio (BKCRP) algorithm.

# Arguments
- `rel_price::Matrix{T}`: Relative prices of assets.
- `K::S`: Number of experts.
- `L::S`: Number of time windows.
- `c::T`: The similarity threshold.

!!! warning "Beware!"
    `rel_price` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm(n_assets, b, alg)`: An object of type `OPSAlgorithm`.

# Example
```julia
julia> using OnlinePortfolioSelection

julia> daily_relative_prices = rand(10, 100);

julia> model = bk(daily_relative_prices, 10, 10, 0.5);

julia> model.alg
"Bᵏ"

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```

# Reference
- [1] [NONPARAMETRIC KERNEL-BASED SEQUENTIAL INVESTMENT STRATEGIES](https://doi.org/10.1111/j.1467-9965.2006.00274.x)
"""
function bk(rel_price::Matrix{T}, K::S, L::S, c) where {T<:Float64, S<:Int}
  0<c≤1 || DomainError("c must be graeter than 0 and less than or equal to 1 (0 < c ≤ 1)") |> throw
  K>0 || DomainError("K must be a positive value (K > 0)") |> throw
  L>0 || DomainError("L must be a positive value (L > 0)") |> throw
  nstocks, ndays= size(rel_price)
  daily_ret = ones(ndays)
  day_weight = ones(nstocks)/nstocks
  day_weight_o = zeros(nstocks)
  daily_portfolio = zeros(nstocks, ndays)
  exp_ret = ones(L+1, K)
  exp_w = ones(nstocks, K * (L+1)) / nstocks

  for t = 1:ndays
    if t>1
      day_weight, exp_w = kernel(rel_price[:, 1:t-1], K, L, c, exp_ret, exp_w)
    end
    day_weight = day_weight ./ sum(day_weight)
    daily_portfolio[:, t] = day_weight
    daily_ret[t, 1] = sum(rel_price[:, t].*day_weight)
    day_weight_o = day_weight .* rel_price[:, t]./daily_ret[t]
    exp_ret[L+1, 1] = exp_ret[L+1, 1]*sum(rel_price[:, t].*exp_w[:, K*L+1])
    for l=1:L
      for k=1:K
        exp_ret[l, k] = exp_ret[l, k]*sum(rel_price[:, t].*exp_w[:, (k-1)*L+l])
      end
    end
  end

  return OPSAlgorithm(nstocks, daily_portfolio, "Bᴷ")
end

function kernel_q(K, L)
  return 1/(K*L+1)
end

"""
    kernel(data, K, L, similarity, exp_ret, exp_w)

Compute the kernel function.

# Arguments
- `data::Matrix{T}`: Relative prices of assets.
- `K::S`: Maximum window size.
- `L::S`: the number of splits into L parts in each K.
- `similarity::T`: the similarity threshold.
- `exp_ret::Matrix{T}`: matrix of historical cumulative returns used to weight the \
portfolios
- `exp_w::Matrix{T}`: matrix of the experts' last portfolios.

"""
function kernel(data, K, L, c, exp_ret, exp_w)
  # Initialize the first expert's portfolio
  exp_w[:, K*L+1] = expert(data, 0, 0, c)

  # Initialize the remaining experts' portfolios
  for l = 1:L
    for k = 1:K
      exp_w[:, (k-1)*L+l] = expert(data, k, l, c)
    end
  end

  # Calculate the weight of each expert's portfolio
  numerator = kernel_q(K, L) * exp_ret[L+1, 1] * exp_w[:, K*L+1]
  denominator = kernel_q(K, L) * exp_ret[L+1, 1]

  for l = 1:L
    for k = 1:K
      numerator += kernel_q(K, L) * exp_ret[l, k] * exp_w[:, (k-1)*L+l]
      denominator += kernel_q(K, L) * exp_ret[l, k]
    end
  end

  # Calculate the weight of the final portfolio
  weight = numerator / denominator

  return weight, exp_w
end

"""
    expert(data, k, l, c)

Compute the expert's portfolio.

# Arguments
- `data::Matrix{T}`: Relative prices of assets.
- `k::S`: The window size.
- `l::S`: The number of splits into L parts in each K.
- `c::T`: The similarity threshold.

# Returns
- `::Vector{T}`: The expert's portfolio.
"""
function expert(data, k, l, c)
  nstocks, day = size(data)
  m = 0
  historical_data = zeros(nstocks, day)
  if day ≤ k+1
    return ones(nstocks) / nstocks
  end

  if k==l==0
    historical_data = data[:, 1:day]
    m = day
  else
    for i = k+1:day
      data2 = data[:, i-k:i-1]-data[:, day-k+1:day]
      if √(tr(transpose(data2) * data2))≤c/l
        m += 1
        historical_data[:, m] = data[:, i]
      end
    end
  end

  if m==0
    return ones(nstocks) / nstocks
  end

  first_m_days = @views historical_data[:, 1:m]

  model = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
  @variable(model, 0 <= weight[i=1:nstocks] <= 1)
  @constraint(model, sum(weight) == 1)
  @NLobjective(model, Max, sum(first_m_days[j,i] * weight[j] for i=1:m, j=1:nstocks))

  optimize!(model)

  weight = transpose(value.(weight))
  return weight
end
