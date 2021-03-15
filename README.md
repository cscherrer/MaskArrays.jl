# MaskArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cscherrer.github.io/MaskArrays.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cscherrer.github.io/MaskArrays.jl/dev)
[![Build Status](https://github.com/cscherrer/MaskArrays.jl/workflows/CI/badge.svg)](https://github.com/cscherrer/MaskArrays.jl/actions)
[![Coverage](https://codecov.io/gh/cscherrer/MaskArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cscherrer/MaskArrays.jl)

When working with missing values in an array, there are a few challenges:
1. `::Missing` values have some overhead, and prevent BLAS operations
2. For imputations, we need to track which values were imputed
3. For many inference algorithms, it's convenient to have the imputed values together in a dense array

`MaskArrays` addresses these issues. For example, say you're given an array like

```julia
julia> x
7-element Vector{Union{Missing, Float64}}:
 -0.742
   missing
 -0.301
 -0.954
   missing
   missing
 -0.436
```

Then we can convert this easily:
```julia
julia> ma = maskarray(x)
7-element MaskArray{Float64,1}:
 -0.742
  6.9439480399727e-310
 -0.301
 -0.954
  0.0
  0.0
 -0.436
```

The imputed values are represented as a `view` into the data:
```julia
julia> imputed(ma)
3-element view(::Vector{Float64}, [2, 5, 6]) with eltype Float64:
 6.9439480399727e-310
 0.0
 0.0
```

For example, we can easily do

```julia
julia> imputed(ma) .= 1:3
3-element view(::Vector{Float64}, [2, 5, 6]) with eltype Float64:
 1.0
 2.0
 3.0

julia> ma
7-element MaskArray{Float64,1}:
 -0.742
  1.0
 -0.301
 -0.954
  2.0
  3.0
 -0.436
```

# Buffers

A `MaskArray` has a "buffer" to allow it to easily connect to outside data sources. By default, this is identical to the `imputed` values (so extra allocation is avoided). 

For example, say we have
```julia
julia> outside_data = randn(10)
10-element Vector{Float64}:
 -0.42452477906454783
  0.03203787170597264
  1.1366181451933932
 -2.018667288063533
  1.3208417491973015
  0.07966694888217887
  1.063328831016872
  0.07649454253602395
 -2.4029119018577814
  0.6908031059739369
```

we can connect a subset of this to our imputed values like this:

```julia
julia> ma2 = replace_buffer(ma, view(outside_data, 3:5))
7-element MaskArray{Float64,1}:
 -0.742
  1.0
 -0.301
 -0.954
  2.0
  3.0
 -0.436
```

After a change in the buffer, we need to `sync!` to push the results to the data:

```julia
julia> sync!(ma2)
7-element MaskArray{Float64,1}:
 -0.742
  1.1366181451933932
 -0.301
 -0.954
 -2.018667288063533
  1.3208417491973015
 -0.436
 ```

Now say we make a change to the outside data:

```julia
julia> outside_data .= 99999
10-element Vector{Float64}:
 99999.0
 99999.0
 99999.0
 99999.0
 99999.0
 99999.0
 99999.0
 99999.0
 99999.0
 99999.0

julia> sync!(ma2)
7-element MaskArray{Float64,1}:
    -0.742
 99999.0
    -0.301
    -0.954
 99999.0
 99999.0
    -0.436
```
