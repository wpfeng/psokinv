function outvel = sim_oksar2horivel(oksar,factor,thresh)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
% Created by FWP, @ GU, 2013-07-05
%
if nargin < 1
    oksar = '../oksar/tk_dist_cskazi_30_89_20130629.oksar.out';
end
if nargin < 2
    factor = 4;
end
if nargin < 3
    thresh = 0.6;
end
%
fpara = sim_oksar2SIM(oksar);
zone  = sim_oksar2utm(oksar);
%
strikeslip = fpara(:,8);
dipslip    = fpara(:,9);
slip       = sqrt(strikeslip.^2+dipslip.^2);
%plot(slip)
%
minx = min(fpara(:,1));
miny = min(fpara(:,2));
maxx = max(fpara(:,1));
maxy = max(fpara(:,2));
[xgrid,ygrid] = meshgrid(minx:max(fpara(:,7))*factor:maxx,...
                         miny:max(fpara(:,6))*factor:maxy);
%
dims = size(xgrid);
outfpara = [];
for i = 1:dims(1)
    for j = 1:dims(2)
    %
       croi = [xgrid(i,j)-max(fpara(:,7))*factor/2, ygrid(i,j)-max(fpara(:,6))*factor/2;...
               xgrid(i,j)-max(fpara(:,7))*factor/2, ygrid(i,j)+max(fpara(:,6))*factor/2;...
               xgrid(i,j)+max(fpara(:,7))*factor/2, ygrid(i,j)+max(fpara(:,6))*factor/2;...
               xgrid(i,j)+max(fpara(:,7))*factor/2, ygrid(i,j)-max(fpara(:,6))*factor/2;...
               xgrid(i,j)-max(fpara(:,7))*factor/2, ygrid(i,j)-max(fpara(:,6))*factor/2];
       %
       %plot(croi(:,1),croi(:,2),'-r');
       %hold on
       %
       cindex = inpolygon(fpara(:,1),fpara(:,2),croi(:,1),croi(:,2));
       dindex = find(cindex==1);
       cslip  = slip(cindex==1);
       findex = find(cslip==max(cslip));
       
       if ~isempty(findex)
           %slip(findex(1))
           %plot(fpara(dindex(findex(1)),1),fpara(dindex(findex(1)),2),'ob');
           if slip(dindex(findex(1)))>thresh
              outfpara = [outfpara;fpara(dindex(findex(1)),:)];
           end
       end
    end
       
    %
end
%
fpara = outfpara;
strikeslip = fpara(:,8);
dipslip    = fpara(:,9);
%slip       = sqrt(strikeslip.^2+dipslip.^2);
%[rakes,mrake] = sim_calrake(fpara);
%rakes
%
%
%
[lat,lon]  = utm2deg(fpara(:,1).*1000,fpara(:,2).*1000,zone);
%[cx,cy]    = sim_rotaxs(strikeslip,dipslip,180-1.*fpara(:,3),0);%...fpara(:,4));
[cx,cy] = sim_3drotate(strikeslip,dipslip,mean(180-1.*fpara(:,3)),0);%mean(fpara(:,4)));
%
%
outvel = [lon,lat,cx,cy,cx.*0,cx.*0,cx.*0+0.5];
%quiver(lon,lat,cx,cy);
%
