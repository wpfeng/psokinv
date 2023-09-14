function Stress = StrainToStress(Strain, lambda, mu)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% StressToStrain.m
%
% Calculate stresses and invariants given a strain tensor and elastic
% moduli lambda and mu.
%
% This paper should and related code should be cited as:
% Brendan J. Meade, Algorithms for the calculation of exact 
% displacements, strains, and stresses for Triangular Dislocation 
% Elements in a uniform elastic half space, Computers & 
% Geosciences (2007), doi:10.1016/j.cageo.2006.12.003.
%
% Use at your own risk and please let me know of any bugs/errors!
%
% Copyright (c) 2006 Brendan Meade
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
if nargin < 2
   lambda = 3.0e2;
end
if nargin < 3
   mu = lambda;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Stress.sxx = 2.*mu.*Strain.xx + lambda.*(Strain.xx+Strain.yy+Strain.zz);
Stress.syy = 2.*mu.*Strain.yy + lambda.*(Strain.xx+Strain.yy+Strain.zz);
Stress.szz = 2.*mu.*Strain.zz + lambda.*(Strain.xx+Strain.yy+Strain.zz);
Stress.sxy = 2.*mu.*Strain.xy;
Stress.sxz = 2.*mu.*Strain.xz;
Stress.syz = 2.*mu.*Strain.yz;
Stress.I1 = Stress.sxx + Stress.syy + Stress.szz;
Stress.I2 = -(Stress.sxx.*Stress.syy + Stress.syy.*Stress.szz + Stress.sxx.*Stress.szz) + Stress.sxy.*Stress.sxy + Stress.sxz.*Stress.sxz + Stress.syz.*Stress.syz;
Stress.I3 = Stress.sxx.*Stress.syy.*Stress.szz + 2.*Stress.sxy.*Stress.sxz.*Stress.syz - (Stress.sxx.*Stress.syz.*Stress.syz + Stress.syy.*Stress.sxz.*Stress.sxz + Stress.szz.*Stress.sxy.*Stress.sxy);


