module MaskArrays

using ConcreteStructs


EqualTo = Base.Fix2{typeof(isequal)}
@concrete terse struct MaskArray{T,N} <: AbstractArray{T,N}
    base
    indices
    imputed
    buffer
end

export imputed
imputed(ma::MaskArray) = ma.imputed

export buffer
buffer(ma::MaskArray) = ma.buffer

Base.length(x::MaskArray) = Base.length(x.base)
Base.size(x::MaskArray) = Base.size(x.base)

Base.getindex(ma::MaskArray, inds...) = getindex(ma.base, inds...)

export maskarray

function maskarray(x::AbstractArray{Union{T,Missing},N}) where {T,N}
    inds = CartesianIndices(x)

    # Get the locations of missing values
    missinginds = inds[findall(ismissing, x)]
    nummissing = length(missinginds)

    # # Build base array, fill with known data
    base = similar(x, T)
    for j in inds
        j ∈ missinginds && continue
        base[j] = x[j]
    end


    indices = Dict(zip(missinginds, 1:nummissing))
    vu = view(base, missinginds)

    return MaskArray{T,N}(base, indices, vu, vu)
end

export replace_buffer

function replace_buffer(ma::MaskArray{T,N}, x::AbstractVector) where {T,N}
    @assert eltype(x) == eltype(ma.base)
    @assert length(x) == length(ma.imputed)
    MaskArray{T,N}(ma.base, ma.indices, ma.imputed, x)
end

export sync!

function sync!(ma::MaskArray)
    ma.imputed .= ma.buffer
    return ma
end


end
