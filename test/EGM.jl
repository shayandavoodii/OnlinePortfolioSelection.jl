rel_pr = [
  0.900393  1.04269  0.997774  1.01906  1.01698   1.0032    0.990182
  0.963212  1.04651  1.00128   1.00725  1.0143    0.993574  0.992278
  0.971516  1.05379  0.997833  1.00738  0.998495  0.995971  0.987723
]

ege = EGE(0.99)
egr = EGR(0.)
ega = EGA(0.99, 0.)

@testset "EGM.jl" begin
  @testset "With valid arguments" begin
    model = egm(rel_pr, ege)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.n_assets == size(rel_pr, 1)

    model = egm(rel_pr, egr)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)

    model = egm(rel_pr, ega)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
  end

  @testset "With custom arguments" begin
    model = egm(rel_pr, ege, 0.1)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.n_assets == size(rel_pr, 1)

    model = egm(rel_pr, egr, 0.1)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)

    model = egm(rel_pr, ega, 0.1)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
  end

  @testset "With invalid arguments" begin
    @test_throws ArgumentError egm(rel_pr, ege, 0.)
  end
end
