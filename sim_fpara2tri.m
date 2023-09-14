function [triX,triY,triZ,info] = sim_fpara2tri(fpara,maxratio,maxlength,maxarea,minarea,isshow,rdepth,isall)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% +Name:
%        [triX,triY,triZ] = sim_fpara2tri(fpara,mindist,minarea,isshow)
% +Purpose:
%        convert the rectangular fault model into the triangular fault
%        plane
% +Input:
%        fpara, n*10, SIM format for rectangular fault model
%      maxlength, propotion, max(length)/min(length) in a triangle...
%      maxarea, the threshold of the maximum area to continume split plane
%       isshow, the flag show if the triplane will display automatically.
% +Output:
%       triX, the x-coordiantes in the triplane corners
%       triY, the y-coordinates in the triplane corners
%       triZ, the z-coordinates in the triplane corners
%       info, including the patch numbers, minimum area, maxnimum area 
% Created by Feng Wanpeng, IGP/CEA, 2009/11/23
% Latest Version: v0.1
% Modified by Feng, Wanpeng, IGP/CEA,2010/07/01
% Latest version,v0.2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
   disp('[x,y,z,ntri] = sim_fpara2tri(fpara,maxlength,maxarea,isshow)');
   triX = [];
   triY = [];
   triZ = [];
   return
end
if nargin < 2
   maxratio = 2;
end
if nargin < 3
   maxlength = 2;
end
if nargin < 4
   maxarea = 2;
end
if nargin < 5
   minarea = 0.001;
end
if nargin < 6
   isshow = 0;
end
if nargin < 7 || isempty(rdepth) == 1
   rdepth = 0;
end
if nargin < 8
    isall = 0;
end
if size(fpara,1)==1
    fpara = sim_fpara2dist(fpara,fpara(7),fpara(6),fpara(7),fpara(6),'w',rdepth);
end
%sim_fig3d(fpara);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
azi      = mean(fpara(:,3));
if isall ~=1
   tpoints  = sim_fpara2cc4tri(fpara);
else
   tpoints  = sim_fpara2allcors(fpara);
   tpoints  = tpoints(1:4,:);
end
areaflag = 10^100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while areaflag > maxarea;
    outp      = tpoints;
    [cx,~]    = eqs_rotaxs(outp(:,1),outp(:,2),azi);
    cx        = ceil(cx.*10)./10;
    dinp      = cx.*0.001+abs(ceil(outp(:,3).*10)./10);
    [~,uind]  = unique(dinp);
    outp      = outp(uind,:);
    tpoints   = tpoints(uind,:);
    cx        = cx(uind);
    cz        = fix(outp(:,3).*100)./100;
    bndindex  = sim_findbnds(cx,cz);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TRI       = delaunay(cx(:,1),cz(:).*-1); %outp(:,3));
    nTRI      = size(TRI,1);
    triX      = zeros(nTRI,3);
    triY      = triX;
    triZ      = triX;
    area_h    = zeros(nTRI,2);
    %index     = zeros(nTRI,1);
    for ni = 1 : nTRI
        triX(ni,:)   = outp(TRI(ni,:),1);
        triY(ni,:)   = outp(TRI(ni,:),2);
        triZ(ni,:)   = outp(TRI(ni,:),3).*-1;
        P            = [triX(ni,:)'  triY(ni,:)'  triZ(ni,:)'];
        area_h(ni,1) = triangle_area(P,'h');
        [maxr,maxl,ind1,ind2] = maxlength_SUB(P);
        area_h(ni,2)          = maxr;
        area_h(ni,3)          = maxl;
        %
        if area_h(ni,2) > maxratio
            %
            tfeng = [1,2,3];
            a1    = tfeng == ind1;
            a2    = tfeng == ind2;
            bb    = a1 + a2;
            ind3  = tfeng(bb==0);
            if sum(bndindex==ind3) == 0
                tmP   = P(ind3,:);
                fnd1  = tpoints(:,1)-tmP(1);
                fnd2  = tpoints(:,2)-tmP(2);
                fnd3  = tpoints(:,3)-tmP(3);
                fnd   = fnd1.^2+fnd2.^2+fnd3.^2;
                tpoints(fnd==min(fnd),:) = [];
            end
        end
        if area_h(ni,1) > maxarea || area_h(ni,3) > maxlength %&& area_h(ni,1) >= minarea)
            if area_h(ni,2) <= maxratio
               tmP       = mean(P);
            else
               tmP       = (P(ind1,:)+P(ind2,:))./2;
            end
            tmP(:,3)  = tmP(:,3).*-1;
            tpoints   = [tpoints;tmP];
        end
    end
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    triX(area_h(:,1)  <minarea,:) = [];
    triY(area_h(:,1)  <minarea,:) = [];
    triZ(area_h(:,1)  <minarea,:) = [];
    area_h(area_h(:,1)<minarea,:) = [];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ntri                     = size(triX,1);
    info.ntri                = ntri;
    info.minarea             = min(area_h(:,1));
    info.maxarea             = max(area_h(:,1));
    info.maxleng             = max(area_h(:,2));
    info.points              = outp;
    info.area                = area_h(:,1);
    areaflag                 = max(area_h(:,1));
end
if isshow == 1
   patch(triX',triY',triZ',area_h(:,2)'+1);
end
%
% Subrountines, Feng, Wanpeng
%
function [maxratio,maxlen,ind1,ind2] = maxlength_SUB(P)
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         dist1 = sqrt((P(1,1)-P(2,1)).^2+(P(1,2)-P(2,2)).^2+(P(1,3)-P(2,3)).^2);
         dist2 = sqrt((P(3,1)-P(2,1)).^2+(P(3,2)-P(2,2)).^2+(P(3,3)-P(2,3)).^2);
         dist3 = sqrt((P(1,1)-P(3,1)).^2+(P(1,2)-P(3,2)).^2+(P(1,3)-P(3,3)).^2);
         minl  = min([dist1;dist2;dist3]);
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         [maxratio,I] = max([dist1;dist2;dist3]./minl);
         maxlen       = max([dist1;dist2;dist3]);
         switch I
             case 1
               ind1 = 1;
               ind2 = 2;
             case 2
               ind1 = 2;
               ind2 = 3;
             case 3
               ind1 = 1;
               ind2 = 3;
         end
%  End of the function

