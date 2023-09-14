function azi = sim_line2azi(p)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose:
%    return the azimuth angle from two points
% Usage:
%    azi = sim_line2azi(p)
% Input:
%    p, 2*2,two points
% Output:
%    azi, degree angle
% Modification History:
%  Feng, Wanpeng, 2010-11-30, initial version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
azi = 90 - atan2(p(2,2)-p(1,2),p(2,1)-p(1,1))*180/pi;
azi = (azi > 0 )*azi + (azi <= 0) *(360+azi);
