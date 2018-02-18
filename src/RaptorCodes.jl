module RaptorCodes

doc"parameter container"
abstract type Parameters end

doc"arbitrary coded symbol"
abstract type CodeSymbol end

doc"matrix row"
abstract type Row end

include("Numinv.jl")
include("Soliton.jl")
include("SparseBitVector.jl")
include("Symbols.jl")
include("Gray.jl")
include("R10Tables.jl")
include("R10.jl")
include("Matrix.jl")
include("R10Encode.jl")
include("LT.jl")
include("Decode.jl")

end # module
