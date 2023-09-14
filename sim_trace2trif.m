function [trif,fpara,pfpara] = sim_trace2trif(points,dip,maxdist,width,subwid)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if nargin <1 
     disp('trif = sim_trace2trif(points,dip,maxdist,width,subwid)');
     disp('Created by Feng W.P');
     return
 end
 if nargin < 2
     dip = 90;
 end
 if nargin < 3
    maxdist = 2;
 end
 if nargin < 4
    width = 20;
 end
 if nargin < 5
    subwid = 2;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 npoints = size(points,1);
 fpara   = [];
 dazim   = zeros(npoints-1,1);
 pfpara  = [];
 for ni = 1 : npoints-1
     p1    = points(ni,:);
     p2    = points(ni+1,:);
     distv = sqrt((p1(1)-p2(1)).^2+(p1(2)-p2(2)).^2);
     dazi  = 90-atan2(p2(2)-p1(2),p2(1)-p1(1))*180/pi;
     dazim(ni) = dazi;
     %
     cfpara = [(p1(1)+p2(1))/2,(p1(2)+p2(2))/2,...
              dazi,dip,0,1,distv,1,1,0];
     pfpara = [pfpara;cfpara(1:5),width,distv,1,1,0];
     tfpara = sim_fpara2dist(cfpara,distv,width,distv/ceil(distv/maxdist),subwid);
     fpara  = [fpara;tfpara];
 end
 [trif,outcps,info] = sim_tri(fpara,'maxarea',maxdist^2);
 
