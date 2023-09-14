function [slap,dlap,lap] = sim_fpara2lap_xd(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Created by Feng, Wanpeng,wanpeng.feng@hotmail.com, 2010-05
 % Modified by FWP, @ UoG, 2013-06-17
 % Updated by Wanpeng Feng, @Ottawa, 2016-10-27
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 mstr   = mean(fpara(:,3));
 numf   = size(fpara,1);
 tfpara = sim_fparaconv(fpara,0,3);
 cx     = eqs_rotaxs(tfpara(:,1),tfpara(:,2),mstr);
 cx     = cx - min(cx(:));
 cy     = tfpara(:,5);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 slap = zeros(numf);
 %dlap = slap;
 %
 for ni=1:numf
     adist          = sqrt((cx-cx(ni)).^2+(cy-cy(ni)).^2);
     [rdix,ind]     = sort(adist);
     if numel(ind)<17
        iend = numel(ind);
     else
        iend = 17;
     end
     %
     idx   = ind(2:iend);
     rdist = rdix(2:iend);
     %
     for nj=1:iend-1
         slap(ni,idx(nj)) = -1./rdist(nj);%./distr(nj);
     end
     slap(ni,ni)     = sum(abs(1./rdist));
 end
dlap = slap;
%
lap = [dlap dlap.*0;dlap.*0 dlap];
