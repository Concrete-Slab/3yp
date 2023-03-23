function [zthetaE] = incidentCalculator(si,R)
%INCIDENTCALCULATOR Summary of this function goes here
%   Detailed explanation goes here
arguments(Input)
    si(1,:) Sample                          % input sample list
    R(1,1) double {mustBePositive} = 0.025  % internal radius of beam tube
end
arguments(Output)
    zthetaE(3,:) double                      % z(1,:) and theta(2,:) values of proton intersection
end
lenS = length(si);
zthetaE = zeros(3,lenS);
parfor i = 1:lenS
    zthetaE(:,i) = parGenerate(si(i),R);
end
end

function zthetaEVal = parGenerate(s,R)
    pos = s.pos;
    xi = pos(1);
    yi = pos(2);
    zi = pos(3);
    mom = s.fourMomentum.vec(2:4);
    E = s.fourMomentum.vec(1);
    a = mom(1)./mom(3);
    b = mom(2)./mom(3);
    polyCoefficients = [(a^2+b^2), 2*(xi*a+yi*b), (xi^2+yi^2-R^2)];
    z = roots(polyCoefficients);
    z = z(z>0)+zi;
    if length(z)>1
        warning("more than one z intersection solution")
        disp(z);
    end
    s = (a*z+xi)+sqrt(-1)*(b*z+yi);
    theta = angle(s);
    zthetaEVal = [z;theta;E];
end

