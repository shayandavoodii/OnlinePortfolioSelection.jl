const METHODS1 = (:CORN, :DRICORN)

function simplex_proj(b::Vector)
  n_assets = length(b)
  cond = false

  sorted_b = sort(b, rev=true)

  tmpsum = 0.
  for i in 1:n_assets-1
    tmpsum += sorted_b[i]
    tmax = (tmpsum - 1.)/i
    if tmax≥sorted_b[i+1]
      cond = true
      break
    end
  end

  if !cond
    tmax = (tmpsum + sorted_b[n_assets-1] - 1.)/n_assets
  end

  max.(b .- tmax, 0.)
end;

function mc_simplex(d, points)
  a = sort(rand(points, d), dims=2)
  a = [zeros(points) a ones(points)]
  diff(a, dims=2)
end;

"""
    invest(
      method::Symbol,
      horizon::Int,
      weights::Matrix{Float64},
      reltv_pr::Matrix{Float64},
      initial_budget
    )

  Invest the budget in the assets according to the given weights in the given horizon.

  # Arguments
  - `method::Symbol`: The method that is used for investment.
  - `horizon::Int`: The number of periods that the investment is made.
  - `weights::Matrix{Float64}`: The weights of the assets in each period.
  - `reltv_pr::Matrix{Float64}`: The relative prices of the assets in each period.
  - `initial_budget`: The initial budget.

  # Returns
  - `budgets::Vector{Float64}`: The budget during the investment horizon.
"""
function invest(
  method::Symbol,
  horizon::Int,
  weights::Matrix{Float64},
  reltv_pr::Matrix{Float64},
  initial_budget
)

  if method∈METHODS1
    return budg_dur_time(horizon, weights, reltv_pr, initial_budget)
  end
end;

function budg_dur_time(
  horizon::Int,
  weights::Matrix{Float64},
  reltv_pr::Matrix{Float64},
  initial_budget
)
  # Calculate budgets
  budgets = zeros(horizon+1)
  budgets[1] = initial_budget

  for t in 1:horizon
    @views budgets[t+1] = budgets[t] * sum(reltv_pr[:, end-horizon+t] .* weights[:, t])
  end

  budgets
end
