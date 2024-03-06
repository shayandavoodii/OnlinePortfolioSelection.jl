# Test data for DRICORN.jl. Assumption: 3 assets and 30 periods.
rel_pr = rand(3, 30) .* [4., 3., 2.] .+ [1., 5., 4.];
relpr_market = rand(30);

@testset "DRICORNK" begin
  @testset "Arument Errors" begin
    @testset "invalid p" begin
      @test_throws ArgumentError dricornk(
        rel_pr,
        relpr_market,
        3,
        2,
        4,
        1
      )
    end

    @testset "invalid number of data points" begin
      @test_throws ArgumentError dricornk(
        rel_pr,
        relpr_market,
        6,
        3,
        3,
        2
      )
    end

    @testset "unmatched number of data points" begin
      @test_throws ArgumentError dricornk(
        rel_pr,
        rand(29),
        5,
        3,
        3,
        2
      )
    end
    @testset "invalid k" begin
      @test_throws ArgumentError dricornk(
        rel_pr,
        relpr_market,
        3,
        15,
        3,
        2
      )
    end
  end

  @testset "All good" begin
    res = dricornk(
      rel_pr,
      relpr_market,
      5,
      2,
      2,
      2
    )

    @test res.alg == "DRICORN-K"

    @test sum(res.b, dims=1) .|> isapprox(1.) |> all
  end
end
