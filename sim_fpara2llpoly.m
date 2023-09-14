function [polygon,topline] = sim_fpara2llpoly(fpara,refpoint)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
polygon = [];
[~,~,zone] = deg2utm(refpoint(2),refpoint(1));
outpoints  = [];
for ni = 1:size(fpara,1)
    [x1,y1,z1] = sim_fpara2corners(fpara(ni,:),'ul');
    [x2,y2,z2] = sim_fpara2corners(fpara(ni,:),'ur');
    [x3,y3,z3] = sim_fpara2corners(fpara(ni,:),'lr');
    [x4,y4,z4] = sim_fpara2corners(fpara(ni,:),'ll');
    cp      = [x1,y1;x2,y2;x3,y3;x4,y4;x1,y1];
    [x0,y0] = utm2deg(cp(:,1).*1000,cp(:,2).*1000,zone);
    polygon = [polygon;...
               x0,y0;nan nan];
    %oupoints = [oupoints;x1,y1,z1;x2,y2,z2;x3,y3,z3;x4,y4,z4];
    cfpara = sim_fpara2rand_UP(fpara(ni,:));
    [cx1,cy1] = sim_fpara2corners(cfpara,'uc');
    %[cx2,cy2] = sim_fpara2corners(cfpara,'ur');
    outpoints = [outpoints;cx1,cy1];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% oupoints(:,3) = oupoints(:,3).*-1;
% D    = oupoints(:,1).*0+1;
% cofs = oupoints\D;
% %
% minx = min(oupoints(:,1));
% maxx = max(oupoints(:,2));
% miny = cofs(1)/(-1*cofs(2))*minx + 1/cofs(2);
% maxy = cofs(1)/(-1*cofs(2))*maxx + 1/cofs(2);
% %
% x       = linspace(minx,maxx,1000);
% y       = linspace(miny,maxy,1000);
% %topline = [x(:),y(:)];
D    = outpoints(:,1).*0+1;
cofs = outpoints\D;
if fpara(1,3)~=180
   [px,ix]= sort(outpoints(:,1));
   py   = outpoints(ix,2);
   p    = [px,py];
   minx = min(p(:,1));
   maxx = max(p(:,1));
   miny = cofs(1)/(-1*cofs(2))*minx + 1/cofs(2);
   maxy = cofs(1)/(-1*cofs(2))*maxx + 1/cofs(2);
else
   [px,ix]= sort(outpoints(:,2));
   py   = outpoints(ix,1);
   p    = [px,py];
   miny = min(p(:,2));
   maxy = max(p(:,2));
   minx = cofs(2)/(-1*cofs(1))*miny + 1/cofs(1);
   maxx = cofs(2)/(-1*cofs(1))*maxy + 1/cofs(1);
end

 x       = linspace(minx,maxx,1000);
 y       = linspace(miny,maxy,1000);
[x0,y0] = utm2deg(x.*1000,y.*1000,zone);
topline = [x0(:),y0(:)];


