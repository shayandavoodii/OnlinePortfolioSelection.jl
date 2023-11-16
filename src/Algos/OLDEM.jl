using StatsBase: sample
"""
    createLDES(L::T, s::T, n_assets::T) where T<:Int

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
function createLDES(L::T, s::T, n_assets::T) where T<:Int
  return [sample(1:n_assets, s, replace=false) for 𝑙=1:L]
end

"""
    createXₜ⁽ˡ⁾(w::T, t::T, 𝑙::AbstractVector{<:Int}, x::AbstractMatrix) where T<:Int

Create a matrix of size `w` × `length(𝑙)` where ``w=i-t`` and ``𝑙={𝑙₁, 𝑙₂, \\ltods, 𝑙ₛ}``.

# Arguments
- `w::T`: Window size.
- `t::T`: Current time index.
- `𝑙::AbstractVector{<:Int}`: A vector of length `s` containing index of assets in the LDE.
- `x::AbstractMatrix`: A matrix of size `n_assets` × `t` containing the price relatives of \
assets.

# Returns
- `::AbstractMatrix`: A Xₜ⁽ˡ⁾ matrix of size ``t-i \\times j``. Where ``i=1,2,\\ldots ,w`` \
and ``j=1,2,\\ldots ,s``. Note that `length(𝑙)=s`.

# Example:
```julia
julia> x = rand(0.8:0.001:1.2, 6, 10)
6×10 Matrix{Float64}:
 1.058  1.158  1.067  0.803  0.977  1.175  0.954  1.075  1.099  1.035
 1.01   1.068  0.875  0.873  0.934  0.884  1.198  1.073  1.127  1.098
 0.897  1.115  0.995  0.833  1.151  0.839  1.104  1.166  1.151  1.11
 0.829  0.893  1.046  0.956  1.057  1.119  1.109  1.095  1.059  0.82
 1.145  1.014  0.87   1.137  1.029  0.904  1.095  1.111  1.079  1.109
 1.023  0.992  1.059  1.15   0.915  0.916  1.137  0.9    1.033  0.864

 julia> createXₜ⁽ˡ⁾(3, 5, [2, 4, 6, 3], x)
3×4 Matrix{Float64}:
 0.873  0.956  1.15   0.833
 0.875  1.046  1.059  0.995
 1.068  0.893  0.992  1.115
```
"""
function createXₜ⁽ˡ⁾(w::T, t::T, 𝑙::AbstractVector{<:Int}, x::AbstractMatrix) where T<:Int
  all(𝑙.∈Ref(1:size(x, 1))) || DomainError("$𝑙 ∉ 1:$(size(x, 1))") |> throw
  t-w>0 || DomainError("t-w<0 is invalid") |> throw
  t>0   || DomainError("t<0 is invalid") |> throw
  return rotl90(x[𝑙, t-w:t-1])
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
julia> Xₜ⁽ˡ⁾ = rand(0.8:0.001:1.2, 3, 4)
3×4 Matrix{Float64}:
 0.832  0.914  1.106  0.805
 0.862  1.112  1.143  1.03
 0.922  1.114  1.092  0.835

julia> xₜₖ = rand(0.8:0.001:1.2, size(Xₜ⁽ˡ⁾, 1))
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
  return (Xₜ⁽ˡ⁾'*Xₜ⁽ˡ⁾)^-1*(Xₜ⁽ˡ⁾'*xₜₖ) |> vec
end

x̂ₜ₊₁ₖ⁽ˡ⁾func(xₜ⁽ˡ⁾::T, β̂ₖ⁽ˡ⁾::T) where T<:AbstractVector = sum(xₜ⁽ˡ⁾.*β̂ₖ⁽ˡ⁾)

"""
    Rₜ⁽ˡ⁾(xₜ::T, x̂ₜ⁽ˡ⁾::T, w::Int) where T<:AbstractMatrix

Calculate the mean squared error for all assets.

# Arguments
- `xₜ::T`: A matrix of size `n_assets` × `T` containing the price relatives of assets where \
  ``T=t-i`` and ``i=0\\to w-1``.
- `x̂ₜ⁽ˡ⁾::T`: A matrix of size `n_assets` × `T` containing the estimated price relatives of \
  assets where ``T=t-i`` and ``i=0\\to w-1``.
- `w::Int`: Window size.

