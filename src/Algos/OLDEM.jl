"""
    createLDES(L::T, s::T, n_assets::T) where T<:Integer

Creates a list of LDES of length `L`, each of which is of length `s` and contains integers \
from 1 to `n_assets`. Hence, this function randomly creates a list of vectors each of which \
contains index of `s` assets.

# Arguments
- `L::T`: Number of LDES to be created.
- `s::T`: Length of each LDES. (Number of assets in each LDES)
- `n_assets::T`: Number of considered assets.

!!! note
    Note that ``s<<n_assets`` should be satisfied. Also, `L` should be a large number. The \
    authors have used `L=300` and `s=5` in their paper.

# Returns
- `::Vector{Vector{<:Int}}`: A list of LDES of length `L`.

# Example
A minimal example is as follows:
```julia
julia> createLDES(3, 2, 4)
3-element Vector{Vector{Int64}}:
 [1, 3]
 [3, 4]
 [4, 1]
```
In the above, the third subsystem contains the fourth and the first assets.
"""
function createLDES(L::T, s::T, n_assets::T) where T<:Integer
  return [sample(1:n_assets, s, replace=false) for 𝑙=1:L]
end

"""
    β̂ₖ⁽ˡ⁾func(Xₜ⁽ˡ⁾::AbstractMatrix, xₜₖ::AbstractVector)

Estimate unknown parameters βₖₛ⁽ˡ⁾ using OLS.

# Arguments
- `Xₜ⁽ˡ⁾::AbstractMatrix`: A matrix of size ``t-i \times j``. Where ``i=1,2,\\ldots ,w`` \
  and ``j=1,2,\\ldots ,s``. Note that `length(𝑙)=s`.
- `xₜₖ::AbstractVector`: Price relative of ``k``th asset at time ``t \\to t-w+1``. In other \
  words, ``x_{t,k}=\\left( x_{t,k}, x_{t-1,k}, \\ldots , x_{t-w+1,k}\\right)``.

# Returns
- `::AbstractVector`: A `Vector` of length ``j`` containing the estimated parameters.

# Example
```julia
julia> w = 3;

julia> Xₜ⁽ˡ⁾ = rand(0.8:0.001:1.2, w, 4)
3×4 Matrix{Float64}:
 0.832  0.914  1.106  0.805
 0.862  1.112  1.143  1.03
 0.922  1.114  1.092  0.835

julia> xₜₖ = rand(0.8:0.001:1.2, w)
3-element Vector{Float64}:
 0.846
 0.912
 0.912

julia> β̂ₖ⁽ˡ⁾func(Xₜ⁽ˡ⁾, xₜₖ)
4-element Vector{Float64}:
 -0.4798900000000006
  0.5026091289306112
  0.34547586878629644
  0.42096800422953784
"""
function β̂ₖ⁽ˡ⁾func(Xₜ⁽ˡ⁾::AbstractMatrix, xₜₖ::AbstractVector)
  length(xₜₖ) == size(Xₜ⁽ˡ⁾, 1) || DimensionMismatch("length(xₜₖ) != size(Xₜ⁽ˡ⁾, 2)") |> throw
  xₜₖ = xₜₖ |> permutedims |> permutedims
  return Xₜ⁽ˡ⁾\xₜₖ |> vec
end

