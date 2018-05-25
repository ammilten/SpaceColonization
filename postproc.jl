function branch2scatter(branchList::Array{Branch,1})

    #Initialize
    branches = []

    #Loop through branches
    for br in branchList
        branches = [branches; br.loc']
    end

    #Return
    branches
end

function attractor2scatter(attrList::Array{Attractor,1})

    #Initialize
    attr = []

    #Loop through branches
    for att in attrList
        attr = [attr; att.loc']
    end

    #Return
    attr
end
