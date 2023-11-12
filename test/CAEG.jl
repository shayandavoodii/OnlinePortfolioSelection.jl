rel_pr = [
  1.01387  1.00094  1.02046  0.995164  1.02029  1.00778
  1.01159  1.00189  1.01241  0.989079  1.0073   1.00154
  1.01925  1.0095   1.03275  0.996709  1.00879  0.999479
]

n_assets = size(rel_pr, 1)
ηs1 = [0.02, 0.05]
ηs2 = [0.05]

@testset "CAEG.jl" begin
  @testset "With valid arguments" begin
    model = caeg(rel_pr, ηs1)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.b[:, 1] == ones(n_assets)/n_assets
    @test size(model.b) == size(rel_pr)
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError caeg(rel_pr, [0.02, 0.05, -0.01])
    @test_throws ArgumentError caeg(rel_pr, [0.02, 0.05, 0.])
    @test_throws ArgumentError caeg(rel_pr, ηs2)
  end
end
