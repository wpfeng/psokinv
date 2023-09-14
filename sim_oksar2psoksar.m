function sim_oksar2psoksar(oksar,psoksar)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 % Convert the OKSAR file into PSOKSAR file
 %    PSOKSAR, top and bot represent the vertical diretion to surface.
 %      OKSAR, top and bot represent the dip direction along the WIDTH.
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Modified by Feng, W.P, 2010-04-14
 % -> redefine oksar
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fpara = sim_oksar2SIM(oksar);
 sim_fpara2psoksar(fpara,psoksar);
