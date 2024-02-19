"""
    bk(rel_price::AbstractMatrix{T}, K::S, L::S, c::T) where {T<:AbstractFloat, S<:Integer}

Run Bᴷ algorithm.

# Arguments
- `rel_price::AbstractMatrix{T}`: Relative prices of assets.
- `K::S`: Number of experts.
- `L::S`: Number of time windows.
- `c::T`: The similarity threshold.

!!! warning "Beware!"
    `rel_price` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Example
```julia
julia> using OnlinePortfolioSelection

julia> daily_relative_prices = rand(3, 20);
julia> nexperts = 10;
julia> nwindows = 3;
julia> sim_thresh = 0.5;

julia> model = bk(daily_relative_prices, nexperts, nwindows, sim_thresh);

julia> model.b
3×20 Matrix{Float64}:
 0.333333  0.333333  0.354839  0.318677  …  0.333331  0.329797  0.322842  0.408401
 0.333333  0.333333  0.322581  0.362646     0.333339  0.340406  0.354317  0.295811
 0.333333  0.333333  0.322581  0.318677     0.333331  0.329797  0.322842  0.295789

julia> sum(model.b, dims=1) .|> isapprox(1.) |> all
true
```

# Reference
> [NONPARAMETRIC KERNEL-BASED SEQUENTIAL INVESTMENT STRATEGIES](https://doi.org/10.1111/j.1467-9965.2006.00274.x)
"""
function bk(rel_price::AbstractMatrix{T}, K::S, L::S, c::T) where {T<:AbstractFloat, S<:Integer}
  0<c≤1 || DomainError("c must be graeter than 0 and less than or equal to 1 (0 < c ≤ 1)") |> throw
  K>0   || DomainError("K must be a positive value (K > 0)") |> throw
  L>0   || DomainError("L must be a positive value (L > 0)") |> throw
  nstocks, ndays = size(rel_price)
  b              = similar(rel_price)
  b[:, 1]       .= 1/nstocks
  𝑆ₙ             = ones(T, L+1, K)
  𝐡⁽ᵏˡ⁾          = fill(1/nstocks, nstocks, K * (L+1))
  𝑆ₙfunc!(𝑆ₙ, rel_price[:, 1], 𝐡⁽ᵏˡ⁾, K, L)
  for t ∈ 2:ndays
    𝐛, 𝐡⁽ᵏˡ⁾ = kernel(rel_price[:, 1:t-1], K, L, c, 𝑆ₙ, 𝐡⁽ᵏˡ⁾)
    normalizer!(𝐛)
    b[:, t]  = 𝐛
    𝑆ₙfunc!(𝑆ₙ, rel_price[:, t], 𝐡⁽ᵏˡ⁾, K, L)
  end

  return OPSAlgorithm(nstocks, b, "Bᴷ")
end

function 𝑆ₙfunc!(𝑆ₙ::AbstractMatrix, 𝐱ₜ::AbstractVector, 𝐡⁽ᵏˡ⁾::AbstractMatrix, K, L)
  𝑆ₙ[L+1, 1] = 𝑆ₙ[L+1, 1]*sum(𝐱ₜ.*𝐡⁽ᵏˡ⁾[:, K*L+1])
  for l ∈ 1:L, k ∈ 1:K
    𝑆ₙ[l, k] = 𝑆ₙ[l, k]*sum(𝐱ₜ.*𝐡⁽ᵏˡ⁾[:, (k-1)*L+l])
  end
end

"""
    function kernel(
      𝐱::AbstractMatrix{T},
      K::S,
      L::S,
      c::T,
      𝑆ₙ::AbstractMatrix{T},
      𝐡⁽ᵏˡ⁾::AbstractMatrix{T}
    ) where {T<:AbstractFloat, S<:Integer}

Compute the kernel function.

# Arguments
- `𝐱::AbstractMatrix{T}`: Relative prices of assets.
- `K::S`: Maximum window size.
- `L::S`: the number of splits into L parts in each K.
- `c::T`: the similarity threshold.
- `𝑆ₙ::AbstractMatrix{T}`: matrix of historical cumulative returns used to weight the \
  portfolios
- `𝐡⁽ᵏˡ⁾::AbstractMatrix{T}`: matrix of the experts' last portfolios.

"""
function kernel(
  𝐱::AbstractMatrix{T},
  K::S,
  L::S,
  c::T,
  𝑆ₙ::AbstractMatrix{T},
  𝐡⁽ᵏˡ⁾::AbstractMatrix{T}
) where {T<:AbstractFloat, S<:Integer}
  # Initialize the first expert's portfolio
  𝐡⁽ᵏˡ⁾[:, K*L+1] = 𝐡⁽ᵏˡ⁾func(𝐱, 0, 0, c)

  # Initialize the remaining experts' portfolios
  for l ∈ 1:L, k ∈ 1:K
    𝐡⁽ᵏˡ⁾[:, (k-1)*L+l] = 𝐡⁽ᵏˡ⁾func(𝐱, k, l, c)
  end
  qₖₗ = 1/(K*L+1)
  inves_wealth = qₖₗ * 𝑆ₙ[L+1, 1]
  numerator    = inves_wealth * 𝐡⁽ᵏˡ⁾[:, K*L+1]
  denominator  = inves_wealth

  for l ∈ 1:L, k ∈ 1:K
    inves_wealth = qₖₗ * 𝑆ₙ[l, k]
    numerator   += inves_wealth * 𝐡⁽ᵏˡ⁾[:, (k-1)*L+l]
    denominator += inves_wealth
  end

  # Calculate the weight of the final portfolio
  𝐛 = numerator / denominator

  return 𝐛, 𝐡⁽ᵏˡ⁾
end

"""
    𝐡⁽ᵏˡ⁾func(𝐱::AbstractMatrix{T}, k::S, l::S, c::T) where {T<:AbstractFloat, S<:Integer}

Compute the expert's portfolio.

# Arguments
- `𝐱::AbstractMatrix{T}`: Relative prices of assets.
- `k::S`: The window size.
- `l::S`: The number of splits into L parts in each K.
- `c::T`: The similarity threshold.

# Returns
- `::AbstractVector{T}`: The expert's portfolio.
"""
function 𝐡⁽ᵏˡ⁾func(𝐱::AbstractMatrix{T}, k::S, l::S, c::T) where {T<:AbstractFloat, S<:Integer}
  nstocks, day = size(𝐱)
  day ≤ k+1 && return ones(T, nstocks) / nstocks
  historical_data = zeros(T, nstocks, day)
  m = zero(S)

  if k==l==0
    historical_data = 𝐱[:, 1:day]
    m = day
  else
    for i ∈ k+1:day
      @views xᵢ₋ₖⁱ⁻¹ = 𝐱[:, i-k:i-1]
      @views 𝐬 = 𝐱[:, day-k+1:day]
      dif = xᵢ₋ₖⁱ⁻¹ - 𝐬
      if norm(dif)≤c/l
        m += 1
        historical_data[:, m] = 𝐱[:, i]
      end
    end
  end

  m==0 && return ones(T, nstocks) / nstocks

  first_m_days = @views historical_data[:, 1:m]
  model = Model(optimizer_with_attributes(Optimizer, "print_level" => 0))
  @variable(model, 0 <= b[i=1:nstocks] <= 1)
  @constraint(model, sum(b) == 1)
  @objective(model, Max, sum(first_m_days[j,i] * b[j] for i=1:m, j=1:nstocks))
  optimize!(model)
  return value.(b)
end
