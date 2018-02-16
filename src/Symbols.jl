doc"Arbitrary coded symbol."
abstract type CodeSymbol end

doc"True if cs neighbours the intermediate symbol with index i."
function has_neighbour(cs::CodeSymbol, i::Int) :: Bool
    return i in neighbours(cs)
end

doc"Intermediate code symbol."
struct ISymbol <: CodeSymbol
    value::Int
    neighbours::Set{Int}
    function ISymbol(value::Int, neighbours::Set{Int})
        new(value, neighbours)
    end
    function ISymbol(value::Int)
        new(value, Set{Int}())
    end
end

doc"Outer code symbol."
struct R10Symbol <: CodeSymbol
    esi::Int # encoded symbol id
    value::Int # value of the symbol
    primary_neighbour::Int
    active_neighbours::Array{Int,1}
    inactive_neighbours::Array{Int,1}
    function R10Symbol(esi::Int, value::Int,
                       primary_neighbour::Int,
                       active_neighbours::Array{Int,1},
                       inactive_neighbours::Array{Int,1},
                       sort=true)
        if sort
            return new(
                esi,
                value,
                primary_neighbour,
                sort!(copy(active_neighbours)),
                sort!(copy(inactive_neighbours)),
            )
        else
            return new(
                esi,
                value,
                primary_neighbour,
                active_neighbours,
                inactive_neighbours,
            )
        end
    end
    function R10Symbol(esi::Int, value::Int, neighbours::Array{Int,1})
        R10Symbol(esi, value, -1, neighbours, Array{Int,1}())
    end
end

doc"Sparse binary vector."
struct RBitVector <: CodeSymbol
    value::Int
    active::Vector{Int}
    inactive::Vector{Int}
    function RBitVector(value::Int, active::Vector{Int}, inactive::Vector{Int}, sort=true)
        if sort
            return new(value, sort!(copy(active)), sort!(copy(inactive)))
        else
            return new(value, active, inactive)
        end
    end
end

@inline function degree(r::RBitVector)
    return active_degree(r) + inactive_degree(r)
end

@inline function active_degree(r::RBitVector)
    return length(r.active)
end

@inline function inactive_degree(r::RBitVector)
    return length(r.inactive)
end

@inline function active_neighbours(r::RBitVector)
    return r.active
end

@inline function inactive_neighbours(r::RBitVector)
    return r.inactive
end

@inline function neighbours(r::RBitVector)
    return append!(copy(r.active), r.inactive)
end

doc"XOR of 2 sorted lists."
function listxor{T}(l1::Vector{T}, l2::Vector{T}) :: Vector{T}
    i = 1
    j = 1
    il, jl = length(l1), length(l2)
    l = similar(l1, 0)
    @inbounds begin
        while i <= il && j <= jl
            u, v = l1[i], l2[j]
            if u < v
                push!(l, u) # TODO: slow
                i += 1
            elseif u > v
                push!(l, v)
                j += 1
            else
                i += 1
                j += 1
            end
        end
        while i <= il
            u = l1[i]
            push!(l, u) # TODO: slow
            i += 1
        end
        while j <= jl
            v = l2[j]
            push!(l, v)
            j += 1
        end
    end
    return l
end

function Base.xor(a::RBitVector, b::RBitVector) :: RBitVector
    active = listxor(a.active, b.active)
    inactive = listxor(a.inactive, b.inactive)
    value = xor(a.value, b.value)
    return RBitVector(value, active, inactive, false)
end

doc"Outer code symbol with only binary coefficients."
struct BlockBitRow <: CodeSymbol
    value::Int
    active::SparseBitVector
    inactive::SparseBitVector
end
function BlockBitRow(l::Int, value::Int, active::Vector{Int}, inactive::Vector{Int})
    ba = SparseBitVector(l)
    for i in active
        ba[i] = true
    end
    bi = SparseBitVector(l)
    for i in inactive
        bi[i] = true
    end
    return BlockBitRow(value, ba, bi)
end

@inline function degree(r::BlockBitRow)
    return active_degree(r) + inactive_degree(r)
end

@inline function active_degree(r::BlockBitRow)
    return sum(r.active)
end

@inline function inactive_degree(r::BlockBitRow)
    return sum(r.inactive)
end

@inline function active_neighbours(r::BlockBitRow)
    return findall(r.active)
end

@inline function inactive_neighbours(r::BlockBitRow)
    return findall(r.inactive)
end

@inline function neighbours(r::BlockBitRow)
    return append!(findall(r.active), findall(r.inactive))
end

# function subtract!(d::Decoder{BlockBitRow}, i::Int, j::Int)
#     cs1 = d.csymbols[i]
#     cs2 = d.csymbols[j]
#     active = xor!(cs2.active, cs1.active) # TODO: linking
#     active = xor!(cs2.inactive, cs1.inactive) # TODO: linking
#     value = xor(cs2.value, cs1.value)
#     push!(d.metrics, "num_xor", degree(cs1)+1)
#     cs = BitRow(value, active, inactive)
# end

doc"Number of neighbouring outer coded symbols."
function degree(is::ISymbol)
    return length(is.neighbours)
end

doc"Number of neighbouring intermediate symbols."
function degree(cs::R10Symbol)
    return length(cs.active_neighbours) + length(cs.inactive_neighbours)
end

doc"Neighbouring outer code symbols."
function neighbours(is::ISymbol)
    return collect(is.neighbours)
end

doc"Neighbouring intermediate symbols."
function neighbours(cs::R10Symbol)
    return append!(append!([], cs.active_neighbours), cs.inactive_neighbours)
end

doc"Number of non-zero entries in V."
function active_degree(cs::R10Symbol)
    return length(cs.active_neighbours)
end

doc"Number of non-zero entries in U."
function inactive_degree(cs::R10Symbol)
    return length(cs.inactive_neighbours)
end

doc"Neighbours that are not decoded or inactivated."
function active_neighbours(cs::R10Symbol) # TODO: slow
    return cs.active_neighbours
end
