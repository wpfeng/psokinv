function [ix,iy,iz] = sim_fpara2corners(ifpara,type,incoor,outcoor,outzone)
%
%
% Purpose:
%       Return the corners' coordinates of a rectangular fault planet.
%       input the standard fpara model.
% Input:
%       fpara,it's the standar fpara dataset
%       type, it's the relative coordinates, which can be 
%
% Output:
%      x,y
% Created  by Feng Wanpeng (wanpeng.feng@hotmail.com), 01/07/2008
% Modified by Feng Wanpeng (wanpeng.feng@hotmail.com), 02/12/2008
%           -> add a keyword, coor. if the coor is 'LL', it will be
%           converted into the km automaticly.
% Modified by Feng Wanpeng, 19/12/2009
%           -> add a new type, "dc", which is for the beneath boundary CP
%           -> it's userful to sim_chngdip.m
%
if nargin<1
   %
   disp('[x,y,z] = sim_fpara2corners(fpara,type,incoor,outcoor,outzone)');
   %
   return
end
%
ix = zeros(numel(ifpara(:,1)),1);
iy = ix;
iz = ix;
%
for ni=1:numel(ifpara(:,1))
    %
    fpara = ifpara(ni,:);
    strike = fpara(3);
    dip    = fpara(4);
    wid    = fpara(6);
    rlen   = fpara(7);
    x0     = fpara(1);
    y0     = fpara(2);
    dep    = fpara(5);
    %
    %incoor
    if nargin < 3 || isempty(incoor)==1
        incoor = 'UTM';
    end
    if nargin < 4 || isempty(outcoor)==1
        outcoor = 'UTM';
    end
    if nargin < 5 || isempty(outzone)==1
        outzone = '33 T';
    end
    if strcmpi(incoor,'LL')==1
        [x0,y0] = deg2utm(y0,x0,[]);
        x0 = x0/1000;
        y0 = y0/1000;
    end
    %
    i  = sqrt(-1);
    ll = -0.5*rlen - i*wid*cosd(dip);    % low-left ,ul
    lr =  0.5*rlen - i*wid*cosd(dip);    % low-right,ur
    ul = -0.5*rlen + i*0*cosd(dip);      % up-left  ,ll
    ur =  0.5*rlen + i*0*cosd(dip);      % up-right ,lr
    strkr = (90-strike)*pi/180;
    ul = (x0+y0*i) + ul*exp(i*strkr);
    ur = (x0+y0*i) + ur*exp(i*strkr);
    ll = (x0+y0*i) + ll*exp(i*strkr);
    lr = (x0+y0*i) + lr*exp(i*strkr);
    %
    switch lower(type)
        case{'ul'}
            x = real(ul);
            y = imag(ul);
            z = dep;
        case{'ur'}
            x = real(ur);
            y = imag(ur);
            z = dep;
        case{'ll'}
            x = real(ll);
            y = imag(ll);
            z = dep+wid*sind(dip);
        case{'lr'}
            x = real(lr);
            y = imag(lr);
            z = dep+wid*sind(dip);
        case{'lc'}
            x = (real(lr)+real(ll))/2;
            y = (imag(lr)+imag(ll))/2;
            z = dep+wid*sind(dip);
        case{'uc'}
            x = (real(ur)+real(ul))/2;
            y = (imag(ur)+imag(ul))/2;
            z = dep;                  %+wid*sind(dip);
        case{'dc'}
            x = (real(lr)+real(ll))/2;
            y = (imag(lr)+imag(ll))/2;
            z = dep+wid*sind(dip);
        case{'cc'}
            x = (real(lr)+real(ll)+real(ur)+real(ul))/4;
            y = (imag(lr)+imag(ll)+imag(ur)+imag(ul))/4;
            z = dep+wid*sind(dip)/2;
    end
    if strcmpi(outcoor,'LL')==1
        [y,x] = utm2deg(x*1000,y*1000,outzone);
    end
    ix(ni) = x;
    iy(ni) = y;
    iz(ni) = z;
end
             
