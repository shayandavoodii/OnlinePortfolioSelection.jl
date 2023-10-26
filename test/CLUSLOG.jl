adj_close = [
  1.5464 1.5852 1.6532 1.7245 1.5251 1.4185 1.2156 1.3231 1.3585 1.4563 1.4456
  1.2411 1.2854 1.3456 1.4123 1.5212 1.5015 1.4913 1.5212 1.5015 1.4913 1.5015
  1.3212 1.3315 1.3213 1.3153 1.3031 1.2913 1.2950 1.2953 1.3315 1.3213 1.3315
]

rel_pr = adj_close[:, 2:end]./adj_close[:, 1:end-1]
nassets = size(rel_pr, 1)
horizon = 3
TW = 3
nclusters_ = 3
nclustering = 10
lb, ub = 0., 1.

@testset "CLUSLOG.jl" begin
  @testset "With valid args" begin
    model = cluslog(rel_pr, horizon, TW, KmeansModel, nclusters_, nclustering, (lb, ub))
    @test model.alg == "KMNLOG"
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (nassets, horizon)

    model = cluslog(rel_pr, horizon, TW, KmedoidsModel, nclusters_, nclustering, (lb, ub))
    @test model.alg == "KMDLOG"
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test size(model.b) == (nassets, horizon)
  end

  @testset "With invalid args" begin
    @test_throws DomainError cluslog(rel_pr, horizon, TW, KmeansModel, 1, nclustering, (lb, ub)) # nclusters≥2
    @test_throws DomainError cluslog(rel_pr, horizon, TW, KmeansModel, nclusters_, 0, (lb, ub)) # nclustering≥1
    @test_throws DomainError cluslog(rel_pr, horizon, 1, KmeansModel, nclusters_, nclustering, (lb, ub)) # TW≥2
    @test_throws DomainError cluslog(rel_pr, horizon, TW, KmeansModel, nclusters_, nclustering, (ub, lb)) # ub > lb
    @test_throws DomainError cluslog(rel_pr, 0, TW, KmeansModel, nclusters_, nclustering, (lb, ub)) # horizon>0
    @test_throws MethodError cluslog(rel_pr, horizon, TW, KmeansModel, nclusters_, nclustering, (lb, ub, 1.)) # length(boundries)==2
    @test_throws DomainError cluslog(rel_pr, horizon, TW, KmeansModel, 8, nclustering, (lb, ub)) # nclusters ≤ nperiods-horizon
    @test_throws DomainError cluslog(rel_pr, horizon, 8, KmeansModel, nclusters_, nclustering, (lb, ub)) # TW < nperiods-horizon+1
    @test_throws DomainError cluslog(rel_pr, horizon, TW, KmeansModel, nclusters_, nclustering, (0.34, ub)) # boundries[1] < 1/nassets
    @test_throws DomainError cluslog(rel_pr, horizon, TW, KmeansModel, nclusters_, nclustering, (-0.1, ub)) # lb>0
    @test_throws DomainError cluslog(rel_pr, horizon, TW, KmeansModel, nclusters_, nclustering, (lb, -0.1)) # 0<ub≤1
    @test_throws DomainError cluslog(rel_pr, horizon, TW, KmeansModel, nclusters_, nclustering, (lb, 1.1)) # 0<ub≤1
  end
end