# Returns
- `::AbstractVector`: A vector of length `n_assets` containing the mean squared error \
  for all assets.
"""
function Rₜ⁽ˡ⁾(xₜ::T, x̂ₜ⁽ˡ⁾::T, w::Int) where T<:AbstractMatrix
  size(xₜ) == size(x̂ₜ⁽ˡ⁾) || DimensionMismatch("size(xₜ) != size(x̂ₜ⁽ˡ⁾)") |> throw
  w == size(xₜ, 2) || DimensionMismatch("w != size(xₜ, 2)") |> throw
  w>0 || DomainError("w<0 is invalid") |> throw
  return 1/w*(sum((xₜ .- x̂ₜ⁽ˡ⁾).^2, dims=2))
end

"""
    vₜ⁽ˡ⁾func(Rₜ::AbstractMatrix, σ::AbstractFloat)

Calculate weight of 𝑙'th subsystem.

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

julia> vₜ⁽ˡ⁾func(Rₜ, σ)
4×6 Matrix{Float64}:
 0.271464     9.43352e-11  1.58879e-8  0.631974     1.56574e-9  0.096562
 0.000689913  0.102539     0.292452    0.246573     0.354119    0.00362605
 0.000926364  0.138302     0.641032    0.0699813    0.149757    3.20621e-9
 2.58894e-5   0.88983      9.606e-11   1.91068e-11  0.110144    2.68181e-7
