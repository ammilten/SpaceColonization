module SpaceColonization

##Add these back in if the function doesn't work
# using Plots
# plotlyjs()

include("datatypes.jl")
#include("plotTree.jl")
include("spacecol.jl")
include("initializers.jl")
include("postproc.jl")

export
    Attractor,
    Branch,
    initAttractors,
    #plotTree,
    initRoots,
    branch2scatter,
    attractor2scatter,
    spacecol
end
