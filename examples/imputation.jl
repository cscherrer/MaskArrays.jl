using MaskArrays

using Distributions

# Get a positive definite matrix for the covariance
z = randn(6,5)
Σ = z' * z

# Use that to build a distribution
d = MvNormal(Σ)

# Sample from it and "forget" some values
x = Vector{Union{Missing, Float64}}(undef, 5)
x .= rand(d)
x[[2,4]] .= missing

# Use the result to build a MaskArray
ma = maskarray(x)

using TupleVectors
using Sobol
using StatsFuns

# Now sample and log-weight the result
ω = SobolHypercube(2)
s = @with (;ω) 10000 begin
    # A very naive proposal
    x = 5 * norminvcdf(rand(ω))
    y = 5 * norminvcdf(rand(ω))
    imputed(ma) .= [x,y]

    # The log-weight
    ℓ = logpdf(d, ma)

    (;ℓ, x, y)
end

using StatsBase

# Use the log-weights to resample
rs = TupleVector(sample(s, Weights(exp.(s.ℓ)), 1000))

# And plot the result
using UnicodePlots
@with TupleVectors.unwrap(rs) begin
    scatterplot(x, y)
end

# julia> @with TupleVectors.unwrap(rs) begin
#            scatterplot(x, y)
#        end
#       ┌────────────────────────────────────────┐ 
#     4 │⠀⠀⠀⠁⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⢀⠀⢀⡀⣀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⢄⢀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⢂⡱⣃⡀⡃⡄⡄⢼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠚⠡⢒⢽⣿⢯⣸⠄⠠⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠄⠳⣽⣻⢿⢢⣷⠍⣂⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
#       │⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠥⢷⡿⣿⢷⡧⡿⣼⣮⣤⡤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢼⡷⣳⠵⣿⢞⣚⢆⠧⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠁⠈⣛⠾⣯⢝⢣⢽⡲⢇⡠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠘⠘⠄⠟⢏⡧⢏⣷⢒⢦⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠊⠒⠫⣎⣿⢜⠪⠄⠂⢄⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠗⠌⠗⢆⠱⠂⠀⠀⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠣⠐⠡⡂⠀⠄⠁⠀⠀⠀⠀│ 
#       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀│ 
#    -5 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀│ 
#       └────────────────────────────────────────┘ 
#       -4                                       5
