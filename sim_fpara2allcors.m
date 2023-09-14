function p = sim_fpara2allcors(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Created by Feng, W.P., @ BJ, 2009/11/01
 % 
 [x1,y1,z1] = sim_fpara2corners(fpara,'lr');
 [x2,y2,z2] = sim_fpara2corners(fpara,'ll');
 [x3,y3,z3] = sim_fpara2corners(fpara,'ul');
 [x4,y4,z4] = sim_fpara2corners(fpara,'ur');
 [x5,y5,z5] = sim_fpara2corners(fpara,'cc');
 p          = [x1,y1,z1;...
               x2,y2,z2;...
               x3,y3,z3;...
               x4,y4,z4;...
               x5,y5,z5];
