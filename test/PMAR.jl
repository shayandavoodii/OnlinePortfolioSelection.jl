rel_pr = [
  0.900393  1.04269  0.997774  1.01906  1.01698
  0.963212  1.04651  1.00128   1.00725  1.0143
  0.974759  1.05006  1.03435   1.01661  1.00171
  0.970961  1.04714  1.00072   1.03245  1.01193
  0.971516  1.05379  0.997833  1.00738  0.998495
]

ϵ = 0.01

@testset "PMAR.jl" begin
  @testset "With default arguments" begin
    model = PMAR()
    result = pmar(rel_pr, ϵ, model)
    @test sum(result.b, dims=1) .|> isapprox(1.) |> all
    @test result.alg == "PMAR"
    @test size(result.b) == size(rel_pr)

    model = PMAR1()
    result = pmar(rel_pr, ϵ, model)
    @test sum(result.b, dims=1) .|> isapprox(1.) |> all
    @test result.alg == "PMAR1"
    @test size(result.b) == size(rel_pr)

    model = PMAR2()
    result = pmar(rel_pr, ϵ, model)
    @test sum(result.b, dims=1) .|> isapprox(1.) |> all
    @test result.alg == "PMAR2"
    @test size(result.b) == size(rel_pr)
  end

  @testset "With custom valid arguments" begin
    model = PMAR1(C=0.02)
    result = pmar(rel_pr, ϵ, model)
    @test sum(result.b, dims=1) .|> isapprox(1.) |> all
    @test result.alg == "PMAR1"
    @test size(result.b) == size(rel_pr)

    model = PMAR2(C=1.)
    result = pmar(rel_pr, ϵ, model)
    @test sum(result.b, dims=1) .|> isapprox(1.) |> all
    @test result.alg == "PMAR2"
  end

  @testset "With invalid arguments" begin
    model = PMAR1(C=-0.02)
    @test_throws ArgumentError pmar(rel_pr, ϵ, model)

    model = PMAR2(C=-1.)
    @test_throws ArgumentError pmar(rel_pr, ϵ, model)

    model = PMAR()
    @test_throws ArgumentError pmar(rel_pr, -0.01, model)
  end
end
