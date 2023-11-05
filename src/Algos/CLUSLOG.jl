"""
    cluslog()
    cluslog(
      rel_pr::AbstractMatrix{<:AbstractFloat},
      horizon::Int,
      TW::Int,
      clus_mod::Type{<:ClusteringModel},
      nclusters::Int,
      nclustering::Int,
      boundries::NTuple{2, AbstractFloat};
      progress::Bool=true
    )

You need to install and import the following packages before using this function:
- `Clustering`

```julia
julia> using Pkg

julia> Pkg.add(name="Clustering", version="0.15.2")

julia> using OnlinePortfolioSelection, Clustering
```

    cluslog(
      rel_pr::AbstractMatrix{<:AbstractFloat},
      horizon::Int,
      TW::Int,
      clus_mod::Type{<:ClusteringModel},
      nclusters::Int,
      nclustering::Int,
      boundries::NTuple{2, AbstractFloat};
      progress::Bool=true
    )

Run KMNLOG, KMDLOG, etc., algorithms on the given data.

# Arguments
- `rel_pr::AbstractMatrix{<:AbstractFloat}`: Relative prices of assets. Each column \
represents the price of an asset at a given time.
- `horizon::Int`: Number of trading days.
- `TW::Int`: Maximum time window length to be examined.
- `clus_mod::Type{<:ClusteringModel}`: Clustering model to be used. Currently, only \
[`KMNModel`](@ref) and [`KMDModel`](@ref) are supported.
- `nclusters::Int`: The maximum number of clusters to be examined.
- `nclustering::Int`: The number of times clustering algorithm is run for optimal \
number of clusters.
- `boundries::NTuple{2, AbstractFloat}`: The lower and upper boundries for the \
weights of assets in the portfolio.

# Keyword Arguments
- `progress::Bool=true`: Whether to log the progress or not.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Example
Two clustering model is available as of now: [`KMNModel`](@ref), and [`KMDModel`](@ref). \
The first example utilizes [`KMNModel`](@ref):

```julia
julia> using OnlinePortfolioSelection, Clustering

julia> adj_close = [
         1.5464 1.5852 1.6532 1.7245 1.5251 1.4185 1.2156 1.3231 1.3585 1.4563 1.4456
         1.2411 1.2854 1.3456 1.4123 1.5212 1.5015 1.4913 1.5212 1.5015 1.4913 1.5015
         1.3212 1.3315 1.3213 1.3153 1.3031 1.2913 1.2950 1.2953 1.3315 1.3213 1.3315
       ]

julia> rel_pr = adj_close[:, 2:end]./adj_close[:, 1:end-1]

julia> horizon = 3; TW = 3; nclusters_ = 3; nclustering = 10; lb, ub = 0.0, 1.;

julia> model = cluslog(rel_pr, horizon, TW, KMNModel, nclusters_, nclustering, (lb, ub));

julia> model.b
3×3 Matrix{Float64}:
0.00264911  0.00317815  0.148012
0.973581    0.971728    0.848037
0.02377     0.0250939   0.00395028

julia> sum(model.b , dims=1) .|> isapprox(1.) |> all
true
```

The same approach works for [`KMDModel`](@ref) as well:

```julia
julia> using OnlinePortfolioSelection, Clustering

julia> model = cluslog(rel_pr, horizon, TW, KMDModel, nclusters_, nclustering, (lb, ub));

julia> model.b
3×3 Matrix{Float64}:
4.59938e-7  4.96421e-7  4.89426e-7
0.999998    0.999997    0.999997
2.02964e-6  2.02787e-6  2.02964e-6

julia> sum(model.b , dims=1) .|> isapprox(1.) |> all
true
```

See also [`KMNModel`](@ref), and [`KMDModel`](@ref).

# Reference
> [An online portfolio selection algorithm using clustering approaches and considering transaction costs](https://doi.org/10.1016/j.eswa.2020.113546)
"""
function cluslog end
