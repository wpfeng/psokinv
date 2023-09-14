function [cx,cy] = sar_rsc2cc(inrsc)
%
%
% To return lonlat at center of an image which has a rsc file
% by wanpeng feng, @Ottawa, 2017-04-14
%
cx = [];
cy = [];
%
info = sim_roirsc(inrsc);
fwid  = info.width;
flength = info.file_length;
cx = info.x_first + fwid/2 * info.x_step;
cy = info.y_first + flength / 2 * info.y_step;