"""
    x̂ₜ₊₁ₖ⁽ˡ⁾func(xₜ⁽ˡ⁾::AbstractVector, β̂ₖ⁽ˡ⁾::AbstractVector)

Calculate the predicted price relative of ``k``th asset at time ``t+1`` using the ``l``'th \
subsystem.

# Arguments
- `xₜ⁽ˡ⁾::AbstractVector`: A vector of length ``s`` containing the price relative of assets \
  in the ``l`` subsystem at time ``t``.
- `β̂ₖ⁽ˡ⁾::AbstractVector`: A vector of length ``s`` containing the estimated parameters for \
  each asset in the ``l``'th subsystem. ``\\beta_k^{(l)}=\\left( \\beta_{k,1}^{(l)},
  \\beta_{k,2}^{(l)}, \\ldots , \\beta_{k,s}^{(l)}\\right)``.

# Returns
- `::AbstractFloat`: A scalar containing the predicted price relative of ``k``th asset at \
  time ``t+1`` using the ``l``'th subsystem.

# Example
```julia
julia> xₜ⁽ˡ⁾ = [0.86, 0.802, 0.837, 0.837];

julia> β̂ₖ⁽ˡ⁾ = [0.1, 0.2, 0.3, 0.4];

julia> x̂ₜ₊₁ₖ⁽ˡ⁾func(xₜ⁽ˡ⁾, β̂ₖ⁽ˡ⁾)
0.8323
```
"""
x̂ₜ₊₁ₖ⁽ˡ⁾func(xₜ⁽ˡ⁾::AbstractVector, β̂ₖ⁽ˡ⁾::AbstractVector) = sum(xₜ⁽ˡ⁾.*β̂ₖ⁽ˡ⁾)

"""
    vₜfunc(Rₜ::AbstractMatrix, σ::AbstractFloat)

Calculate weight of all subsystems.

# Arguments
- `Rₜ::AbstractMatrix`: A matrix of size `n_assets` × `𝑙` containing the mean squared error \
  for all assets.
- `σ::AbstractFloat`: Kernel bandwidth.

# Returns
- `::AbstractMatrix`: A matrix of size `n_assets` × `𝑙` containing the weight of 𝑙'th \
  subsystem.

# Example
```julia
julia> Rₜ = rand(4, 6)
4×6 Matrix{Float64}:
 0.0960631  0.967273    0.762214  0.0622623  0.854902  0.137409
 0.730288   0.530231    0.488309  0.495134   0.480655  0.663915
 0.471691   0.271454    0.210108  0.298702   0.268271  0.974648
 0.420664   0.00286611  0.920839  0.985436   0.086436  0.603461

julia> σ = 0.2

julia> vₜfunc(Rₜ, σ)
4×6 Matrix{Float64}:
 0.271464     9.43352e-11  1.58879e-8  0.631974     1.56574e-9  0.096562
 0.000689913  0.102539     0.292452    0.246573     0.354119    0.00362605
 0.000926364  0.138302     0.641032    0.0699813    0.149757    3.20621e-9
 2.58894e-5   0.88983      9.606e-11   1.91068e-11  0.110144    2.68181e-7
```
"""
function vₜfunc(Rₜ::AbstractMatrix, σ::AbstractFloat)
  numerator_ = exp.((-1*Rₜ)/(σ^2))
  vₜ         = numerator_./sum(numerator_, dims=2)
  any(isnan.(vₜ)) && ArgumentError("Result contains NaN values. You may want to increase \
  σ.") |> throw
  return vₜ
end

