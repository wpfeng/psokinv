function sim_psoksar2oksar(psoksar,oksar)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 % Convert the PSOOKSAR file into OKSAR file
 %    PSOKSAR, top and bot represent the vertical diretion to surface.
 %      OKSAR, top and bot represent the dip direction along the WIDTH.
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Modified by Feng, W.P, 2010-04-14
 % -> redefine oksar
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fpara = sim_psoksar2SIM(psoksar);
 sim_fpara2oksar(fpara,oksar);
