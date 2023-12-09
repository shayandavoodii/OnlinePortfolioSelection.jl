rel_pr = [
  0.990278  1.00797  0.995297  1.01609  1.02124  1.00226
  0.987548  1.00259  0.990882  1.01593  1.01249  0.995373
  0.995093  1.02466  0.999376  1.00788  1.01104  1.00697
]

β = 1
𝛿 = 1/8
η = 0.
n_assets = size(rel_pr, 1)

@testset "ONS.jl" begin
  @testset "With default arguments" begin
    model = ons(rel_pr)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == n_assets
    @test (model.b[:, 1] .== 1/n_assets) |> all
  end

  @testset "With custom arguments" begin
    model = ons(rel_pr, β, 𝛿, η)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == n_assets
    @test (model.b[:, 1] .== 1/n_assets) |> all
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError ons(rel_pr, 0, 𝛿, η)
    @test_throws ArgumentError ons(rel_pr, β, 0., η)
    @test_throws ArgumentError ons(rel_pr, β, 𝛿, -1.)
  end
end
