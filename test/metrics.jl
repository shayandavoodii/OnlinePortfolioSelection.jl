using HypothesisTests
using GLM

# Test data. Assumption: 3 assets and 40 periods.
adj_close = rand(3, 40) .* [4., 3., 2.] .+ [1., 5., 4.];
rel_pr = adj_close[:, 2:end] ./ adj_close[:, 1:end-1];
adj_close_market = rand(40);
rel_pr_market = adj_close_market[2:end] ./ adj_close_market[1:end-1];

@testset "opsmetrics" begin
  @testset "DRICORNK" begin
    res = dricornk(
      adj_close,
      adj_close_market,
      1,
      2,
      2,
      2
    )

    met = opsmetrics(
      res.b,
      rel_pr,
      rel_pr_market
    )

    @test isa(met, OPSMetrics)
    @test propertynames(met) == fieldnames(OPSMetrics)
  end

  @testset "CORN-K" begin
    res = cornk(
      adj_close,
      10,
      2,
      3,
      2
    )

    met = opsmetrics(
      res.b,
      rel_pr,
      rel_pr_market
    )

    @test isa(met, OPSMetrics)
    @test propertynames(met) == fieldnames(OPSMetrics)
  end

  @testset "CORN-U" begin
    res = cornu(
      adj_close,
      7,
      2,
      rho=0.8,
    )

    met = opsmetrics(
      res.b,
      rel_pr,
      rel_pr_market
    )

    @test isa(met, OPSMetrics)
    @test propertynames(met) == fieldnames(OPSMetrics)
  end
end

@testset "Individual metrics" begin
  @testset "sn" begin
    model = anticor(adj_close[:, end-29:end], 3)
    @test isa(sn(model.b, rel_pr), Vector{<:AbstractFloat})
  end

  @testset "ttest" begin
    apys = [
      [1, 2, 3, 4],
      [2, 7, 0, 1],
      [3, 0, 0, 5]
    ]
    @test ttest(apys) ≈ [
      0.0  1.0  0.702696943894
      0.0  0.0  0.843671720531
      0.0  0.0  0.0
    ]
    @test_throws ArgumentError ttest([[1,2,3]])
    @test_throws ArgumentError ttest([[1,2,3], [1,2]])
    @test_throws ArgumentError ttest([[1],[2]])

    SB, Sₜ = rand(10), rand(10)
    SF = 1.000156
    @test ttest(SB, Sₜ, SF) isa StatsModels.TableRegressionModel
    @test_throws ArgumentError ttest(rand(2), rand(3), SF)
  end
end
