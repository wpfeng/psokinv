function bndfpara = sim_fpara2bnd_xd(fpara,maxdepth,maxslip)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% set boundary patches with zero slip
% by Wanpeng Feng, @SYSU, Guangzhou, 2019/07/22
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 mstr   = mean(fpara(:,3));
 %
 % left 
 % 
 [tmpx,tmpy,botd] = sim_fpara2corners(fpara,'dc');
 bndfpara = fpara;
 if nargin < 3
     bndfpara(:,8) = 100;
     bndfpara(:,9) = 100;
 else
     bndfpara(:,8) = maxslip;
     bndfpara(:,9) = maxslip;
 end
 %
 if nargin > 1
     bndfpara(botd >= maxdepth,8) = 0;
     bndfpara(botd >= maxdepth,9) = 0;
 else
     bndfpara(botd >= max(botd),8) = 0;
     bndfpara(botd >= max(botd),9) = 0;
 end
 %
 depths = fpara(:,5);
 ufpara = fpara(fpara(:,5) == min(depths),:);
 [reftmpx,reftmpy] = eqs_rotaxs(ufpara(:,1),ufpara(:,2),mstr);
 % left
 [tmpx,tmpy] = sim_fpara2corners(fpara,'ul');
 %
 [cx,cy] = eqs_rotaxs(tmpx,tmpy,mstr);
 bndfpara(cx < min(reftmpx),8) = 0;
 bndfpara(cx < min(reftmpx),9) = 0;
 % right
 [tmpx,tmpy] = sim_fpara2corners(fpara,'ur');
 [cx,cy] = eqs_rotaxs(tmpx,tmpy,mstr);
 bndfpara(cx > max(reftmpx),8) = 0;
 bndfpara(cx > max(reftmpx),9) = 0;
 %
 % force the bottom with zero slip 
 strs = unique(bndfpara(:,3));
 for i = 1:size(strs,1)
     cfpara = bndfpara(bndfpara(:,3) == strs(i),:);
     cfpara(cfpara(:,5) == max(cfpara(:,5)),8) = 0;
     cfpara(cfpara(:,5) == max(cfpara(:,5)),9) = 0;
     bndfpara(bndfpara(:,3) == strs(i),:) = cfpara;
 end