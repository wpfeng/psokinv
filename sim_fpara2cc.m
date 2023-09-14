function [p1,p2] = sim_fpara2cc(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng W.P, the code will return the center of the fault plane.
%
p1 = [];
p2 = [];
for ni=1:size(fpara,1)
    [x1,y1,z1] = sim_fpara2corners(fpara(ni,:),'uc');
    [x2,y2,z2] = sim_fpara2corners(fpara(ni,:),'cc');
    [x3,y3,z3] = sim_fpara2corners(fpara(ni,:),'lc');
    %points     = [points;x1,y1,z1;x2,y2,z2;x3,y3,z3];
    p1     = [p1;x1,y1,z1;x3,y3,z3];
    p2     = [p2;x2,y2,z2];
    
end
