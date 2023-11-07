p = [
  37.9433  34.1638  35.6223  35.543   36.2205  36.8356  36.9533  36.5905  36.0403
  76.9565  75.014   78.7695  81.4755  82.829   82.971   82.811   82.028   80.8605
  52.2925  50.803   53.5355  53.4195  53.814   53.733   53.5165  52.8595  52.2345
  96.2182  92.6785  96.9889  97.1126  97.8167  99.2155  98.5779  97.8167  97.1031
]

p2 = [
  35.6223 -Inf 35.6223  35.543   36.2205  36.8356  36.9533  36.5905  36.0403
  78.7695 -Inf  78.7695  81.4755  82.829   82.971   82.811   82.028   80.8605
  53.733 -Inf  53.5355  53.4195  53.814   53.733   53.5165  52.8595  52.2345
  97.8167 -Inf 96.9889  97.1126  97.8167  99.2155  98.5779  97.8167  97.1031
]

n_assets = size(p, 1)
horizon = 6
using OnlinePortfolioSelection
@testset "PPT.jl" begin
  @testset "with valid default arguments" begin
    model = ppt(p, 3, 100, horizon)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (n_assets, horizon)

    model = ppt(p2, 2, 100, horizon)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (n_assets, horizon)
  end

  @testset "with valid custom arguments" begin
    model = ppt(p, 3, 100, horizon, [0.1, 0.2, 0.3, 0.4])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (n_assets, horizon)
  end

  @testset "with invalid arguments" begin
    @test_throws ArgumentError ppt(p, 0, 100, horizon)
    @test_throws ArgumentError ppt(p, 3, 0, horizon)
    @test_throws ArgumentError ppt(p, 3, 100, horizon, [0.1, 0.2, 0.3, 0.5])
    @test_throws ArgumentError ppt(p, 3, 100, horizon, [0.5, 0.2, 0.3])
    @test_throws ArgumentError ppt(p, 3, 100, horizon+1)
  end
end