"""
    x̂ₜ₊₁func(
      x::AbstractMatrix,
      𝑙::AbstractVector{<:AbstractVector{<:T}},
      σ::AbstractFloat,
      w::T,
      t::T
    ) where T<:Integer


Calculate the aggregated price relatives predictions for all assets.

# Arguments
- `x::AbstractMatrix`: A matrix of size `n_assets` × `T` containing the historical price \
  relatives of assets.
- `𝑙::AbstractVector{<:AbstractVector{<:T}}`: A list of LDES of length `L`, each of \
  which is of length `s` and contains integers from 1 to `n_assets`.
- `σ::AbstractFloat`: Kernel bandwidth.
- `w::T`: Window size.
- `t::T`: Current time index.

# Returns
- `::AbstractVector`: A vector of length `n_assets` containing the aggregated price \
  relatives predictions for all assets.
- `::AbstractMatrix`: A matrix of size `n_assets` × `L` containing the weight of 𝑙'th \
  subsystem for all assets.
- `::AbstractMatrix`: A matrix of size `n_assets` × `n_assets` × `L` containing the \
  estimated parameters for all assets in the subsystem.

# Example
```julia
julia> using YFinance
julia> tickers = ["MSFT", "TSLA", "AAPL", "AMZN", "GOOG", "META", "BRK-A", "V", "JNJ", "WMT"];
julia> querry = [get_prices(ticker, startdt="2020-01-01", enddt="2020-01-10")["adjclose"] for ticker in tickers];
julia> prices = stack(querry) |> permutedims;
julia> x = prices[:, 2:end]./prices[:, 1:end-1];

julia> n_assets = size(x, 1);
julia> σ = 0.2;
julia> w = 2;
julia> t = 5;

julia> l = createLDES(10, 5, n_assets);

julia> x̂ₜ₊₁func(x, l, σ, w, t)
10-element Vector{Float64}:
 1.007095155084924
 1.0208765736448693
 1.0096586004857036
 0.9881347027337815
 1.0009849867391298
 1.003509756119584
 0.9962733063776238
 1.0063832165652333
 0.9930479784123145
 0.9927579917128402
```
"""
function x̂ₜ₊₁func(
  x::AbstractMatrix,
  𝑙::AbstractVector{<:AbstractVector{<:T}},
  σ::AbstractFloat,
  w::T,
  t::T
) where T<:Integer
  n_assets, _ = size(x)
  n_subsys    = length(𝑙)
  x̂ₜ₊₁        = similar(x, n_assets, n_subsys)
  x̂ₜ₋ᵢ        = similar(x, n_assets, n_subsys, w)
  Rₜ⁽ˡ⁾       = similar(x̂ₜ₊₁)
  β̂ₖ          = zeros(n_assets, n_assets, n_subsys)
  for k ∈ 1:n_assets
    for l ∈ 1:n_subsys
      Xₜ⁽ˡ⁾          = rotl90(x[𝑙[l], t-w:t-1])
      xₜₖ            = x[k, t-w+1:t]
      xₜ⁽ˡ⁾          = x[𝑙[l], t]
      β̂ₖ[k, 𝑙[l], l] = β̂ₖ⁽ˡ⁾func(Xₜ⁽ˡ⁾, xₜₖ)
      x̂ₜ₊₁[k, l]     = x̂ₜ₊₁ₖ⁽ˡ⁾func(xₜ⁽ˡ⁾, β̂ₖ[k, 𝑙[l], l])
      for tt ∈ 1:w
        @views Xₜ₋ᵢ⁽ˡ⁾ = rotl90(x[𝑙[l], t-w-tt:t-1-tt])
        @views xₜ₋ᵢₖ   = x[k, t-w+1-tt:t-tt]
        @views xₜ₋ᵢ⁽ˡ⁾ = x[𝑙[l], t-tt]
        x̂ₜ₋ᵢ[k, l, tt] = x̂ₜ₊₁ₖ⁽ˡ⁾func(xₜ₋ᵢ⁽ˡ⁾, β̂ₖ⁽ˡ⁾func(Xₜ₋ᵢ⁽ˡ⁾, xₜ₋ᵢₖ))
        Rₜ⁽ˡ⁾[k, l]    = sum((x[k, t-w+1:t] .- x̂ₜ₋ᵢ[k, l, :]).^2)/w
      end
    end
  end
  vₜ = vₜfunc(Rₜ⁽ˡ⁾, σ)
  any(isnan.(β̂ₖ)) && @warn "β̂ₖ contains NaN values."
  return sum(vₜ.*x̂ₜ₊₁, dims=2) |> vec, vₜ, β̂ₖ
end

