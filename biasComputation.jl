
function findProb(g::Array{Float64,1}, azm::Real, dip::Real, bias::Real)

    azm = azm*pi/180
    dip = dip*pi/180

    ns = [sin(azm)*sin(dip), -cos(azm)*sin(dip), cos(dip)];

    psi = asin(ns'*g/sqrt(g'*g))

    prob = abs(cos(psi))^bias
    prob

end
