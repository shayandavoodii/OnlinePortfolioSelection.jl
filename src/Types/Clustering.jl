abstract type ClusteringModel end

"""
    KMNModel(alg::String="KMNLOG")<:ClusteringModel

`KMNModel` is a concrete type used to represent the KMNLOG Model.

# Fields
- `alg::String="KMNLOG"`: The algorithm's name to be used.

!!! warning
    Do not try to change the value of `alg` field.
"""
@kwdef struct KMNModel<:ClusteringModel
  alg::String="KMNLOG"
end

"""
    KMDModel(alg::String="KMDLOG")<:ClusteringModel

`KMDModel` is a concrete type used to represent the KMDLOG Model.

# Fields
- `alg::String="KMDLOG"`: The algorithm's name to be used.

!!! warning
    Do not try to change the value of `alg` field.
"""
@kwdef struct KMDModel<:ClusteringModel
  alg::String="KMDLOG"
end