"""
    covxₜₗₚxₜₗqfunc(xₜ⁽ˡ⁾::AbstractMatrix, 𝑙::AbstractVector, w::Integer)

Calculate the covariance of price relatives for ``lₚ`` and ``lq`` assets.

# Arguments
- `xₜ⁽ˡ⁾::AbstractMatrix`: A matrix of size `n_assets` × `w` containing the price relatives \
  of assets for ``t\to t-w+1``. Example: If w=3, then ``xₜ⁽ˡ⁾=\\left( x_{t}, x_{t-1}, \
  x_{t-2}`` for each asset.
- `𝑙::AbstractVector`: A vector of length `2` containing index of two assets in the subsystem. \
  Example: ``𝑙=[2, 4]`` means that the second and the fourth assets are in the subsystem.
- `w::Integer`: Window size.

# Returns
- `::AbstractFloat`: A scalar containing the covariance of price relatives for ``lₚ`` and \
  ``lq`` assets.

# Example
```julia
julia> xₜ⁽ˡ⁾ = [
 0.86   0.802  0.837  0.837  0.813  0.932  0.964  0.916  0.919  0.805
 1.054  1.103  0.949  1.123  0.926  0.888  0.923  0.904  1.11   0.825
 0.955  1.086  1.192  0.817  0.928  0.831  1.153  1.059  1.142  0.996
 0.976  0.86   1.166  1.037  0.906  1.095  1.113  0.969  1.068  0.909
 0.884  0.859  1.098  0.934  0.851  1.083  0.974  0.985  1.195  1.118
 0.804  0.911  0.829  1.187  0.815  1.16   0.958  1.198  1.196  0.836
];

julia> x = xₜ⁽ˡ⁾[:, t-w+1:t]
6×3 Matrix{Float64}:
 0.802  0.837  0.837
 1.103  0.949  1.123
 1.086  1.192  0.817
 0.86   1.166  1.037
 0.859  1.098  0.934
 0.911  0.829  1.187

julia> 𝑙 = [2, 4];

julia> t, w = 4, 3;

julia> covxₜₗₚxₜₗqfunc(x, 𝑙, w)
-0.011005000000000001
```
"""
function covxₜₗₚxₜₗqfunc(x::AbstractMatrix, 𝑙::AbstractVector, w::Integer)
  length(𝑙)==2      || ArgumentError("length(𝑙) != 2") |> throw
  w==size(x, 2) || DimensionMismatch("w != size(x, 2). ($w != $(size(x, 2)))") |> throw

  x̄ₜₗₚ, x̄ₜₗq  = mean(x[𝑙, :], dims=2)
  𝑙ₚ, 𝑙q      = 𝑙
  numerator_  = ((x[𝑙ₚ, end-i].-x̄ₜₗₚ)*(x[𝑙q, end-i].-x̄ₜₗq) for i=0:w-1) |> sum
  covxₜₗₚxₜₗq = numerator_/(w-1)
  return covxₜₗₚxₜₗq
end

