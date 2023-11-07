abstract type ClusLogVariant end

"""
    KMNLOG(alg::String="KMNLOG")<:ClusLogVariant

`KMNLOG` is a concrete type used to represent the KMNLOG Model. Also, see [`KMDLOG`](@ref).
"""
struct KMNLOG<:ClusLogVariant end

"""
    KMDLOG(alg::String="KMDLOG")<:ClusLogVariant

`KMDLOG` is a concrete type used to represent the KMDLOG Model. Also, see [`KMNLOG`](@ref).
"""
struct KMDLOG<:ClusLogVariant end
