function [slap,dlap,lap] = sim_fpara2lap_v4(fpara,xyzindex)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Created by Feng, Wanpeng,skyflow2008@126.com, 2010-05
 % Updated by fWP, @ IGPP of SIO, UCSD, 2013-10-16
 % + Input:
 % fpara,     discretized fault models n x 10
 % xyzindex,  flag for smoothing control, n x 3
 % tnum = 100;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 numf = size(fpara,1);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 slap = zeros(numf);
 %
 cfpara = fpara;
 cfpara(:,8) = fpara(:,5);
 flag = xyzindex{1};
 if flag(1)==0 || flag(1) == 1
     cfpara(:,9) = fpara(:,1);
 else
     cfpara(:,9) = fpara(:,2);
 end
 %
 for ni=1:numf
     %
     adist       = sqrt((cfpara(:,8)-cfpara(ni,8)).^2+...
                        (cfpara(:,9)-cfpara(ni,9)).^2);
     %
     [~,cindex]  = sort(adist);
     %
     adist(:) = 0;
     adist(cindex(2:17)) = -1./16;
     adist(cindex(1)) = 1;
     slap(ni,:)      = adist;
 end
 %slap = slap./(max(abs(slap(:))));
 dlap = slap;
 lap  = [slap    slap.*0; ...
         slap.*0 dlap]; 
 
 return
