function [zone,x0,y0] = sar_rsc2zone(rsc)
%
%
%
% Return UTm zone number for a ROI_PAC image
% by Wanpeng Feng, @Ottawa, 2016-11-12
%
info = sim_roirsc(rsc);
maxlon = info.x_first + (info.width-1)*info.x_step;
minlat = info.y_first + (info.file_length-1)*info.y_step;
[x0,y0,zone] = deg2utm((minlat+info.y_first)/2,(maxlon+info.x_first)/2);
zone         = MCM_rmspace(zone);
%