module MaskArrays

using ConcreteStructs


EqualTo = Base.Fix2{typeof(isequal)}
@concrete struct MaskArray{T,N} <: AbstractArray{T,N}
    base
    indices
    missingview
    buffer
end

Base.length(x::MaskArray) = Base.length(x.base)
Base.size(x::MaskArray) = Base.size(x.base)

Base.getindex(ma::MaskArray, inds...) = getindex(ma.base, inds...)

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

    indices = Dict(zip(missinginds, 1:nummissing))
    vu = view(base, missinginds)

    return MaskArray{T,N}(base, indices, vu, vu)
end

export replace_storage

function replace_buffer(ma::MaskArray{T,N}, x::AbstractVector) where {T,N}
    @assert eltype(v) == eltype(ma.base)
    @assert length(v) == length(ma.imputed)
    MaskArray{T,N}(ma.base, ma.indices, ma.missingview, x)
end

export sync!

function sync!(ma::MaskArray)
    ma.view .= ma.buffer
end


end
