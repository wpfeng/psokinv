function [roi,roip,nwid,nlen] = sar_rsc2roi(rscfile)

% + Purpose:
%   return the file region, the file has rsc header file...
% + Input:
%   rscfile, the rscfile is header info of image data file...
% + Output:
%   roi, [minx,maxx,miny,maxy]
% + Log:
%   Created by Feng, W.P, 20110510, @ BJ
%
%
%
if exist(rscfile,'file')~=0
    info = sim_roirsc(rscfile);
    %
    nwid = info.width;%ceil((roi(2)-roi(1))/info.x_step);
    nlen = info.file_length;%ceil((roi(4)-roi(3))/abs(info.y_step));
    %
    %
    roi  = [info.x_first,                    info.x_step*(info.width-1)+info.x_first,...
            info.y_first-abs(info.y_step)*(info.file_length-1),info.y_first,nwid,nlen];
    roip = [roi(1),roi(3);
            roi(1),roi(4);
            roi(2),roi(4);
            roi(2),roi(3);
            roi(1),roi(3)];
else
    disp([rscfile, ' is not existing. Please check the file...']);
    roi  = [];
    roip = [];
    nwid = [];
    nlen = [];
end
