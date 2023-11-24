abstract type EGMFramework end

"""
    EGE{T<:AbstractFloat}<:EGMFramework

EGE variant of the EGM algorithm.

# Fields
- `gamma1::T`: momentum parameter

# Example
```julia
julia> model = EGE(0.99)
EGE{Float64}(0.99)
```
"""
struct EGE{T<:AbstractFloat}<:EGMFramework
  gamma1::T
end

"""
    EGR{T<:AbstractFloat}<:EGMFramework

EGR variant of the EGM algorithm.

# Fields
- `gamma2::T`: momentum parameter

# Example
```julia
julia> model = EGR(0.)
EGR{Float64}(0.0)
```
"""
struct EGR{T<:AbstractFloat}<:EGMFramework
  gamma2::T
end

"""
    EGA{T<:AbstractFloat}<:EGMFramework

EGA variant of the EGM algorithm.

# Fields
- `gamma1::T`: momentum parameter
- `gamma2::T`: momentum parameter

# Example
```julia
julia> model = EGA(0.99, 0.)
EGA{Float64}(0.99, 0.0)
```
"""
struct EGA{T<:AbstractFloat}<:EGMFramework
  gamma1::T
  gamma2::T
end
