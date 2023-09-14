function [fpara,zone] = sim_mw2fpara(x,y,focal,mw,slip,depth,isutm)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng, W.P., 2011/10/23
%
if nargin < 5
    slip = 2.0;
end
if nargin < 7
    isutm = 0;
end
%
zone = [];
if isutm==0
    [x,y,zone]  = deg2utm(y,x);
end
[lens,wids] = sim_mw2length(mw,slip);
%
fpara      = zeros(1,10);
if isutm == 0
    fpara(1)   = x./1000;
    fpara(2)   = y./1000;
else
    fpara(1)   = x;
    fpara(2)   = y;
end
fpara(3)   = focal(1);
fpara(4)   = focal(2);
fpara(6)   = wids*2;
fpara(7)   = lens/2;
fpara(8)   = slip.*cosd(focal(3));
fpara(9)   = slip.*sind(focal(3));
fpara(5)   = depth;
%
