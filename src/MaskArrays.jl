module MaskArrays

using ConcreteStructs


EqualTo = Base.Fix2{typeof(isequal)}
@concrete struct MaskArray{T,N} <: AbstractArray{T,N}
    base
    lookup
    imputed
end

export imputed

imputed(ma::MaskArray) = ma.imputed

Base.length(x::MaskArray) = Base.length(x.base)
Base.size(x::MaskArray) = Base.size(x.base)

# TODO: Make this more efficient (currently doing the lookup twice)
function Base.getindex(x::MaskArray, ind)
    haskey(x.lookup, ind) && return x.imputed[x.lookup[ind]]

    return x.base[ind]
end

# Get the type constructor, without type parameters
constructor(x) = typeof(x).name.wrapper

export maskarray

function maskarray(x::AbstractArray{Union{T,Missing},N}) where {T,N}
    # Get the locations of missing Aalues
    missinginds = findall(ismissing, x)
    nummissing = length(missinginds)

    A = constructor(x)

    # Build base array, fill with known data
    base = A{T}(undef, length(x))
    for j in eachindex(base)
        j ∈ missinginds && continue
        base[j] = x[j]
    end

    imp = Vector{T}(undef, nummissing)
    lookup = Dict(zip(missinginds, 1:nummissing))

    return MaskArray{T,N}(base, lookup, imp)
end

function replace_storage(ma::MaskArray, v::AbstractVector)
    @assert eltype(v) == eltype(ma.base)
    @assert length(v) == length(ma.imputed)
    ma.imputed
end


end
