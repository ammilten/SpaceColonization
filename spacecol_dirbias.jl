include("biasComputation.jl")
function spacecol2(roots::Array{Branch, 1}, leaves::Array{Attractor, 1},
    D::Real; pthresh::Real = 0, dk::Real = 10*D, iterLim::Real = 1000,
    azm::Real = 0, dip::Real = 0, bias::Real = 0)

if dk < D
    error("Error: Kill distance (dk) cannot be less than discretization (D)")
end
if bias < 0
    error("Error: Bias cannot be less than zero")
end
azm=-azm

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

    #For all attractors assign to a most probable branch
    for att in activeAtt

        #Initialize testing parameters
        nearestInd=-1;
        maxProb=-1;

        #Find nearest branch
        for br in Vsearch

            #Find vector connecting points
            vec = att.loc - br.loc;

            #Find probability scaled by distance
            prob = findProb(vec,azm,dip,bias)

            prob = prob/norm(vec)

            #Test for maximum likelihood
            if prob > maxProb || maxProb == -1

                #Update maximum likelihood
                maxProb = prob

                #Record which branch is most likely
                nearestInd = br.index
            end
        end

        #Call nearest branch
        nbr = Vall[nearestInd]
        att.nearestBranch = nbr.index

        # #Weight and update direction of most likely branch (no radius of influence)
        # if isempty(nbr.dir)
        #     nbr.dir = (att.loc - nbr.loc) * maxProb
        # else
        #     nbr.dir = nbr.dir + (att.loc - nbr.loc) * maxProb
        # end

        #Test to see if the branch is sufficiently likely
        if maxProb > pthresh

            #Update direction for most probable branch
            if isempty(nbr.dir)
                nbr.dir = (att.loc - nbr.loc) * maxProb
            else
                nbr.dir = nbr.dir + (att.loc - nbr.loc) * maxProb
            end
        end

        #Kill attractor if it's within kill distance
        if norm(att.loc-nbr.loc) < dk
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
        break
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
