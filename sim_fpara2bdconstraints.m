function [lb,ub] = sim_fpara2bdconstraints(fpara,ilbs,ilbd,iubs,iubd,whichnonzero,is2bands)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % whichnonzero , the array saving the indexes, which not be set to zero
 %                        U, the up side
 %                        B, the bottom side
 %                        L, the left side
 %                        R, the left side
 % A new functions for boundary identification...
 % developed by fWP, @ IGPP of SIO, UCSD, 2013-10-02
 % -> some basic information is added...
 %
 if nargin < 7
     is2bands = 1;
 end
 %
 %
 nf    = size(fpara,1);
 lbs   = zeros(nf,1)+ilbs;
 lbd   = zeros(nf,1)+ilbd;
 ubs   = zeros(nf,1)+iubs;
 ubd   = zeros(nf,1)+iubd;
 %
 %%%%%%
 sfpara      = fpara;
 sfpara(:,8) = lbs;
 sfpara(:,9) = ubs;
 dfpara      = fpara;
 dfpara(:,8) = lbd;
 dfpara(:,9) = ubd;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%
 findex = sim_fpara2index(fpara);
 %
 sfpara(findex(:,4)==1,9) = ilbs;
 sfpara(findex(:,5)==1,9) = ilbs;
 sfpara(findex(:,6)==1,9) = ilbs;
 sfpara(findex(:,7)==1,9) = ilbs;
 %
 dfpara(findex(:,4)==1,9) = ilbd;
 dfpara(findex(:,5)==1,9) = ilbd;
 dfpara(findex(:,6)==1,9) = ilbd;
 dfpara(findex(:,7)==1,9) = ilbd;
 %
 nbound = 1;
 
 for ni = 1:numel(whichnonzero)
     switch upper(whichnonzero{ni})
         
         case 'L'
             sfpara(findex(:,6)==1,9) = iubs;
             dfpara(findex(:,6)==1,9) = iubd;
         case 'R'
             sfpara(findex(:,7)==1,9) = iubs;
             dfpara(findex(:,7)==1,9) = iubd;
         case 'U'
             sfpara(findex(:,4)==1,9) = iubs;
             dfpara(findex(:,4)==1,9) = iubd;
         case 'B'
             sfpara(findex(:,5)==1,9) = iubs;
             dfpara(findex(:,5)==1,9) = iubd;
             nbound = 0;
     end
 end
 %
 if nbound == 1
    sfpara(findex(:,5)==1,9) = ilbs;
    dfpara(findex(:,5)==1,9) = ilbs;
 end
 %
 if is2bands == 1
     lb = [sfpara(:,8);dfpara(:,8)];
     ub = [sfpara(:,9);dfpara(:,9)];
 else
     lb = sfpara(:,8);
     ub = sfpara(:,9);
 end
 %
