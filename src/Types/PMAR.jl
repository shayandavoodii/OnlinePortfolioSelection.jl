abstract type PAMRModel end

"""
    PAMR() <: PAMRModel

Create a PAMR object. Also, see [`PAMR1`](@ref), and [`PAMR2`](@ref).

# Example
```julia
model = PAMR()
```
"""
struct PAMR<:PAMRModel end

"""
    PAMR1(C::AbstractFloat=1.) <: PAMRModel

Create a PAMR1 object. Also, see [`PAMR`](@ref), and [`PAMR2`](@ref).

# Keyword Arguments
- `C::AbstractFloat=1.`: Aggressiveness parameter.

# Example
```julia
model = PAMR1(C=0.02)
```
"""
@kwdef struct PAMR1{T<:AbstractFloat}<:PAMRModel
  C::T=1.
end

"""
    PAMR2(C::AbstractFloat=1.) <: PAMRModel

Create a PAMR2 object. Also, see [`PAMR`](@ref), and [`PAMR1`](@ref).

# Keyword Arguments
- `C::AbstractFloat=1.`: Aggressiveness parameter.

# Example
```julia
model = PAMR2(C=0.02)
```
"""
@kwdef struct PAMR2{T<:AbstractFloat}<:PAMRModel
  C::T=1.
end
