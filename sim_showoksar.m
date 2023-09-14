function fpara = sim_showpsoksar(psoksarfile,ishow)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Function:
 %    Input the fault model in psoksar format.
 % Input:
 %     psoksarfile, the full file path (or current dir)
 %     ishow,       0,no show in 3d projection;1,show in 3d projection
 % Output:
 %     fpara,  the fault model in SIM format
 %     figure, if you set "ishow" equal 1, you will get a figure to show
 %             model in 3d
 % Created by Feng W.P 
 % University of Glasgow, 19 June 2009
 %
 fpara= sim_psoksar2SIM(psoksarfile);
 if ishow ==1 
    figure();
    sim_fig3d(fpara);
 end
