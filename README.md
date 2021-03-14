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
  missing
 2.7981042574409654
  missing
 3.604098449207802
  missing
 0.7771530789987786
 0.13614296317180433
```

Then we can convert this easily:
```julia
julia> ma = maskarray(x)
7-element MaskArrays.MaskArray{Float64, 1, Vector{Float64}, Dict{Int64, Int64}, Vector{Float64}}:
 6.9260378314933e-310
 2.7981042574409654
 6.92603783148617e-310
 3.604098449207802
 6.9260378314917e-310
 0.7771530789987786
 0.13614296317180433
```

The imputed values are stored here:
```julia
julia> imputed(ma)
3-element Vector{Float64}:
 6.9260378314933e-310
 6.92603783148617e-310
 6.9260378314917e-310
```

For example, we can easily do

```julia
julia> imputed(ma) .= 0.0
3-element Vector{Float64}:
 0.0
 0.0
 0.0

julia> ma
7-element MaskArrays.MaskArray{Float64, 1, Vector{Float64}, Dict{Int64, Int64}, Vector{Float64}}:
 0.0
 2.7981042574409654
 0.0
 3.604098449207802
 0.0
 0.7771530789987786
 0.13614296317180433
```

or

```julia
julia> imputed(ma) .= randn(3)
3-element Vector{Float64}:
 -1.1414540384041585
 -0.49701283338792845
 -0.27001612213513915

julia> ma
7-element MaskArrays.MaskArray{Float64, 1, Vector{Float64}, Dict{Int64, Int64}, Vector{Float64}}:
 -1.1414540384041585
  2.7981042574409654
 -0.49701283338792845
  3.604098449207802
 -0.27001612213513915
  0.7771530789987786
  0.13614296317180433
```
