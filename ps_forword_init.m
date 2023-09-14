%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% ps_forword_init
% +Usage:
%     get all infomation in the GUI of ps_forward.
% psoksar
hid = findobj('tag','edt_psoksar');
ginfo.psoksar = get(hid,'String');
ginfo.psoksarid = hid;
%
% inp
hid = findobj('tag','edt_inp');
ginfo.inp = get(hid,'String');
% format
hid = findobj('tag','list_format');
ginfo.format.no    = get(hid,'value');
ginfo.format.value = get(hid,'String');
ginfo.currentformat = ginfo.format.value{ginfo.format.no};
% no fault
hid = findobj('tag','list_fault_index');
ginfo.faultno = get(hid,'value');
ginfo.faultnoid = hid;
% no parameter
hid               = findobj('tag','list_para_index');
ginfo.para.no     = get(hid,'value');
ginfo.para.value  = get(hid,'String');
%ginfo.currentpara = ginfo.para.value{ginfo.para.no};
% value of parameters
hid               = findobj('tag','edt_para_value');
ginfo.currentpara = str2double(get(hid,'String'));
ginfo.currentparaid = hid;
% value of parameters
hid               = findobj('tag','edt_step');
ginfo.step        = str2double(get(hid,'String'));
ginfo.stepid      = hid;
%%%%%
ginfo.faultnum    = 0;
%
ginfo.az = 20;
ginfo.el = 30;
ginfo.fig3dposition = [];
