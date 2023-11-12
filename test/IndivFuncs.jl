@testset "IndivFuncs.jl" begin
  v = [0.5, -0.8, 0.3]
  @test OnlinePortfolioSelection.positify(v) == [0.5, 0.0, 0.3]
  @test OnlinePortfolioSelection.positify(v) !== v
  @test OnlinePortfolioSelection.positify!(v) == [0.5, 0.0, 0.3]
  @test v == [0.5, 0.0, 0.3]
end
