@testset "IndivFuncs.jl" begin
  v = [0.5, -0.8, 0.3]
  @test OnlinePortfolioSelection.positify(v) == [0.5, 0.0, 0.3]
  @test OnlinePortfolioSelection.positify(v) !== v
  @test OnlinePortfolioSelection.positify!(v) == [0.5, 0.0, 0.3]
  @test v == [0.5, 0.0, 0.3]
end

@testset "tools.jl" begin
  p = rand(3, 10)
  r = p[:, 2:end] ./ p[:, 1:end-1]
  @test OnlinePortfolioSelection.pred_relpr(SMAP(), p, 3) ≈
    OnlinePortfolioSelection.pred_relpr(SMAR(), r, 3)
end
