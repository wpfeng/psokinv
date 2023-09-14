function nfpara = sim_shiftfpara(fpara,lshift,dirs)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Usage:
%     nfpara = sim_shiftfpara(fpara,lshift,dirs)
% Input:
%     fpara,  the n*10, fault model
%     lshift, shift length,km
%     dirs,   direction, the switch flag:1 for right;-1 for left;
% Ouput:
%     nfpara, the fault model after shift
% Modification History:
%     Feng, Wanpeng, 2010-11-29, created
%
if nargin < 1
    disp('nfpara = sim_shiftfpara(fpara,lshift,dirs)');
    nfpara = [];
    return
end
if nargin < 3
   dirs = 1;
end
nfpara = fpara;
for ni = 1:numel(fpara(:,1))
   cfpara = fpara(ni,:);
   cfpara(7) = lshift*2;
   if dirs == -1
       [x,y] = sim_fpara2corners(cfpara,'ul');
   else
       [x,y] = sim_fpara2corners(cfpara,'ur');
   end
   cfpara(1) = x;
   cfpara(2) = y;
   cfpara(7) = fpara(ni,7);
   nfpara(ni,:) = cfpara;
end
   
