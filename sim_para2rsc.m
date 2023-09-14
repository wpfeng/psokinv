function sim_para2rsc(outname,region,ps)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Develped by FWP,@BJ, 2010-01-01
%  Create a rsc header file based on input ROI
% 
% region, [minlon,maxlon,minlat,maxlat]
%     ps, [sizelon,sizelat], pixel size...
%
if nargin < 1 
   outname = 'TEST.img.rsc';
end
info = sim_roirsc();
info.x_first = region(1);
info.y_first = region(4);
info.x_step  = ps(1);
info.y_step  = abs(ps(2))*-1;
info.width   = ceil((region(2)-region(1))/ps(1));
info.file_length = ceil((region(4)-region(3))/ps(2));
info.xmax        = info.width - 1;
info.ymax        = info.file_length - 1;
sim_croirsc(outname,info);
