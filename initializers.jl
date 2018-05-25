
function initAttractors(locs)
    s=size(locs)
    #Change to 3 for 3d
    if s[2] == 2
        #Pad with zeros if necessary
        locs=[locs zeros(s[1])]
    elseif s[2] ≠ 3
        error("Error: wrong number of dimensions")
    end

    #Add attractors to array
    att=Attractor[]
    for i=1:s[1]
        push!(att,Attractor(locs[i,:]))
    end
    att

end


function initRoots(locs)
    s=size(locs)
    #Change to 3 for 3d
    if s[2] == 2
        #Pad with zeros if necessary
        locs=[locs zeros(s[1])]
    elseif s[2] ≠ 3
        error("Error: wrong number of dimensions")
    end

    #Add attractors to array
    att=Branch[]
    for i=1:s[1]
        push!(att,Branch(locs[i,:],i,0))
    end
    att

end
