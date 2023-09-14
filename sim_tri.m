function [trif,outcps,info] = sim_tri(fpara,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% +Name:
%      [trif,outcps,info] = sim_tri(fpara,varagin)
%      create TRIF fault model from SIM model(fpara)
% TRIF:
%      a structure array to describe the fault models
%      trif.x, 1*3, x-coordinates of three triangle vertices
%      trif.y, 1*3, y-coordinates of three triangle vertices
%      trif.z, 1*3, z-coordinates of three triangle vertices
%      trif.cx, 1, x-coordinates of the center of triangle
%      trif.cy, 1, y-coordinates at the center of triangle
%      trif.cz, 1, z-coordinates of the center of triangle
%      trif.index, the indexes of the vertices in the all points
%      trif.id,    the ID number in all triangle patches
%      trif.neighbor, the neighbor ID which share two vertices
%      trif.numneig,  the number of neighbor
% +Input:
%      fpara, the initial fault model with rectangle
% +Output:
%      trif, the fault model in TRI format
%      outcps, the center points of TRI fault models
%      info, a structure variable to output points,number of triangles.
% +LOG:
% Created by Feng W.P, IGP/CEA, 2009/11/24
%
%%%%%%%%%%% 
if nargin<1
   disp('[trif,outcps] = sim_tri(fpara,varargin)');
   disp('please input enough variables...');
   return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxlength = 2;
maxratio  = 2;
minarea   = 0.01;
maxarea   = 4;
isshow    = 0;
rdepth    = 0; % is the depth value of upper line each rectangular
isall     = 0; % is get the all corners of each rectangular
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v = sim_varmag(varargin);
for j = 1:length(v)
   eval(v{j});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[triX,triY,triZ,info] = sim_fpara2tri(fpara,maxratio,maxlength,...
                                      maxarea,...
                                      minarea,isshow,rdepth,isall);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ntri        = info.ntri;
trif        = struct([]);
points      = info.points;
points(:,3) = points(:,3).*-1;
outindex    = [];
outcps      = [];
%
for ni = 1:ntri
    trif(ni).x     = triX(ni,:);
    trif(ni).y     = triY(ni,:);
    trif(ni).z     = triZ(ni,:);
    trif(ni).ss    = 0;
    trif(ni).ts    = 0;
    trif(ni).ds    = 0;
    trif(ni).id    = ni;
    index          = zeros(3,1);
    for nk=1:3
     flag        = [points(:,1)-triX(ni,nk) ...
                    points(:,2)-triY(ni,nk) ...
                    points(:,3)-triZ(ni,nk)];
     flag        = flag(:,1).^2+flag(:,2).^2+flag(:,3).^2;
     [nflg,inds] = sort(flag);
     index(nk)   = inds(1);
    end
    outindex     = [outindex;sort(index')];
    % return the indexes which corners are in the points...
    trif(ni).index = index;
    trif(ni).cx    = mean(trif(ni).x);
    trif(ni).cy    = mean(trif(ni).y);
    trif(ni).cz    = mean(trif(ni).z);
    trif(ni).neighbor = [];
    outcps            = [outcps;trif(ni).cx trif(ni).cy trif(ni).cz];
end
%
for ni=1:ntri
    f_1a = outindex(:,1)-outindex(ni,1);
    f_1b = outindex(:,2)-outindex(ni,1);
    f_1c = outindex(:,3)-outindex(ni,1);
    f_2a = outindex(:,1)-outindex(ni,2);
    f_2b = outindex(:,2)-outindex(ni,2);
    f_2c = outindex(:,3)-outindex(ni,2);
    f_3a = outindex(:,1)-outindex(ni,3);
    f_3b = outindex(:,2)-outindex(ni,3);
    f_3c = outindex(:,3)-outindex(ni,3);
    flag = [abs(f_1a.*f_1b.*f_1c) ...
            abs(f_2a.*f_2b.*f_2c) ...
            abs(f_3a.*f_3b.*f_3c)];
    neighbor = [];
    invindex = [];
    for nk = 1:ntri
        num0 = find(flag(nk,:)' == 0);
        if numel(num0)==2
           neighbor = [neighbor;nk];
        end
    end
    trif(ni).neighbor = neighbor;
    trif(ni).numneig  = numel(neighbor);
    
end
info.outindex = outindex;
%
%

