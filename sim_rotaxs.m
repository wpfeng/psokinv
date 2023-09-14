function [cx,cy] = sim_rotaxs(x0,y0,strike,dip,cx0,cy0)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Created by Feng,W.P, 2009-01-01
 %
 if nargin < 5
    cx0 = 0;
 end
 if nargin < 6
    cy0 = 0;
 end
 i       = sqrt(-1);
 strkr   = (90-strike).*pi/180; 
 %
 start   = (cx0+cy0*i);
 outdata = ((x0+y0.*i)-start).*exp(-i*strkr);
 cx      = real(outdata);
 cy      = imag(outdata).*cosd(dip);
 
