function [lap,distfpara] = sim_fpara2lapv3(fpara,isjoint,l,w,pl,pw)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created by Feng,W.P., @BJ, 2011-09
% 
%
if isjoint <= 1
   distfpara = []; 
   for ni=1:numel(fpara(:,1))
       cfpara    = sim_fpara2dist(fpara(ni,:),l(ni),w(ni),pl(ni),pw(ni));
       distfpara = [distfpara;cfpara];
   end
   lap = sim_fpara2lapv2(distfpara);
else
   distfpara = [];
   mlap      = cell(1);
   lapindex  = zeros(2,1);
   lapindex(1) = 0;
   for ni = 1:isjoint-1
       cfpara     = sim_fpara2dist(fpara(ni,:),l(ni),w(ni),pl(ni),pw(ni));
       distfpara  = [distfpara;cfpara];
       mlap{ni}   = sim_fpara2lapv2(cfpara);
       lapindex(ni+1) = size(distfpara,1);
   end
   %
   dist2 = [];
   for nj = isjoint:size(fpara,1)
       cfpara = sim_fpara2dist(fpara(nj,:),l(nj),w(nj),pl(nj),pw(nj));
       dist2  = [dist2;cfpara];
   end
   distfpara  = [distfpara;dist2];
   lapindex(ni+2) = size(distfpara,1);
   mlap{ni+1}     = sim_fpara2lapv2(dist2);
   lap            = zeros(lapindex(end));
   for nk=1:numel(mlap)
       lap(lapindex(nk)+1:lapindex(nk+1),lapindex(nk)+1:lapindex(nk+1)) = ...
                                                       mlap{nk};
   end
end
