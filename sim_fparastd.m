function output = sim_fparastd(oksar,thresh)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created by FWP, @ GU, 2012-11-16
%
if nargin < 2
    thresh = 0.5;
end
output     = [];
fpara      = sim_oksar2SIM(oksar);
slip       = sqrt(fpara(:,8).^2 + fpara(:,9).^2);
maxslip    = max(slip);
[m1,m2,m3] = sim_fpara2moment(fpara);
[~,mnrk]   = sim_calrake(fpara,thresh);
%
disp(' +++++++++++++++++++++++++++++++++++++++++ ');
disp('             EQ Information                ');
disp(['          ', oksar]);
disp(' +++++++++++++++++++++++++++++++++++++++++ ');
disp([' Maximum   slip:',num2str(maxslip,'%10.5f')]);
disp(['             Mw:',num2str(m3,'%5.3f')]);
disp([' Seismic Moment:',num2str(m2,'%i')]);
disp([' Mean Rake Angl:',num2str(mnrk)]);
%
sim_fig3d(fpara);
