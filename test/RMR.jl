prices = [
  68.3685   68.033    69.7105   69.667    70.216    70.9915   71.4865   71.9615   71.544    71.96     72.585    74.0195   74.22     74.2975   74.3325   73.3355   71.695    72.628    72.9315   72.792
  73.1526   72.4415   73.0187   72.6753   73.8444   75.4129   75.5834   77.1981   76.1557   75.8293   76.7792   77.6292   77.1031   77.3784   77.751    77.527    75.2473   77.3759   78.9956   78.8811
 154.78    152.852   153.247   151.85    154.269   156.196   155.473   157.343   156.235   157.246   160.128   161.024   160.446   159.675   160.658   159.039   156.379   159.444   161.93    166.497
  94.9005   93.7485   95.144    95.343    94.5985   95.0525   94.158    94.565    93.472    93.101    93.897    93.236    94.6      94.373    94.229    93.082    91.417    92.6625   92.9      93.534
]

n_assets, n_samples = size(prices)
horizon = 5
w = 5
ϵ = 5
m = 7
τ = 1e6

@testset "RMR.jl" begin
  @testset "with valid arguments" begin
    model = rmr(prices, horizon, w, ϵ, m, τ)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == n_assets
    @test (model.b[:, 1] .== 1/n_assets) |> all
    @test size(model.b) == (n_assets, horizon)

    model = rmr(prices, horizon, w, ϵ, m, 0.025)
    @test sum(model.b, dims=1) .|> isapprox(1.) |> all
    @test model.n_assets == n_assets
    @test (model.b[:, 1] .== 1/n_assets) |> all
    @test size(model.b) == (n_assets, horizon)
  end

  @testset "with invalid arguments" begin
    @test_throws ArgumentError rmr(prices, 0, w, ϵ, m, τ)
    @test_throws ArgumentError rmr(prices, horizon, 0, ϵ, m, τ)
    @test_throws ArgumentError rmr(prices, horizon, w, 0, m, τ)
    @test_throws ArgumentError rmr(prices, horizon, w, ϵ, 0, τ)
    @test_throws ArgumentError rmr(prices, horizon, w, ϵ, m, 0)
    @test_throws ArgumentError rmr(prices[:, 1:horizon+w-1-1], horizon, w, ϵ, m, τ)
  end
end
