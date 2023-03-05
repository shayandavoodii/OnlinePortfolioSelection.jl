function simplex_proj(b::Vector)
  n_assets = length(b)
  cond = false

  sorted_b = sort(b, rev=true)
  tmpsum = 0.

  for i in 1:n_assets-1
    tmpsum += sorted_b[i]
    tmax = (tmpsum - 1.)/i
    if tmax≥sorted_b[i]
      cond = true
      break
    end
  end

  if !cond
    tmax = (tmpsum + sorted_b[n_assets] - 1.)/n_assets
  end

  max.(b .- tmax, 0.)
end;

function mc_simplex(d, points)
  a = sort(rand(d, points), dims=2)
  a = [zeros(d) a ones(d)]
  diff(a, dims=2)
end;
