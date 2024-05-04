abstract type TCOVariant end

struct TCO1{T<:AbstractVector}<:TCOVariant
  f::T
end

struct TCO2{T<:AbstractVector}<:TCOVariant
  f::T
end
