abstract type PMARModel end

struct PMAR<:PMARModel end

"""
    PMAR1(C::AbstractFloat=1.) <: PMARModel

Create a PMAR1 object.

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

Create a PMAR2 object.

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
