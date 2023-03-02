using Statistics
using LinearAlgebra

struct RPRT
  n_assets::Int
  weights::Matrix{Float64}
  budgets::Vector{Float64}
end;

function RPRT(adj_close::Matrix{Float64}, w::Int64, θ::Float64=0.8, ϵ=50)
  @assert w≥2 "Window length (w) must be greater than 1"

  n_assets = size(adj_close, 2)

  ϕ = adj_close[2, :]/adj_close[1, :]

  # Initialize the weights
  w = ones(n_assets)/n_assets

  for t in axes(adj_close, 2)
    if t≤w
      prediction = predict_relative_price(adj_close[:, 1:t])

      if t==1
        last_relative_price = ones(n_assets)
      else
        last_relative_price = adj_close[:, t]./adj_close[:, t-1]
      end

    else
      prediction = predict_relative_price(adj_close[:, t-w+1:t])
      last_relative_price = adj_close[:, t]./adj_close[:, t-1]
    end

    # prediction[:] results in a 1D array (Vector)
    d_pred = diagm(prediction[:])

    # predicted γ
    γₚ = θ * last_relative_price / (θ*last_relative_price+ϕ)

    # predicted ϕ
    ϕₚ = γₚ + (1-γₚ)*(ϕ/last_relative_price)

    ϕ = ϕₚ

    # Update the weights

  end
end;

function predict_relative_price(adj_close::Matrix{Float64}))
  mean(adj_close, dims=2)./adj_close[1, :]
end;
