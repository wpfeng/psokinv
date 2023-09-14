function sim_roi2rsc_v2(roi,xinc,yinc,outname,inc,azi,varargin)
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
if nargin < 3
    yinc = 0.0008333;
end
if nargin < 5
    inc = 24;
end
if nargin < 6
    azi = -166.7;
end
%

% updated by FWP, @SYSU, Guanghzou, 2021/0613
lamda = 0.05600;
for ni = 1:2:numel(varargin)
    %
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
end
%
info = sim_roirsc();
info.wavelength = lamda;
info.x_first = roi(1);
info.y_first = roi(4);
info.x_step  = xinc;
info.y_step  = -1*yinc;
%
% modified by FWP, @SYSU, 2021/06/13
info.width       = ceil((roi(2)-roi(1))./xinc)+1;
info.file_length = ceil((roi(4)-roi(3))./yinc)+1;
info.xmax        = info.width - 1;
info.ymax        = info.file_length - 1;
info.heading_deg = azi;
info.incidence   = inc;
%
sim_croirsc(outname,info);
%

