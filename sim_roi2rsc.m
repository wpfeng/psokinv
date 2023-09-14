function sim_roi2rsc(roi,xinc,outname,inc,azi)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Createf by Feng, W.P., 2011-10-23, @ GU
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 2
    xinc = 0.0008333;
end
if nargin < 4
    inc = 24;
end
if nargin < 5
    azi = -166.7;
end
%
info = sim_roirsc();
info.x_first = roi(1);
info.y_first = roi(4);
info.x_step  = xinc;
info.y_step  = -1*xinc;
info.width       = ceil((roi(2)-roi(1))./xinc);
info.file_length = ceil((roi(4)-roi(3))./xinc);
info.xmax        = info.width - 1;
info.ymax        = info.file_length - 1;
info.heading_deg = azi;
info.incidence   = inc;
%
sim_croirsc(outname,info);
%

