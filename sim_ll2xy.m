function [x,y] = sim_ll2xy(lats,lons)
%
%
%
% 
lla = [lats(:) lons(:) lons(:).*0];
out = lla2ecef(lla);
%
x = out(:,2)/1000.;
y = out(:,1)/1000.;