prices = [
  68.3685   68.033    69.7105   69.667    70.216    70.9915   71.4865   71.9615   71.544    71.96     72.585    74.0195   74.22     74.2975   74.3325   73.3355   71.695    72.628    72.9315   72.792
  73.1526   72.4415   73.0187   72.6753   73.8444   75.4129   75.5834   77.1981   76.1557   75.8293   76.7792   77.6292   77.1031   77.3784   77.751    77.527    75.2473   77.3759   78.9956   78.8811
 154.78    152.852   153.247   151.85    154.269   156.196   155.473   157.343   156.235   157.246   160.128   161.024   160.446   159.675   160.658   159.039   156.379   159.444   161.93    166.497
  94.9005   93.7485   95.144    95.343    94.5985   95.0525   94.158    94.565    93.472    93.101    93.897    93.236    94.6      94.373    94.229    93.082    91.417    92.6625   92.9      93.534
]

n_samples = size(prices, 2)
n_assets = size(prices, 1)
h = 5
w = 5

@testset "SSPO.jl" begin
  @testset "With default arguments" begin
    model = sspo(prices, h, w)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == n_assets
    @test (model.b[:, 1] .== 1/n_assets) |> all
    @test size(model.b) == (n_assets, h)
  end

  @testset "With custom arguments" begin
    model = sspo(prices, h, w, nothing, 0.01, 0.1, 0.1, 1000, 1e-3, 1e3)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == n_assets
    @test (model.b[:, 1] .== 1/n_assets) |> all
    @test size(model.b) == (n_assets, h)

    b̂ₜ = [0.25, 0.25, 0.25, 0.25]
    model = sspo(prices, h, w, b̂ₜ)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == n_assets
    @test (model.b[:, 1] .== 1/n_assets) |> all
    @test size(model.b) == (n_assets, h)
  end

  @testset "Error handling" begin
    @test_throws ArgumentError sspo(prices, 0, w)
    @test_throws ArgumentError sspo(prices, h, 0)
    @test_throws ArgumentError sspo(prices, h, w, [0.25, 0.25, 0.25])
    @test_throws ArgumentError sspo(prices, h, w, [0.25, 0.25, 0.25, -0.25])
    @test_throws ArgumentError sspo(prices, h, w, [0.5, 0.5, 0.25, -0.25])
    @test_throws ArgumentError sspo(prices, h, w, [0.25, 0.25, 0.25, 0.25, 0.25], 0.)
    @test_throws ArgumentError sspo(prices, h, w, [0.25, 0.25, 0.25, 0.25, 0.25], 0.005, 0.)
    @test_throws ArgumentError sspo(prices, h, w, [0.25, 0.25, 0.25, 0.25, 0.25], 0.005, 0.01, 0.)
    @test_throws ArgumentError sspo(prices, h, w, [0.25, 0.25, 0.25, 0.25, 0.25], 0.005, 0.01, 0.5, 0)
    @test_throws ArgumentError sspo(prices, h, w, [0.25, 0.25, 0.25, 0.25, 0.25], 0.005, 0.01, 0.5, 500, 0.)
    @test_throws ArgumentError sspo(prices, h, w, [0.25, 0.25, 0.25, 0.25, 0.25], 0.005, 0.01, 0.5, 500, 1e-4, 0)
    @test_throws ArgumentError sspo(prices[:, 1:h+w-1-1], h, w)
  end
end
