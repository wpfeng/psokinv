function [slap,dlap,lap] = sim_fpara2lapv2(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Created by Feng, Wanpeng,skyflow2008@126.com, 2010-05
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 mstr = mean(fpara(:,3));
 numf = size(fpara,1);
 x0   = fpara(1,1);
 y0   = fpara(1,2);
 cx   = sim_rotaxs(x0,y0,mstr,90,fpara(:,1),fpara(:,2));
 cy   = fpara(:,5);                   %/sind(fpara(:,4);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 slap = zeros(numf);
 dlap = slap;
 %
 for ni=1:numf
     adist       = sqrt((cx-cx(ni)).^2+(cy-cy(ni)).^2);
     [sdist,ind] = sort(adist);
     if numel(ind)<17
        iend = numel(ind);
     else
        iend = 17;
     end
     idx         = ind(2:iend);
     rdist       = sqrt((fpara(ni,1)-fpara(idx,1)).^2+...
                        (fpara(ni,2)-fpara(idx,2)).^2+...
                        (fpara(ni,5)-fpara(idx,5)).^2);
     for nj=1:iend-1
         slap(ni,idx(nj)) = -1./rdist(nj);%./distr(nj);
     end
     slap(ni,ni)     = sum(abs(1./rdist));
 end
dlap = slap;
%
lap = [dlap dlap.*0;dlap.*0 dlap];
