function fpara = sim_empirical2foc(mag,type)
%
%
% Reference:
% Wells, D. L. & Coppersmith, K. J. New Empirical Relationships among Magnitude, 
%   Rupture Length, Rupture Width, Rupture Area, And Surface Displacement. 
%   Bull. Seism. Soc. Am. 84, 974-1002 (1994).
% Based on a given magnitude, return an emperical fault model...
% by Feng, W.P., @ IGP, 2015-09-01
%
mu = 3.23e10;
%
switch upper(type)
    case 'SS'
        %
        rld = 10.^(-2.57+0.62.*mag);
        rw  = 10.^(-0.76+0.27.*mag);
        %
        sa  = rw.*rld.*10^6;
        ss  = sim_mag2moment(mag)./mu./sa;
        %
        fpara = [rw.*0,rw.*0,rw.*0,rw.*0+90,rw.*0,rw,rld,ss,ss.*0,ss.*0];
        %
    case 'R'
    case 'N'
end
%
