%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% ps_forword_init
% +Usage:
%     get all infomation in the GUI of ps_forward.
hid = findobj('tag','edt_psoksar');
ginfo.psoksar = get(hid,'String');
disp(ginfo);
