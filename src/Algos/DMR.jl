using Statistics, LinearAlgebra

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

function Afunc(x::AbstractMatrix, ηₖ::Integer, n::Integer, w::Integer)
  n_assets = size(x, 1)
  corrmat = cor(x, dims=2)
  Eₛ = corrmat .> ηₖ
  setdiag!(Eₛ, false)
  S = max.(corrmat, ηₖ)
  DC = sum(Eₛ, dims=1) |> vec
  Vₜₒₚ = sortperm(DC, rev=true)[1:n]
  E = [all(in.(item, Ref(Vₜₒₚ))) ? item : nothing for item=getproperty.(findall(Eₛ), :I)]
end

x = rand(3, 5)
eta = 0
b = Afunc(x, eta, 3, 3)
@code_warntype Afunc(x, eta, 3, 3)
