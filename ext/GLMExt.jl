module GLMExt

using GLM
using OnlinePortfolioSelection

function OnlinePortfolioSelection.ttest(SB::AbstractVector, Sₜ::AbstractVector, SF::AbstractFloat)
  length(SB)==length(Sₜ) || ArgumentError("`SB` and `Sₜ` should have equal length. `SB` \
    has $(length(SB)), `Sₜ` has $(length(Sₜ))"
  ) |> throw
  y   = Sₜ .- SF
  x   = SB .- SF
  return lm(@formula(y~x), (;x, y))
end

end # module
