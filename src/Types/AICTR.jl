abstract type TrendRep end

struct SMA<:TrendRep end

struct EMA{T<:AbstractFloat}<:TrendRep
  v::T
end

struct PP<:TrendRep end
