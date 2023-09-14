function [cx,cy,zone] = sar_roi2cenp(inrsc,isupdate)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
% Created by FWP, @ GU, 2013-03-1
%
if nargin < 2
    isupdate = 2;
end
%
info = sim_roirsc(inrsc);
proj = info.projection;
%
% initialize the parameters
cx   = [];
cy   = [];
zone = [];

%
disp(' sar_roi2cenp: ');
if isempty(strfind(upper(proj),'UTM'))
    %
    %
    wid   = info.width;
    len   = info.file_length;
    xstep = info.x_step;
    ystep = info.y_step;
    xfir  = info.x_first;
    yfir  = info.y_first;
    cx    = xfir + wid/2 * xstep;
    cy    = yfir + len/2 * ystep;
    %
    [~,~,zone] = deg2utm(cy,cx);
    %
    fprintf('[lon, lat] at the centre of the image:  %10.7f %10.7f %s\n', cx,cy,zone);
else
    %
    disp(' The projection of the image has been in UTM.');
    disp(' The processing will quite without any operation.');
    return
end
%
if isupdate == 1
    info.utmzone = MCM_rmspace(zone);
    sim_croirsc(inrsc,info);
    %
end
