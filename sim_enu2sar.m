function [simdis,simphs] = sim_enu2sar(e,n,u,azi,inc,model,lambda)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
% Created by Feng, W.P., @ GU, 2012/02/05
% Reference paper:
%   Fialko, Y., Simons, M. & Agnew, D. 
%   The complete (3-D) surface displacement field in the epicentral area of the 1999 Mw7.1 Hector Mine earthquake, California, from space geodetic observations. Geophysical Research Letters 28, 3063-3066 (2001).
%
%
if nargin < 6  || isempty(model)
    model = 'los';
end
if nargin < 7
    lambda = 0.2323;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch upper(model)
    case 'LOS'
        ve =  -1.*cosd(azi).*sind(inc);
        vn =      sind(azi).*sind(inc);
        vu =                 cosd(inc);
    case 'AZI'
        ve =  sind(azi);
        vn =  cosd(azi);
        vu =  0;
end
%
simdis = e.*ve + n.*vn + u.*vu;
simphs = simdis.*(4*pi)./(-1*lambda);
