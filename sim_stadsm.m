function meanrake = sim_stadsm(fpara,thd)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Statistic info to the distributed Slip Model
 %
 % 
 slip = sqrt(fpara(:,8).^2+fpara(:,9).^2);
 fpara= fpara(slip>=thd,:);
 rake = atan2(fpara(:,9),fpara(:,8)).*180/3.14159265;
 meanrake = mean(rake(:));
