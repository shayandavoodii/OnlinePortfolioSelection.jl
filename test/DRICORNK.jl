# Test data for DRICORN.jl. Assumption: 3 assets and 30 periods.
adj_close = rand(3, 30) .* [4., 3., 2.] .+ [1., 5., 4.];
adj_close_market = rand(30);

@testset "DRICORNK" begin
  @testset "Arument Errors" begin
    @testset "invalid p" begin
      @test_throws ArgumentError DRICORNK(
        adj_close,
        adj_close_market,
        3,
        2,
        4,
        1
      )
    end

    @testset "invalid horizon" begin
      @test_throws ArgumentError DRICORNK(
        adj_close,
        adj_close_market,
        31,
        3,
        3,
        2
      )
    end

    @testset "invalid k" begin
      @test_throws ArgumentError DRICORNK(
        adj_close,
        adj_close_market,
        3,
        15,
        3,
        2
      )
    end
  end

  @testset "All good" begin
    res = DRICORNK(
      adj_close,
      adj_close_market,
      2,
      2,
      2,
      2
    )

    @test sum(res.b, dims=1) .|> isapprox(1.) |> all
  end
end
