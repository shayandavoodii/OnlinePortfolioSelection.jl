module ClusLogModelExt

using OnlinePortfolioSelection, Clustering
using JuMP
using Ipopt
using Statistics
using LinearAlgebra
using Distances
using DataStructures

"""
    function cluslog(
      rel_pr::AbstractMatrix{<:AbstractFloat},
      horizon::Int,
      TW::Int,
      clus_mod::Type{<:ClusteringModel},
      nclusters::Int,
      nclustering::Int,
      boundries::NTuple{2, AbstractFloat};
      log::Bool=true
    )

Run KMNLOG, KMDLOG, etc., algorithms on the given data.

# Arguments
- `rel_pr::AbstractMatrix{<:AbstractFloat}`: Relative prices of assets. Each column
  represents the price of an asset at a given time.
- `horizon::Int`: Number of trading days.
- `TW::Int`: Maximum time window length to be examined.
- `clus_mod::Type{<:ClusteringModel}`: Clustering model to be used. Currently, only
  `KmeansModel` and `KmedoidsModel` are supported.
- `nclusters::Int`: The maximum number of clusters to be examined.
- `nclustering::Int`: The number of times clustering algorithm is run for optimal
  number of clusters.
- `boundries::NTuple{2, AbstractFloat}`: The lower and upper boundries for the
  weights of assets in the portfolio.

# Keyword Arguments
- `log::Bool=true`: Whether to log the progress or not.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
Two clustering model is available as of now: KmeansModel, and KmedoidsModel. The first \
example utilizes `KmeansModel`:
```julia
julia> using OnlinePortfolioSelection

julia> adj_close = [
         1.5464 1.5852 1.6532 1.7245 1.5251 1.4185 1.2156 1.3231 1.3585 1.4563 1.4456
         1.2411 1.2854 1.3456 1.4123 1.5212 1.5015 1.4913 1.5212 1.5015 1.4913 1.5015
         1.3212 1.3315 1.3213 1.3153 1.3031 1.2913 1.2950 1.2953 1.3315 1.3213 1.3315
       ]

julia> rel_pr = adj_close[:, 2:end]./adj_close[:, 1:end-1]

julia> horizon = 3; TW = 3; nclusters_ = 3; nclustering = 10; lb, ub = 0.0, 1.;

julia> model = cluslog(rel_pr, horizon, TW, KmeansModel, nclusters_, nclustering, (lb, ub));

julia> model.b
3×3 Matrix{Float64}:
 0.00264911  0.00317815  0.148012
 0.973581    0.971728    0.848037
 0.02377     0.0250939   0.00395028

julia> sum(model.b , dims=1) .|> isapprox(1.) |> all
true
```

The same approach works for `KmedoidsModel` as well:

```julia
julia> model = cluslog(rel_pr, horizon, TW, KmedoidsModel, nclusters_, nclustering, (lb, ub));

julia> model.b
3×3 Matrix{Float64}:
 4.59938e-7  4.96421e-7  4.89426e-7
 0.999998    0.999997    0.999997
 2.02964e-6  2.02787e-6  2.02964e-6

julia> sum(model.b , dims=1) .|> isapprox(1.) |> all
true
```

# Reference
> [An online portfolio selection algorithm using clustering approaches and considering transaction costs](https://doi.org/10.1016/j.eswa.2020.113546)
"""
function OnlinePortfolioSelection.cluslog(
  rel_pr::AbstractMatrix{<:AbstractFloat},
  horizon::Int,
  TW::Int,
  clus_mod::Type{<:ClusteringModel},
  nclusters::Int,
  nclustering::Int,
  boundries::NTuple{2, AbstractFloat};
  progress::Bool=true
)
  nassets, nperiods = size(rel_pr)
  nperiods > horizon || DomainError("horizon must be less than the number of \
    samples (columns) in rel_pr"
  ) |> throw
  TW ≥ 2 || DomainError("`TW` must be ≥ 2") |> throw
  nclusters ≥ 2 || DomainError("`nclusters` must be ≥ 2") |> throw
  nclustering ≥ 1 || DomainError("`nclustering` must be ≥ 1") |> throw
  boundries[1] < boundries[2] || DomainError("The first element of `boundries` must be \
    less than the second element"
  ) |> throw
  boundries[1] ≥ 0 || DomainError("The first element of `boundries` must be ≥ 0") |> throw
  0 < boundries[2] ≤ 1 || DomainError("The second element of `boundries` must be ∈ (0, 1]"
  ) |> throw
  boundries[1] < 1/nassets || DomainError("The first element of `boundries` must be \
    less than 1/$(nassets)"
  ) |> throw
  TW < nperiods-horizon+1 || DomainError("`TW` must be < $(nperiods-horizon+1). Either \
    provide more data point, or decrease `horizon` or decrease `TW`."
  ) |> throw
  nclusters ≤ nperiods-horizon || DomainError("`nclusters` must be less than or equal to \
  $(nperiods-horizon). This is because of the provided amount of data") |> throw
  horizon > 0 || DomainError("`horizon` must be > 0") |> throw

  b = zeros(nassets, horizon)
  for idx_day ∈ 1:horizon
    rel_pr_ = @view rel_pr[:, 1:end-horizon+idx_day]
    for tw ∈ 2:TW
      ntw           = size(rel_pr_, 2) - tw + 1
      cor_tw        = cor_between_tws(rel_pr_, tw, ntw)
      optimal_nclus = nclusopt(clus_mod, cor_tw, nclusters)
      idx_sim_tws   = clustering(clus_mod, cor_tw, optimal_nclus, nclustering)
      isempty(idx_sim_tws) || pop!(idx_sim_tws)
      if isempty(idx_sim_tws)
        if idx_day==1
          b[:, idx_day] = ones(nassets)/nassets
        else
          b[:, idx_day] = OnlinePortfolioSelection.bAdjusted(b[:, idx_day-1], rel_pr_[:, end])
        end
      else
        day_after_similar_tws        = idx_sim_tws.+tw
        rel_pr_day_after_similar_tws = @view rel_pr_[:, day_after_similar_tws]
        cor_similar_tws              = cor_tw[end, idx_sim_tws]
        b[:, idx_day]                = optimization(cor_similar_tws, rel_pr_day_after_similar_tws, boundries)
      end
    end
    progress && OnlinePortfolioSelection.progressbar(stdout, horizon, idx_day)
  end
  return OPSAlgorithm(nassets, b, clus_mod===KmeansModel ? "KMNLOG" : "KMDLOG")
