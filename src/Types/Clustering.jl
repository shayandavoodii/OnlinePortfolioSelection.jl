abstract type ClusteringModel end

@kwdef struct KmeansModel<:ClusteringModel
  alg::String="KMNLOG"
end
@kwdef struct KmedoidsModel<:ClusteringModel
  alg::String="KMDLOG"
end
