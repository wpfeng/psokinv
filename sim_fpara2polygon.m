function polygon = sim_fpara2polygon(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 %
 if nargin < 1 || isempty(fpara)==1
    disp('polygon = sim_fpara2polygon(fpara)');
    return
 end
 [x1 y1] = sim_fpara2corners(fpara,'ll',[]);
 [x2 y2] = sim_fpara2corners(fpara,'lr',[]);
 [x3 y3] = sim_fpara2corners(fpara,'ur',[]);
 [x4 y4] = sim_fpara2corners(fpara,'ul',[]);
 polygon  = [x1 y1;...
             x2 y2;...
             x3 y3;...
             x4 y4;...
             x1 y1];

 
