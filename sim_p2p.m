function op = sim_p2p(point,strike,length)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Developed by FWP,@gU, 2009-10-01
%   calculate coordinates using fpara format (fault geometry) based on the
%   azimuth and distance
% Input:
% point,  (x,y)
% strike, azimuth angle
% length, distance
%
fpara         = [point(1),point(2),strike,90,0,1,2*length,0,0,0];
[x0,y0,zone ] = deg2utm(point(2),point(1));
[x1,y1]       = sim_fpara2corners(fpara,'ur','LL','LL',zone);
%
op            = [x1,y1];
