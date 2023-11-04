"""
    OPSAlgorithm{T<:Float64}

A `OPSAlgorithm` object that contains the result of running the algorithm.

# Fields
- `n_asset::Int`: Number of assets in the portfolio.
- `b::Matrix{T}`: Weights of the created portfolios.
- `alg::String`: Name of the algorithm.
"""
struct OPSAlgorithm{T<:AbstractFloat}
  n_assets::Int
  b::Matrix{T}
  alg::String
end
