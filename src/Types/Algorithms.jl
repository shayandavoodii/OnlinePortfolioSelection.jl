"""
    OPSAlgorithm{T<:Float64}

A `CORN` object that contains the weights of the portfolio, Sₙ, and the number of assets.

# Fields
- `n_asset::Int`: Number of assets in the portfolio.
- `b::Matrix{T}`: Weights of the created portfolios.
- `budgets::Vector{T}`: Budget during the investment horizon.
- `type::String`: The type of CORN algorithm. It can be either "CORN-U" or "CORN-K".

The formula for calculating the cumulative return of the portfolio is as follows:

```math
{S_n} = {S_0}\\prod\\limits_{t = 1}^T {\\left\\langle {{b_t},{x_t}} \\right\\rangle }
```

where ``S₀`` is the initial budget, ``n`` is the investment horizon, ``b_t`` is the vector \
of weights of the period ``t``, and ``x_t`` is the relative price of the ``t``-th period.
"""
struct OPSAlgorithm{T<:Float64}
  n_assets::Int
  b::Matrix{T}
  budgets::Vector{T}
  alg::String
end
