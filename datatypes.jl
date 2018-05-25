
mutable struct Attractor
    loc::Array{Real,1}
    active::Bool
    nearestBranch::Int64

    Attractor(loc) = new(loc,true,0)
end
function kill(att::Attractor)
    att.active=false
end

mutable struct Branch
    loc::Array{Real,1} #Position
    index::Int64 #Ex: index=6 means it was the 6th branch created
    parent::Int64 #Index of parent branch
    dir::Array{Real,1} #For computing directions

    function Branch(loc,ind,par)
        s=size(loc)
        if s[1] == 2
            loc=[loc;0]
        elseif s[1] ≠ 3
            error("Error: wrong number of dimensions")
        end

        new(loc,ind,par,[])
    end
end
