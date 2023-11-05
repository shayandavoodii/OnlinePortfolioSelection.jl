abstract type PMARModel end

"""
    PMAR() <: PMARModel

Create a PMAR object. Also, see [`PMAR1`](@ref), and [`PMAR2`](@ref).

# Example
```julia
model = PMAR()
```
"""
struct PMAR<:PMARModel end

"""
    PMAR1(C::AbstractFloat=1.) <: PMARModel

Create a PMAR1 object. Also, see [`PMAR`](@ref), and [`PMAR2`](@ref).

# Keyword Arguments
- `C::AbstractFloat=1.`: Aggressiveness parameter.

# Example
```julia
model = PMAR1(C=0.02)
```
"""
@kwdef struct PMAR1{T<:AbstractFloat}<:PMARModel
  C::T=1.
end

"""
    PMAR2(C::AbstractFloat=1.) <: PMARModel

Create a PMAR2 object. Also, see [`PMAR`](@ref), and [`PMAR1`](@ref).

# Keyword Arguments
- `C::AbstractFloat=1.`: Aggressiveness parameter.

# Example
```julia
model = PMAR2(C=0.02)
```
"""
@kwdef struct PMAR2{T<:AbstractFloat}<:PMARModel
  C::T=1.
end
