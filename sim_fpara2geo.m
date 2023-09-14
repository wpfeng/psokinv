function [lon,lat] = sim_fpara2geo(fpara,zone)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Developed by FWP, @ BJ, 2010-10-01
 %
 rfpara    = sim_fpara2rand_UP(fpara,20,20);
 [lat,lon] = utm2deg(rfpara(:,1)*1000,rfpara(:,2)*1000,zone); 