"""
    covx̂ₜ₊₁⁽ˡ⁾x̂ₜ₊₁⁽ˡ⁾func(xₜ::AbstractMatrix, 𝑙::AbstractVector, β̂⁽ˡ⁾::AbstractVector, w::Integer)

Calculate the predicted covariance of price relatives for ``lₚ`` and ``lq`` assets.

# Arguments
- `xₜ::AbstractMatrix`: A matrix of size `n_assets` × `w` containing the price relatives \
  of assets for ``t\to t-w+1``. Example: If w=3, then ``xₜ⁽ˡ⁾=\\left( x_{t}, x_{t-1}, \
  x_{t-2}`` for each asset.
- `𝑙::AbstractVector`: A vector of length ``s`` where ``s`` is the number of assets in the \
  subsystem. Example: ``𝑙=[2, 4, 6]`` means that the second, the fourth, and the sixth \
  assets are in the subsystem.
- `β̂⁽ˡ⁾::AbstractVector`: A vector of length `n_assets` containing the estimated parameters \
  for each asset in the subsystem.
- `w::Integer`: Window size.

# Returns
- `::AbstractFloat`: A scalar containing the predicted covariance of price relatives for \
  ``lₚ`` and ``lq`` assets.

# Example
```julia
julia> xₜ = [
 0.86   0.802  0.837  0.837  0.813  0.932  0.964  0.916  0.919  0.805
 1.054  1.103  0.949  1.123  0.926  0.888  0.923  0.904  1.11   0.825
 0.955  1.086  1.192  0.817  0.928  0.831  1.153  1.059  1.142  0.996
 0.976  0.86   1.166  1.037  0.906  1.095  1.113  0.969  1.068  0.909
 0.884  0.859  1.098  0.934  0.851  1.083  0.974  0.985  1.195  1.118
 0.804  0.911  0.829  1.187  0.815  1.16   0.958  1.198  1.196  0.836
];

julia> t, w = 4, 3;

julia> x = xₜ[:, t-w+1:t]
6×3 Matrix{Float64}:
 0.802  0.837  0.837
 1.103  0.949  1.123
 1.086  1.192  0.817
 0.86   1.166  1.037
 0.859  1.098  0.934
 0.911  0.829  1.187

julia> 𝑙 = [2, 4, 6];

julia> β̂⁽ˡ⁾ = [0., 0.1, 0., 0.2, 0., 0.3];

julia> covx̂ₜ₊₁⁽ˡ⁾x̂ₜ₊₁⁽ˡ⁾func(x, 𝑙, β̂⁽ˡ⁾, w)
0.0019026300000000015
```
"""
function covx̂ₜ₊₁⁽ˡ⁾x̂ₜ₊₁⁽ˡ⁾func(xₜ::AbstractMatrix, s::AbstractVector, β̂⁽ˡ⁾::AbstractVector, w::Integer)
  cov_val = 0.
  for p ∈ s
    for q ∈ s
      cov_val += β̂⁽ˡ⁾[p]*β̂⁽ˡ⁾[q]*covxₜₗₚxₜₗqfunc(xₜ, [p, q], w)
    end
  end
  return cov_val
end

