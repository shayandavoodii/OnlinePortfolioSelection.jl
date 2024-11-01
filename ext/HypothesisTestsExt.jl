module HypothesisTestsExt

using HypothesisTests
using OnlinePortfolioSelection

function OnlinePortfolioSelection.ttest(vec::AbstractVector{<:AbstractVector})
  length(vec)>1 || ArgumentError("There should exist more than one inner vector in the `vec`.") |> throw
  ndatasets, nalgs = length(vec[1]), length(vec)
  for item ∈ vec
    li = length(item)
    li==ndatasets || ArgumentError("Innert vectors should have the same size.") |> throw
    li>1 || ArgumentError("Inner vectors should contain more than an element.") |> throw
  end
  pvalmat = zeros(nalgs, nalgs)
  for i ∈ 1:nalgs, j ∈ i+1:nalgs
    pvalmat[i, j] = OneSampleTTest(vec[i], vec[j]) |> pvalue
  end
  return pvalmat
end

end #module