```
"""
function vₜfunc(Rₜ::AbstractMatrix, σ::AbstractFloat)
  numerator_ = exp.((-1*Rₜ)/(σ^2))
  vₜ = numerator_./sum(numerator_, dims=2)
  any(isnan.(vₜ)) && ArgumentError("Result contains NaN values. You may want to increase \
  σ.") |> throw
  return vₜ
end

"""
    x̂ₜ₊₁func(vₜ::T, x̂ₜ₊₁::T) where T<:AbstractMatrix

Calculate the aggregated price relatives predictions for all assets.

# Arguments
- `vₜ::T`: A matrix of size `n_assets` × `𝑙` containing the weight of 𝑙'th subsystem for all \
  assets.
- `x̂ₜ₊₁::T`: A matrix of size `n_assets` × `𝑙` containing the estimated price relatives of \
  assets for each subsystem ``l``.

# Returns
- `::AbstractVector`: A vector of length `n_assets` containing the aggregated price relatives \
  predictions for all assets.
"""
function x̂ₜ₊₁func(vₜ::T, x̂ₜ₊₁::T) where T<:AbstractMatrix
  size(vₜ) == size(x̂ₜ₊₁) || DimensionMismatch("size(vₜ) != size(x̂ₜ₊₁)") |> throw
  return sum(vₜ.*x̂ₜ₊₁, dims=2) |> vec
end

"""
    covxₜₗₚxₜₗqfunc(xₜ⁽ˡ⁾::AbstractMatrix, 𝑙::AbstractVector, w::Int)

Calculate the covariance of price relatives for ``lₚ`` and ``lq`` assets.

# Arguments
- `xₜ⁽ˡ⁾::AbstractMatrix`: A matrix of size `n_assets` × `w` containing the price relatives \
  of assets for ``t\to t-w+1``. Example: If w=3, then ``xₜ⁽ˡ⁾=\\left( x_{t}, x_{t-1}, \
  x_{t-2}`` for each asset.
- `𝑙::AbstractVector`: A vector of length `2` containing index of two assets in the LDE. \
  Example: ``𝑙=[2, 4]`` means that the second and the fourth assets are in the LDE.
- `w::Int`: Window size.

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
function covxₜₗₚxₜₗqfunc(xₜ⁽ˡ⁾::AbstractMatrix, 𝑙::AbstractVector, w::Int)
  length(𝑙)==2 || ArgumentError("length(𝑙) != 2") |> throw
  w==size(xₜ⁽ˡ⁾, 2) || DimensionMismatch("w != size(xₜ⁽ˡ⁾, 2)") |> throw
  x̄ₜₗₚ, x̄ₜₗq = mean(xₜ⁽ˡ⁾[𝑙, :], dims=2)
  𝑙ₚ, 𝑙q = 𝑙
  numerator_ = ((x[𝑙ₚ, end-i].-x̄ₜₗₚ)*(x[𝑙q, end-i].-x̄ₜₗq) for i=0:w-1) |> sum
  covxₜₗₚxₜₗq = numerator_/(w-1)
  return covxₜₗₚxₜₗq
end

"""
    covx̂ₜ₊₁⁽ˡ⁾x̂ₜ₊₁⁽ˡ⁾func(xₜ::AbstractMatrix, 𝑙::AbstractVector, β̂⁽ˡ⁾::AbstractVector, w::Int)

Calculate the predicted covariance of price relatives for ``lₚ`` and ``lq`` assets.

# Arguments
- `xₜ::AbstractMatrix`: A matrix of size `n_assets` × `w` containing the price relatives \
  of assets for ``t\to t-w+1``. Example: If w=3, then ``xₜ⁽ˡ⁾=\\left( x_{t}, x_{t-1}, \
  x_{t-2}`` for each asset.
- `𝑙::AbstractVector`: A vector of length ``s`` where ``s`` is the number of assets in the \
  LDE. Example: ``𝑙=[2, 4, 6]`` means that the second, the fourth, and the sixth assets are \
  in the LDE.
- `β̂⁽ˡ⁾::AbstractVector`: A vector of length ``s`` containing the estimated parameters for \
  each asset in the LDE.
- `w::Int`: Window size.

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

julia> x = xₜ[:, t-w+1:t]
6×3 Matrix{Float64}:
 0.802  0.837  0.837
 1.103  0.949  1.123
 1.086  1.192  0.817
 0.86   1.166  1.037
 0.859  1.098  0.934
 0.911  0.829  1.187

julia> 𝑙 = [2, 4, 6];

julia> β̂⁽ˡ⁾ = [0.1, 0.2, 0.3];

julia> t, w = 4, 3;

julia> covx̂ₜ₊₁⁽ˡ⁾x̂ₜ₊₁⁽ˡ⁾func(x, 𝑙, β̂⁽ˡ⁾, w)
0.0019026300000000015
```
"""
function covx̂ₜ₊₁⁽ˡ⁾x̂ₜ₊₁⁽ˡ⁾func(xₜ::AbstractMatrix, 𝑙::AbstractVector, β̂⁽ˡ⁾::AbstractVector, w::Int)
  cov_val = 0.
  for p ∈ 𝑙
    for q ∈ 𝑙
      cov_val += β̂⁽ˡ⁾[p]*β̂⁽ˡ⁾[q]*covxₜₗₚxₜₗqfunc(xₜ, [p, q], w)
    end
  end
  return cov_val
end

"""
    covx̂ₜ₊₁ₖx̂ₜ₊₁ₕfunc(
      xₜ::AbstractMatrix,
      𝑙::AbstractVector{AbstractVector{<:Int}},
      β̂::AbstractMatrix,
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
- `β̂::AbstractMatrix`: A matrix of size `n_assets` × `L` containing the estimated parameters \
  for each asset in the LDE.
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
julia> w = 3;

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

julia> β̂ = rand(0.1:0.1:0.5, n_assets, length(l))
6×4 Matrix{Float64}:
 0.3  0.3  0.3  0.5
 0.1  0.3  0.3  0.1
 0.1  0.5  0.3  0.2
 0.4  0.5  0.3  0.2
 0.1  0.4  0.3  0.5
 0.5  0.4  0.1  0.3

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
  𝑙,
  β̂::AbstractMatrix,
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
        vₜₖₕ[k, h, l] += vₖ⁽ˡ⁾*vₕ⁽ˡ⁾/sum_
      end
    end
  end

  covx̂ₜ₊₁ₖx̂ₜ₊₁ₕ = zeros(n_assets, n_assets)
  for k ∈ 1:n_assets
    for h ∈ k:n_assets
      for (idx_l, l) ∈ enumerate(𝑙)
        covx̂ₜ₊₁ₖx̂ₜ₊₁ₕ[k, h] += covx̂ₜ₊₁⁽ˡ⁾x̂ₜ₊₁⁽ˡ⁾func(xₜ, l, β̂[:, idx_l], w)*vₜₖₕ[k, h, idx_l]
      end
    end
  end
  return covx̂ₜ₊₁ₖx̂ₜ₊₁ₕ |> Symmetric |> Matrix
end

x = rand(0.8:0.001:1.2, 6, 10)
createXₜ⁽ˡ⁾(3, 5, [2, 4, 6], x)