"""
    covx̂ₜ₊₁ₖx̂ₜ₊₁ₕfunc(
      xₜ::AbstractMatrix,
      𝑙::AbstractVector{AbstractVector{<:Int}},
      β̂::AbstractArray{<:AbstractFloat, 3},
      w::Int,
      v::AbstractMatrix
    )

Calculate the aggregated predicted covariance of price relatives for all assets.

# Arguments
- `xₜ::AbstractMatrix`: A matrix of size `n_assets` × `w` containing the price relatives \
  of assets for ``t\to t-w+1``. Example: If w=3, then ``xₜ⁽ˡ⁾=\\left( x_{t}, x_{t-1}, \
  x_{t-2}`` for each asset.
- `𝑙::AbstractVector{AbstractVector{<:Int}}`: A list of LDES of length `L`, each of which \
  is of length `s` and contains integers from 1 to `n_assets`.
- `β̂::AbstractMatrix`: An 3D array of size `n_assets` × `n_assets` × `L` containing the \
  estimated parameters for all assets in each subsystem.
- `w::Int`: Window size.
- `v::AbstractMatrix`: A matrix of size `n_assets` × `L` containing the weight of 𝑙'th \
  subsystem for all assets.

# Returns
- `::AbstractMatrix`: A matrix of size `n_assets` × `n_assets` containing the aggregated \
  predicted covariance of price relatives for all assets.

# Example
```julia
julia> xₜ = [
 0.86   0.802  0.837  0.837  0.813  0.932  0.964  0.916  0.919  0.805
 1.054  1.103  0.949  1.123  0.926  0.888  0.923  0.904  1.11   0.825
 0.955  1.086  1.192  0.817  0.928  0.831  1.153  1.059  1.142  0.996
 0.976  0.86   1.166  1.037  0.906  1.095  1.113  0.969  1.068  0.909
 0.884  0.859  1.098  0.934  0.851  1.083  0.974  0.985  1.195  1.118
 0.804  0.911  0.829  1.187  0.815  1.16   0.958  1.198  1.196  0.836
];

julia> n_assets = size(xₜ, 1);

julia> t, w = 4, 3;

julia> x = xₜ[:, t-w+1:t]
6×3 Matrix{Float64}:
 0.802  0.837  0.837
 1.103  0.949  1.123
 1.086  1.192  0.817
 0.86   1.166  1.037
 0.859  1.098  0.934
 0.911  0.829  1.187

julia> l = createLDES(4, 3, n_assets)
4-element Vector{Vector{Int64}}:
 [2, 1, 4]
 [6, 5, 3]
 [2, 1, 5]
 [5, 2, 3]

julia> β̂ = rand(0.1:0.1:0.5, n_assets, n_assets, length(l));

julia> v = rand(0.1:0.1:0.5, n_assets, length(l))
6×4 Matrix{Float64}:
 0.3  0.3  0.3  0.1
 0.4  0.3  0.4  0.4
 0.3  0.2  0.1  0.4
 0.5  0.3  0.3  0.3
 0.5  0.3  0.5  0.4
 0.2  0.1  0.5  0.4

julia> res = covx̂ₜ₊₁ₖx̂ₜ₊₁ₕfunc(x, l, β̂, w, v)
6×6 Matrix{Float64}:
 0.00614701  0.00628448  0.00650497  0.00586764  0.0059775   0.00620744
 0.00628448  0.00702342  0.00763972  0.00644602  0.00661685  0.00712454
 0.00650497  0.00763972  0.00814097  0.00689296  0.00720555  0.00815156
 0.00586764  0.00644602  0.00689296  0.00589798  0.00608306  0.00665605
 0.0059775   0.00661685  0.00720555  0.00608306  0.00623644  0.00669175
 0.00620744  0.00712454  0.00815156  0.00665605  0.00669175  0.00694747

julia> issymmetric(res)
true
```
"""
function covx̂ₜ₊₁ₖx̂ₜ₊₁ₕfunc(
  xₜ::AbstractMatrix,
  𝑙::AbstractVector{<:AbstractVector{<:Integer}},
  β̂::AbstractArray{<:AbstractFloat, 3},
  w::Int,
  v::AbstractMatrix
)
  n_assets = size(xₜ, 1)
  L = length(𝑙)
  vₜₖₕ = zeros(n_assets, n_assets, L)
  for k ∈ 1:n_assets
    for h ∈ 1:n_assets
      sum_ = 0.
      for l ∈ 1:length(𝑙)
        vₖ⁽ˡ⁾ = v[k, l]
        vₕ⁽ˡ⁾ = v[h, l]
        sum_ += vₖ⁽ˡ⁾*vₕ⁽ˡ⁾
        vₜₖₕ[k, h, l] += isnan(vₖ⁽ˡ⁾*vₕ⁽ˡ⁾/sum_) ? 0. : vₖ⁽ˡ⁾*vₕ⁽ˡ⁾/sum_
      end
    end
  end
  covx̂ₜ₊₁ₖx̂ₜ₊₁ₕ = zeros(n_assets, n_assets)
  for k ∈ 1:n_assets
    for h ∈ k:n_assets
      for (idx_l, l) ∈ enumerate(𝑙)
        covx̂ₜ₊₁ₖx̂ₜ₊₁ₕ[k, h] += covx̂ₜ₊₁⁽ˡ⁾x̂ₜ₊₁⁽ˡ⁾func(xₜ, l, β̂[k, :,idx_l], w)*vₜₖₕ[k, h, idx_l]
      end
    end
  end
  return covx̂ₜ₊₁ₖx̂ₜ₊₁ₕ |> Symmetric |> Matrix
end

