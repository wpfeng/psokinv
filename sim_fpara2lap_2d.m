function [slap,dlap,lap] = sim_fpara2lap_2d(fpara,xyzind)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Created by Feng, Wanpeng,wanpeng.feng@hotmail.com, 2010-05
 % Modified by FWP, @ UoG, 2013-06-17
 % xyzind, 1,2,5
 %         x,y,z
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 mstr = mean(fpara(:,3));
 numf = size(fpara,1);
 x0   = fpara(1,1);
 y0   = fpara(1,2);
 cx   = fpara(:,xyzind(1));%sim_rotaxs(x0,y0,mstr,90,fpara(:,1),fpara(:,2));
 cy   = fpara(:,xyzind(2));                   %/sind(fpara(:,4);
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
