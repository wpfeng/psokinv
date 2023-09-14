function [fpara,tfpara,points] = sim_xyz2fpara(ps,nw,nl,now,nol)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% nw, number of patches along dipping 
% nl, number of patches along strike
% now, NO along dip
% nol, NO along strike
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by Feng, W.P,2011-03-30
%
ps(:,3) = ps(:,3).*-1;
f1 =[linspace(ps(1,1),ps(2,1),nl);...
     linspace(ps(1,2),ps(2,2),nl);...
     linspace(ps(1,3),ps(2,3),nl)];
f3 =[linspace(ps(4,1),ps(3,1),nl);...
     linspace(ps(4,2),ps(3,2),nl);...
     linspace(ps(4,3),ps(3,3),nl)];
p1 = sim_3d2points2xyz(f1(:,  nol),f3(:,  nol),nw,now);
p2 = sim_3d2points2xyz(f1(:,nol+1),f3(:,nol+1),nw,now);
p3 = sim_3d2points2xyz(f1(:,nol+1),f3(:,nol+1),nw,now+1);
p4 = sim_3d2points2xyz(f1(:,  nol),f3(:,  nol),nw,now+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
points    = [p1;p2;p3;p4];
% patch(points(:,1),points(:,2),points(:,3),1);
% hold on
meanv     = mean(points(1:2,:));
D         = [1;1;1;1];
cofs      = points\D;
[azi,dip] = sim_cofs2mec(cofs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fpara     = zeros(1,10);
fpara(1:2)= meanv(1:2);
fpara(3)  = azi;
fpara(4)  = dip;
fpara(5)  = abs(meanv(3));
%
mw_1      = mean(points([1,2],:));
mw_2      = mean(points([3,4],:));
ml_1      = mean(points([1,4],:));
ml_2      = mean(points([2,3],:));
fpara(6)  = sqrt(sum((mw_1-mw_2).^2));
fpara(7)  = sqrt(sum((ml_1-ml_2).^2));
tfpara    = sim_fparaconv(fpara,3,0);
