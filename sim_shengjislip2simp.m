function fpara = sim_shengjislip2simp(inshengji,outsimp,refzone,dx,dy)
%
%
%
% Read a USGS simple slip model 
% Developed by Feng, W.P., @ NRCan, 2015-10-07
%
data = load(inshengji);
%
[x,y] = deg2utm(data(:,1),data(:,2),refzone);
x     = x./1000;
y     = y./1000;
%
fpara = [x(:),y(:),data(:,6),data(:,7),data(:,3),x(:).*0+dy,x(:).*0+dx,...
        data(:,4).*cosd(data(:,5))./100,data(:,4).*sind(data(:,5))./100,x(:).*0];
%
% convert centroid slip model to that with the reference on the top centre
fpara = sim_fparaconv(fpara,3,0);
%
sim_fpara2simp(fpara,outsimp,refzone);
%