adj_close = [
1. 2.
4. 9.
7. 8.
10. 11.
13. 7.
8. 17.
19. 20.
22. 23.
25. 8.
2. 12.
5. 12.
5. 0.
0. 2.
1. 1.
];

adj_close = permutedims(adj_close)

b_res = [
  0.5  0.5  0.5  0.5  0.5  0.5  1.0  1.0  1.0  0.0  0.0  0.0  0.0  1.0
  0.5  0.5  0.5  0.5  0.5  0.5  0.0  0.0  0.0  1.0  1.0  1.0  1.0  0.0
]

@testset "Anticor" begin
  @testset "All good" begin
    m_anticor = anticor(adj_close, 3)

    @test sum(m_anticor.b, dims=1) .|> isapprox(1., atol=1e-8) |> all

    @test size(m_anticor.b) == size(adj_close)

    @test m_anticor.b == b_res
  end

  @testset "Errors" begin
    @test_throws ArgumentError anticor(adj_close, 0)
    @test_throws ArgumentError anticor(adj_close, 8)
  end

  @testset "related utilities of Anticor" begin
    test = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    @test OnlinePortfolioSelection.shift(test, 2) == [1, 2, 3, 4, 5, 6, 7, 8]
    test2 = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
    @test OnlinePortfolioSelection.shift(*, 2, test, test2) == [10, 18, 24, 28, 30, 30, 28, 24]
  end
end
