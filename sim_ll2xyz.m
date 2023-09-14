function [x,y,z] = sim_ll2xyz(lons,lats,r,e)
%
% Convert longlat(s) to km in a cartesian coordinate
% This is appliable at the equator and I would strongly 
% suggest using a conversion between lonlat and utm in the 
% areas far from the equator. 
% +Output:
% y and z can be considered to use in modelling
%
% by Wanpeng Feng, @SYSU, Guangzhou, 2019/05/06
%
if nargin < 3
    %
    r = 6378.1370; % at the Equator
end
if nargin < 4
    e = (6378.140-6356.755)/6378.140; 
end
%
%
x = r .* cosd(lats) .* cosd(lons);
y = r .* cosd(lats) .* sind(lons);
z = (r*(1-e^2)) .* sind(lats);