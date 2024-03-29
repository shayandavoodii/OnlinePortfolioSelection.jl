rel_pr = [
  1.01387  1.00094  1.02046  0.995164  1.02029  1.00778
  1.01159  1.00189  1.01241  0.989079  1.0073   1.00154
  1.01925  1.0095   1.03275  0.996709  1.00879  0.999479
]

n_assets = size(rel_pr, 1)

@testset "MAEG.jl" begin
  @testset "With valid arguments" begin
    model = maeg(rel_pr, 2, [0.01, 0.02, 0.1])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test (model.b[:, 1] .== 1/n_assets) |> all
    @test size(model.b) == size(rel_pr)
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError maeg(rel_pr, 1, [0.01, 0.02, 0.1])
    @test_throws ArgumentError maeg(rel_pr, 1, [0., 0.02, 0.1])
    @test_throws ArgumentError maeg(rel_pr, 1, [0.01, 0.02, 1])
    @test_throws ArgumentError maeg(rel_pr, 1, [0.01])
  end
end
