using Distributions

rel_pr = [
  0.900393  1.04269  0.997774  1.01906  1.01698
  0.963212  1.04651  1.00128   1.00725  1.0143
  0.974759  1.05006  1.03435   1.01661  1.00171
]

ϵ = 0.2
ϕ = 0.8

@testset "CWMR.jl" begin
  @testset "With default arguments" begin
    model = cwmr(rel_pr, ϵ, ϕ, CWMRD, Var)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Var"

    model = cwmr(rel_pr, ϵ, ϕ, CWMRD, Stdev)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Stdev"

    model = cwmr(rel_pr, ϵ, ϕ, CWMRS, Var)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Var-s"

    model = cwmr(rel_pr, ϵ, ϕ, CWMRS, Stdev)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Stdev-s"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRD, Var)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Var-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRD, Stdev)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Stdev-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRS, Var)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Var-s-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRS, Stdev)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Stdev-s-Mix"
  end

  @testset "With custom arguments" begin
    eg1 = eg(rel_pr).b
    eg2 = eg(rel_pr, eta=0.2).b

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRD, Var, adt_ptf=[eg1, eg2])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Var-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRD, Stdev, adt_ptf=[eg1, eg2])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Stdev-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRS, Var, adt_ptf=[eg1, eg2])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Var-s-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRS, Stdev, adt_ptf=[eg1, eg2])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Stdev-s-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRD, Var, adt_ptf=[eg1, eg2])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Var-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRD, Stdev, adt_ptf=[eg1, eg2])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Stdev-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRS, Var, adt_ptf=[eg1, eg2])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Var-s-Mix"

    model = cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRS, Stdev, adt_ptf=[eg1, eg2])
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == size(rel_pr)
    @test model.alg == "CWMR-Stdev-s-Mix"
  end

  @testset "With invalid arguments" begin
    eg1 = eg(rel_pr).b
    eg2 = eg(rel_pr, eta = 0.2).b
    @test_throws ArgumentError cwmr(rel_pr, [-0.2, 0.4], [0.1, 0.8], CWMRD, Var, adt_ptf=[eg1, eg2])
    @test_throws ArgumentError cwmr(rel_pr, [0.2, -0.4], [0.1, 0.8], CWMRD, Var, adt_ptf=[eg1, eg2])
    @test_throws ArgumentError cwmr(rel_pr, [0.2, 0.4], [-0.1, 0.8], CWMRD, Var, adt_ptf=[eg1, eg2])
    @test_throws ArgumentError cwmr(rel_pr, [0.2, 0.4], [0.1, -0.8], CWMRD, Var, adt_ptf=[eg1, eg2])
    @test_throws ArgumentError cwmr(rel_pr, [0.2, 0.4], [0.1], CWMRD, Var, adt_ptf=[eg1, eg2])
    t = [0.2 0.4 0.1 0.8 0.2; 0.4 0.1 0.8 0.2 0.4; 0.1 0.8 0.2 0.4 0.1]
    @test_throws ArgumentError cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRD, Var, adt_ptf=[t])
    t = [0.2 0.4 0.1 0.8 0.2; 0.4 0.1 0.8 0.1 0.4; 0.4 0.5 0.1 0.1 0.4]
    @test_throws ArgumentError cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRD, Var, adt_ptf=[t])
    t1 = [0.2 0.4 0.1 0.8 0.2; 0.4 0.1 0.8 0.1 0.4]
    @test_throws ArgumentError cwmr(rel_pr, [0.2, 0.4], [0.1, 0.8], CWMRD, Var, adt_ptf=[t1])
    @test_throws ArgumentError cwmr(rel_pr, -0.2, 0.1, CWMRD, Var)
    @test_throws ArgumentError cwmr(rel_pr, 0.2, -0.1, CWMRD, Var)
  end
  @testset "Functions" begin
    @test OnlinePortfolioSelection.Δfunc(2.0, 4.0, 2.0) == 0.0
    @test OnlinePortfolioSelection.Δfunc(1.0, 5.0, 1.0) == 0.0
    @test OnlinePortfolioSelection.Δfunc(4.0, 2.0, 1.0) == 0.0
  end
end
