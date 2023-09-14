%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% ps_forword_read
% read psoksar
%ginfo.currentformat
switch ginfo.currentformat
    case 'PSOKSAR'
        Gfpara = sim_psoksar2SIM(ginfo.psoksar);
    case 'FPARA'
        Gfpara = load(ginfo.psoksar);
    case 'OKSAR'
        Gfpara = sim_oksar2SIM(ginfo.psoksar);
end
Cfpara = Gfpara;
ginfo.faultnum = size(Gfpara,1);
ginfo.faultno  = 1;
set(ginfo.faultnoid,'Value',1);
set(ginfo.faultnoid,'String',num2cell(linspace(1,ginfo.faultnum,ginfo.faultnum)'));
set(ginfo.currentparaid,'String',num2str(Gfpara(ginfo.faultno,ginfo.para.no)));
