function [lb,ub] = sim_fpara2constraint(fpara,ilbs,ilbd,iubs,iubd,whichnonzero)
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
 % Created by Feng,W.P., @ BJ, 2008-12
 % Modified by Feng,W.P., @ GU, 2012-09-07
 % -> some basic information is added...
 %
 if ilbs == 0
     zeros_sl=0.000000000000000000000000000000000;
     zeros_su=0.000000000000000000000000000000001;
 else
     zeros_su=0.000000000000000000000000000000000;
     zeros_sl=-0.00000000000000000000000000000001;
 end
 if ilbd == 0
     zeros_dl=0.000000000000000000000000000000000;
     zeros_du=0.000000000000000000000000000000001;
 else
     zeros_dl=-0.000000000000000000000000000000001;
     zeros_du= 0.000000000000000000000000000000000;
 end
 %
 nf    = size(fpara,1);
 lbs = zeros(nf,1)+ilbs;
 lbd = zeros(nf,1)+ilbd;
 ubs = zeros(nf,1)+iubs;
 ubd = zeros(nf,1)+iubd;
 %%%%%%
 %ind   = sim_fpara2sort(fpara);
 % updated by FWP, @ GU, 2013-03-26
 ind   = sim_fpara2sortv2(fpara);
 %
 maxr  = max(ind(:,1));
 maxc  = max(ind(:,2));
 lbs( ind(:,1)==1) = zeros_sl;
 lbd( ind(:,1)==1) = zeros_dl;
 ubs( ind(:,1)==1) = zeros_su;
 ubd( ind(:,1)==1) = zeros_du;
 lbs( ind(:,2)==1) = zeros_sl;
 lbd( ind(:,2)==1) = zeros_dl;
 ubs( ind(:,2)==1) = zeros_su;
 ubd( ind(:,2)==1) = zeros_du;
 %%%%%%%%%%
 lbs( ind(:,1)==maxr) = zeros_sl;  % Bottom
 lbd( ind(:,1)==maxr) = zeros_dl;
 ubs( ind(:,1)==maxr) = zeros_su;
 ubd( ind(:,1)==maxr) = zeros_du;
 lbs( ind(:,2)==maxc) = zeros_sl;  % Up-edge constraints
 lbd( ind(:,2)==maxc) = zeros_dl;
 ubs( ind(:,2)==maxc) = zeros_su;
 ubd( ind(:,2)==maxc) = zeros_du;
 
 if isempty(whichnonzero)==0 
    numI= size(whichnonzero,2);
    for noi = 1:numI
        %whichnonzero{noi}
        switch upper(whichnonzero{noi})
            case 'B'
               lbs( ind(:,2)==maxc) = ilbs;
               lbd( ind(:,2)==maxc) = ilbd;
               ubs( ind(:,2)==maxc) = iubs;
               ubd( ind(:,2)==maxc) = iubd;
            case 'U'
               lbs( ind(:,2)==1) = ilbs;
               lbd( ind(:,2)==1) = ilbd;
               ubs( ind(:,2)==1) = iubs;
               ubd( ind(:,2)==1) = iubd;
            case 'R'
               lbs( ind(:,1)==maxr) = ilbs;
               lbd( ind(:,1)==maxr) = ilbd;
               ubs( ind(:,1)==maxr) = iubs;
               ubd( ind(:,1)==maxr) = iubd;
            case 'L'
               lbs( ind(:,1)==1) = ilbs;
               lbd( ind(:,1)==1) = ilbd;
               ubs( ind(:,1)==1) = iubs;
               ubd( ind(:,1)==1) = iubd;
        end
    end
 end
 %
 lb                   = [lbs;lbd];
 ub                   = [ubs;ubd];
 
