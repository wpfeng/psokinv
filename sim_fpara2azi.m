function fpara = sim_fpara2azi(fpara,minazi)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% 
% + Purpose:
%    set the all fault model with same upper wall and footwall.
% + LOG:
%  created by Feng, W.P
%
if nargin < 2
    minazi = 180;
end
fpara(fpara(:,3)<0,3)      = 360+fpara(fpara(:,3)<0,3);
%
fpara(fpara(:,3)>minazi,4) = 180-fpara(fpara(:,3)>minazi,4);
fpara(fpara(:,3)>minazi,3) = fpara(fpara(:,3)>minazi,3)-180;