end

function logger(n::Int)
  @info "Analysis for trading day $n is done."
end

function cor_between_tws(rel_pr::AbstractMatrix{<:AbstractFloat}, len_tw, ntw)
  nassets = size(rel_pr, 1)
  cor_tw  = ones(Float64, ntw, ntw)

  for idx₁ ∈ 1:ntw-1
    coef = idx₁-1
    a = 1+nassets*coef
    b = a+(len_tw*nassets-1)
    for (counter_, idx₂) ∈ enumerate(idx₁+1:ntw)
      a_                 = a+(nassets*counter_)
      b_                 = a_+(len_tw*nassets-1)
      vec₁               = @view rel_pr[a:b]
      vec₂               = @view rel_pr[a_:b_]
      cor_tw[idx₁, idx₂] = cor(vec₁, vec₂)
    end
  end

  return Symmetric(cor_tw) |> Matrix
end

function nclusopt(model::Type{<:ClusteringModel}, cor_tw, nclusters)
  sils      = zeros(Float64, nclusters)
  for nclus ∈ 2:nclusters
    fitted  = clustering(model, cor_tw, nclus)
    dists   = pairwise(Euclidean(), cor_tw)
    sils[nclus-1] = silhouettes(assignments(fitted), counts(fitted), dists) |> mean
  end
  return argmax(sils) + 1
end

"""
    identityfinder(model, idxLastTW)

Find the index of time windows that are in the same cluster as the latest time window.
"""
function identityfinder(model, idxLastTW)
  identities                   = assignments(model)
  indice_latest_tw_cluster     = identities[idxLastTW]
  idx_tws_in_latest_tw_cluster = findall(
    identities .== indice_latest_tw_cluster
  )
  return idx_tws_in_latest_tw_cluster
end

function clustering(::Type{KmeansModel}, cor_tw, nclusters)
  fitted = kmeans(cor_tw, nclusters)
  return fitted
end

function clustering(::Type{KmedoidsModel}, cor_tw, nclusters)
  dists  = pairwise(Euclidean(), cor_tw)
  fitted = kmedoids(dists, nclusters)
  return fitted
end

function clustering(model::Type{<:ClusteringModel}, cor_tw, nclusters, nclustering)
  twoccurance = Vector{Int}(undef, 0)
  ntw         = size(cor_tw, 1)
  for clus_time ∈ 1:nclustering
    fitted      = clustering(model, cor_tw, nclusters)
    idx_sim_TWs = identityfinder(fitted, ntw)
    push!(twoccurance, idx_sim_TWs...)
  end
  counter_    = counter(twoccurance)
  thresh      = round(Int, 0.8*nclustering)
  idx_sim_TWs = filter(x -> counter_[x] ≥ thresh, keys(counter_))
  return idx_sim_TWs |> OrderedSet |> sort |> collect
end

function optimization(corrs::AbstractVector, relpr::AbstractMatrix, boundries::NTuple{2, AbstractFloat})
  lb, ub   = boundries
  nassets  = size(relpr, 1)
  optmodel = Model(Ipopt.Optimizer)
  @variable(optmodel, lb ≤ w[1:nassets] ≤ ub)
  @constraint(optmodel, sum(w)==1)
  @NLobjective(
    optmodel,
    Max,
    sum(
      corrs[i] * log10(
        sum(
          w[j] * relpr[j, i]
          for j ∈ 1:nassets
        )
      )
      for i ∈ 1:length(corrs)
    )
  )
  set_silent(optmodel)
  optimize!(optmodel)
  return value.(w)
end

end #module
