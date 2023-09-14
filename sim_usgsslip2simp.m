function fpara = sim_usgsslip2simp(inusgs,outsimp,refzone,strike,dip,dx,dy)
%
%
%
% Read a USGS simple slip model 
% Developed by Feng, W.P., @ NRCan, 2015-10-07
%
data = load(inusgs);
%
[x,y] = deg2utm(data(:,1),data(:,2),refzone);
x = x./1000;
y = y./1000;
fpara = [x(:),y(:),strike+x(:).*0,dip+x(:).*0,data(:,5),x(:).*0+dy,x(:).*0+dx,data(:,6).*cosd(data(:,7)),data(:,6).*sind(data(:,7)),x(:).*0];
% convert centroid slip model to that with the reference on the top centre
fpara = sim_fparaconv(fpara,3,0);
%
sim_fpara2simp(fpara,outsimp,refzone);
%