function rfpara = sim_fixmodel2chng(fpara,nw,nl)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
tfpara = [500,500,120,85,0,nw*1,nl*1,0,0,0];
distf  = sim_fpara2dist(tfpara,nw,nl,1,1);
whos distf
