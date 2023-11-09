abstract type CWMRVariant end
abstract type PtfDisVariant end

struct CWMRD<:CWMRVariant end
struct CWMRS<:CWMRVariant end

struct Var<:PtfDisVariant end
struct Stdev<:PtfDisVariant end
