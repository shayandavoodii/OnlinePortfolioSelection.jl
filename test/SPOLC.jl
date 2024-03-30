rel_pr = [
  0.900393  1.04269  0.997774  1.01906  1.01698   1.0032    0.990182  0.984963  1.02047  1.01222  1.00594  1.00616  0.977554  1.00404  0.992074
  0.974759  1.05006  1.03435   1.01661  1.00171   0.998072  0.990545  0.985767  1.03546  1.00551  1.00561  1.00176  0.962251  1.00481  1.00909
  0.971516  1.05379  0.997833  1.00738  0.998495  0.995971  0.987723  0.988176  1.03107  1.00355  1.00826  1.00767  0.974742  1.00472  0.998447
  0.963212  1.04651  1.00128   1.00725  1.0143    0.993575  0.992278  0.992704  1.02901  1.00352  1.00702  1.01498  0.981153  1.00975  0.995221
]

𝛾 = 0.025
w = 5

@testset "SPOLC.jl" begin
  @testset "With valid arguments" begin
    model = spolc(rel_pr, 𝛾, w)
    @test size(model.b) == size(rel_pr)
    @test (model.b[:, 1] .== 1/size(rel_pr, 1)) |> all
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError spolc(rel_pr, 0., w)
    @test_throws ArgumentError spolc(rel_pr, 𝛾, 1)
  end

  @testset "Individual funcs" begin
    @test OnlinePortfolioSelection.simplexproj([1e6, 2e6, 3e6], 3)≈[ 0.8999999999999999, 1.0, 1.0999999999999999]
  end
end