"""
    cₜ₊₁func(
      x̂ₜ₊₁::AbstractVector,
      Σ̂ₜ₊₁::AbstractMatrix,
      γ::AbstractFloat,
      ξ::AbstractFloat,
      b̂ₜ::AbstractVector
    )

Obtain optimal ``c_{t+1}`` using the quadratic programming.

# Arguments
- `x̂ₜ₊₁::AbstractVector`: A vector of length `n_assets` containing the aggregated price \
  relatives predictions for all assets.
- `Σ̂ₜ₊₁::AbstractMatrix`: A matrix of size `n_assets` × `n_assets` containing the aggregated \
  predicted covariance of price relatives for all assets.
- `γ::AbstractFloat`: tradeoff parameter.
- `ξ::AbstractFloat`: tradeoff parameter.
- `b̂ₜ::AbstractVector`: A vector of length `n_assets` containing the current portfolio \
  weights.

# Returns
- `::AbstractVector`: A vector of length `n_assets` containing the optimal ``c-{t+1}`` values.

# Formula
``{c_{t + 1}} = \\mathop {\\arg \\min }\\limits_c \\left\\{ {\\gamma {c^T}{{\\hat \\sum }_{t + 1}}c + (2\\gamma \\hat b_t^T{{\\hat \\sum }_{t + 1}} - {{\\hat x}_{t + 1}})c + \\xi {{\\left\\| c \\right\\|}_1}} \\right\\}``

# Example
```julia
julia> x̂ₜ₊₁ = [0.9884, 1.02564, 1.01561];

julia> Σ̂ₜ₊₁ = rand(3, 3);

julia> gam = 0.02;

julia> kasi = 0.03;

julia> b = [0.5, 0.1, 0.4];

julia> cₜ₊₁func(x̂ₜ₊₁, Σ̂ₜ₊₁, gam, kasi, b)
3-element Vector{Float64}:
 -2.9150875774231594e-7
  2.2657563630445562e-7
  6.493312143784338e-8
```
"""
function cₜ₊₁func(
  x̂ₜ₊₁::AbstractVector,
  Σ̂ₜ₊₁::AbstractMatrix,
  γ::AbstractFloat,
  ξ::AbstractFloat,
  b̂ₜ::AbstractVector
)
  n_assets = length(x̂ₜ₊₁)
  model = Model(optimizer_with_attributes(Optimizer, "print_level" => 0))
  @variable(model, c[1:n_assets])
  @constraint(model, sum(c) == 0)
  @variable(model, t[1:n_assets] >= 0)
  @constraint(model, t .>= c)
  @constraint(model, t .>= -c)
  @objective(model, Min, γ*c'*Σ̂ₜ₊₁*c + c'*((2γ*b̂ₜ'*Σ̂ₜ₊₁)'-x̂ₜ₊₁) + ξ*sum(t))
  optimize!(model)
  return value.(c)
end

"""
    oldem(
      rel_pr::AbstractMatrix,
      horizon::S,
      w::S,
      L::S,
      s::S,
      σ::T,
      ξ::T,
      γ::T;
      bt::AbstractVector = ones(size(rel_pr, 1))/size(rel_pr, 1)
    ) where {S<:Integer, T<:AbstractFloat}

Run Online Low Dimension Ensemble Method (OLDEM).

# Arguments
- `rel_pr::AbstractMatrix`: A matrix of size `n_assets` × `T` containing the price relatives \
  of assets.
- `horizon::S`: Investment horizon.
- `w::S`: Window size.
- `L::S`: Number of subsystems.
- `s::S`: Number of assets in each subsystem.
- `σ::T`: Kernel bandwidth.
- `ξ::T`: tradeoff parameter.
- `γ::T`: tradeoff parameter.

## Keyword Arguments
- `bt::AbstractVector`: A vector of length `n_assets` containing the initial portfolio \
  weights. Presumebly, the initial portfolio portfolio is the equally weighted portfolio. \
  However, one can use any other portfolio weights that satisfy the following condition: \
  ``\\sum_{i=1}^{n\\_assets} b_{i} = 1``.
- `progress::Bool=false`: Show the progress bar.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An object of type [`OPSAlgorithm`](@ref).

# Example
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["MSFT", "TSLA", "AAPL", "META", "MMM"];

julia> querry = [
         get_prices(ticker, startdt="2020-01-01", enddt="2020-01-15")["adjclose"]
         for ticker in tickers
       ];

julia> prices = stack(querry) |> permutedims;

julia> x = prices[:, 2:end]./prices[:, 1:end-1]
5×8 Matrix{Float64}:
 0.987548  1.00259  0.990882  1.01593  1.01249   0.995373  1.01202  0.992957
 1.02963   1.01925  1.0388    1.0492   0.978055  0.993373  1.09769  1.02488
 0.990278  1.00797  0.995297  1.01609  1.02124   1.00226   1.02136  0.986497
 0.994709  1.01883  1.00216   1.01014  1.01431   0.998901  1.01766  0.987157
 0.991389  1.00095  0.995969  1.01535  1.00316   0.995971  1.00249  1.00249

julia> σ = 0.025;
julia> w = 2;
julia> h = 4;
julia> L = 4;
julia> s = 3;

julia> model = oldem(x, h, w, L, s, σ, 0.002, 0.25);

julia> model.b
5×4 Matrix{Float64}:
 0.2  1.99964e-8  1.0         0.0
 0.2  1.0         0.0         0.0
 0.2  0.0         0.0         1.99964e-8
 0.2  0.0         0.0         1.0
 0.2  0.0         1.99964e-8  0.0
```

# References
> [Online portfolio selection with predictive instantaneous risk assessment](https://doi.org/10.1016/j.patcog.2023.109872)
"""
function oldem(
  rel_pr::AbstractMatrix,
  horizon::S,
  w::S,
  L::S,
  s::S,
  σ::T,
  ξ::T,
  γ::T;
  bt::AbstractVector = ones(size(rel_pr, 1))/size(rel_pr, 1),
  progress::Bool=false
) where {S<:Integer, T<:AbstractFloat}
  n_assets, n_samples = size(rel_pr)
  sum(bt)≈1               || ArgumentError("sum(bt) != 1")         |> throw
  horizon>0               || ArgumentError("horizon<0 is invalid") |> throw
  w>0                     || ArgumentError("w<0 is invalid")       |> throw
  L>0                     || ArgumentError("L<0 is invalid")       |> throw
  s>0                     || ArgumentError("s<0 is invalid")       |> throw
  s<L                     || ArgumentError("s>L is invalid")       |> throw
  σ>0                     || ArgumentError("σ<0 is invalid")       |> throw
  ξ>0                     || ArgumentError("ξ<0 is invalid")       |> throw
  γ>0                     || ArgumentError("γ<0 is invalid")       |> throw
  all(bt.>=0)             || ArgumentError("bt[i]<0 is invalid")   |> throw
  L<binomial(n_assets, s) || DomainError("L is too large. L should be less than \
  $(binomial(n_assets, s)). Either add more assets or decrease `L`. Note that increasing \
  `s` might help.") |> throw
  n_samples>horizon+w     || DomainError("=> Inadequate number of data sample(s) are provided. \
  Either provide $(horizon+w-n_samples+1) more data samples or decrease `horizon` and/or \
  `w`.") |> throw
  n_samples>2w+horizon-1  || DomainError("=> Inadequate number of data sample(s) are provided. \
  Either provide $(2w+horizon-1-n_samples+1) more data samples or decrease `horizon` and/or \
  `w`.") |> throw
  b = similar(rel_pr, n_assets, horizon)
  b[:, 1] = bt
  l = createLDES(L, s, n_assets)

  for t ∈ 1:horizon-1
    x = rel_pr[:, 1:end-horizon+t]
    x̂ₜ₊₁, vₜ, β̂ₖ = x̂ₜ₊₁func(x, l, σ, w, n_samples-horizon+t)
    Σ̂ₜ₊₁ = covx̂ₜ₊₁ₖx̂ₜ₊₁ₕfunc(rel_pr[:, end-horizon-w+t:end-horizon+t-1], l, β̂ₖ, w, vₜ)
    cₜ₊₁ = cₜ₊₁func(x̂ₜ₊₁, Σ̂ₜ₊₁, γ, ξ, bt)
    bₜ₊₁ = cₜ₊₁ + bt
    b[:, t+1] = normptf(bₜ₊₁)
    progress && progressbar(stdout, horizon-1, t)
  end

  any(b.<0) && b |> positify! |> normalizer!
  return OPSAlgorithm(n_assets, b, "OLDEM")
end
