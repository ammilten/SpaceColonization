function spacecol(roots::Array{Branch, 1}, leaves::Array{Attractor, 1},
    D::Real; di::Real = Inf, dk::Real = 10*D, iterLim::Real = 1000)

if dk < D
    error("Error: Kill distance (dk) cannot be less than discretization (D)")
end

#Copying properties so input arguments don't get changed
Vall = copy(roots)
Vsearch = copy(Vall)
attractors = copy(leaves)

#To keep track of the branch indices
brcount = length(Vall)

#Iteration number to keep tract of iteration limit
iter=1

#Main algorithm
while ~isempty(attractors)

    #Copy over active indices
    activeAtt=copy(attractors)

    #Initialize activeAtt indices to kill
    killInd=Int64[];

    #For all attractors assign to a nearest branch
    for att in activeAtt

        #Initialize testing parameters
        nearestInd=-1;
        minDist=-1;

        #Find nearest branch
        for br in Vsearch

            #Find vector connecting points
            vec = att.loc - br.loc;

            #Test for minimum distance
            if norm(vec) < minDist || minDist == -1

                #Update minimum distance
                minDist = norm(vec)

                #Record which branch is closest
                nearestInd = br.index
            end
        end

        #Call nearest branch
        nbr = Vall[nearestInd]
        att.nearestBranch = nbr.index

        #Test to see if the branch is within the radius of influence
        if minDist < di

            #Update direction for nearest branch
            if isempty(nbr.dir)
                nbr.dir = (att.loc - nbr.loc) / minDist
            else
                nbr.dir = nbr.dir + (att.loc - nbr.loc) / minDist
            end
        end

        #Kill attractor if it's within kill distance
        if minDist < dk
            att.active = false
            filter!(e->e != att,attractors)
        end

    end

    #Initialize an updated Vsearch
    Vsearch_update = copy(Vsearch)

    #Update all branches if necessary
    for br in Vsearch

        #Only worry if the direction was updated
        if ~isempty(br.dir)
            #println(br)

            #Compute daughter branch location
            #add noise proportional to the size of the vecto
            noise = rand(3) * norm(br.dir) * .2
            br.dir = br.dir + noise
            n = br.dir/norm(br.dir)
            locd = br.loc + n*D
            #println(n)

            #Update branch count
            brcount = brcount + 1

            #Create daughter branch
            brd = Branch(locd, brcount, br.index)

            #Add daughter branch to list of all branches
            push!(Vall, brd)

            #Add daughter branch to search branches
            push!(Vsearch_update, brd)

            #Set parent direction as empty for next iteration
            br.dir = []

        #Otherwise the branch is dead
        else
            filter!(e -> e != br, Vsearch_update)
        end
    end

    #Update search branches
    Vsearch = copy(Vsearch_update)

    #Make sure all branches are not dead
    if isempty(Vsearch)
        #println(attractors)
        warn("All branches died before all attractors were killed. Be careful with results.")
    end

    #Keep track of number of iterations
    iter=iter+1
    if iter > iterLim
        warn("Iteration limit reached. Be careful with results. Something went wrong or the iteration limit needs to be raised.")
        break
    end

end

#Output branches
Vall
end
