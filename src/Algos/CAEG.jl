"""
    caeg(rel_pr::AbstractMatrix, ηs::AbstractVector)

Run CAEG algorithm.

# Arguments
- `rel_pr::AbstractMatrix`: Historical relative prices. The paper's authors used *"the \
  ratio of closing price to last closing price"*.
- `ηs::AbstractVector`: Learning rates.

!!! warning "Beware!"
    `rel_pr` should be a matrix of size `n_assets` × `n_periods`.

# Returns
- `::OPSAlgorithm`: An [`OPSAlgorithm`](@ref) object.

# Examples
```julia
julia> using OnlinePortfolioSelection, YFinance

julia> tickers = ["AAPL", "MSFT", "GOOG"];

julia> startdt, enddt = "2020-1-1", "2020-1-10";

julia> open_querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["open"] for ticker ∈ tickers];

julia> open_ = stack(open_querry) |> permutedims;

julia> close_querry = [get_prices(ticker, startdt=startdt, enddt=enddt)["adjclose"] for ticker ∈ tickers];

julia> close_ = stack(close_querry) |> permutedims;

julia> rel_pr = close_./open_;

julia> learning_rates = [0.02, 0.05];

julia> model = caeg(rel_pr, learning_rates);

julia> model.b
3×6 Matrix{Float64}:
 0.333333  0.333322  0.333286  0.333271  0.333287  0.333368
 0.333333  0.333295  0.333271  0.333171  0.333123  0.333076
 0.333333  0.333383  0.333443  0.333558  0.33359   0.333557
```

# References
> [Aggregating exponential gradient expert advice for online portfolio selection](https://doi.org/10.1080/01605682.2020.1848358)
"""
function caeg(rel_pr::AbstractMatrix, ηs::AbstractVector)
  all(ηs .> 0) || ArgumentError("ηs must contain only positive values.") |> throw
  length(ηs) ≥ 2 || ArgumentError("ηs must contain at least two values.") |> throw
  n_assets, n_days = size(rel_pr)
  exp_weights      = (eg(rel_pr, eta=val).b for val = ηs)
  Sη               = sn.(exp_weights, Ref(rel_pr))
  b                = similar(rel_pr, n_assets, n_days)
  b[:, 1]          = ones(n_assets)/n_assets
  numerator_       = zeros(n_assets)
  denumerator_     = 0.
  for t ∈ 1:n_days-1
    for (idx, expert) ∈ enumerate(exp_weights)
      numerator_  .+= Sη[idx][t]^(1/√(t+1))*expert[:, t+1]
      denumerator_ += Sη[idx][t]^(1/√(t+1))
    end
    b[:, t+1]    = numerator_/denumerator_
    numerator_  .= 0.
    denumerator_ = 0.
  end
  return OPSAlgorithm(n_assets, b, "CAEG")
end
