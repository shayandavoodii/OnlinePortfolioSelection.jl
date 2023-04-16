# Test data for CORN.jl. Assumption: 3 assets and 30 periods.
adj_close = rand(3, 30) .* [4., 3., 2.] .+ [1., 5., 4.];

@testset "CORN" begin

  @testset "CORN-U" begin

    @testset "invalid ρ" begin
      @test_throws ArgumentError CORNU(
        adj_close,
        3,
        3,
        1.
      )

      @test_throws ArgumentError CORNU(
        adj_close,
        3,
        3,
        -0.5
      )
    end

    @testset "valid ρ" begin
      res = CORNU(
        adj_close,
        3,
        3,
        0.5
      );

      @test all(isapprox.(1., sum(res.b, dims=1)))
    end

    @testset "invalid horizon" begin
      @test_throws ArgumentError CORNU(
        adj_close,
        30,
        3,
        0.1
      )
    end
  end

  @testset "CORN-K" begin
    @testset "invalid p" begin
      @test_throws ArgumentError CORNK(
        adj_close,
        3,
        3,
        4,
        1
      )
    end

    @testset "valid p" begin
      res = CORNK(
        adj_close,
        2,
        3,
        4,
        2
      );

      @test all(isapprox.(1., sum(res.b, dims=1)))
    end

    @testset "invalid horizon" begin
      @test_throws ArgumentError CORNK(
        adj_close,
        30,
        3,
        3,
        2
      )
    end
  end
end
