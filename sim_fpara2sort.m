function  [ilr,mfpara] = sim_fpara2sort(fpara,xytype)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%  Created by Feng, Wanpeng, at 20110127
% Modified by Feng, Wanpeng, at 20110127
% 
if nargin < 2
    if abs(sind(fpara(3,1))) >= abs(cosd(fpara(3,1)))
       xytype = 1;
    else
       xytype = 2;
    end
end
%
strikes = unique(fpara(:,3));
cfpara  = fpara;
cilr    = [];
outcell = cell(numel(strikes),1);
moffx   = [];
moffy   = [];
tindx   = outcell;
%
for nlk = 1:numel(strikes)
    tindx{nlk}= find(cfpara(:,3)==strikes(nlk));
    fpara     = cfpara(cfpara(:,3)==strikes(nlk),:);
    strike    = strikes(nlk);
    np     = size(fpara,1);
    ilr    = zeros(np,2);
    tfpara = fpara(fpara(:,5)==max(fpara(:,5)),:);
    offx   = min(tfpara(:,1));
    offy   = tfpara(tfpara(:,1)==min(tfpara(:,1)),2);
    %
    % modification by Feng,Wanpeng, if strike equal to 0,90,180,270,360
    % code will go wrong, 2011-03-26
    %
    offx   = offx(1);
    offy   = offy(1);
    for nop = 1:np
        %
        i          = sqrt(-1);
        str        = (90-strike)*3.14159265/180;
        ll         = ((fpara(nop,1)+fpara(nop,2)*i)-(offx+i*offy))*exp(-i*str);
        ilr(nop,1) = real(ll)./fpara(nop,7);
        ilr(nop,2) = fpara(nop,5)./sind(fpara(nop,4))/fpara(nop,6);
    end
    %mfpara         = [mfpara;fpara];
    ilr(:,1)       = ilr(:,1)-min(ilr(:,1));
    ilr(:,2)       = ilr(:,2)-min(ilr(:,2));
    %
    ilr            = round(ilr);
    ilr            = ilr + 1;
    outcell{nlk}   = ilr;
    moffx          = [moffx;offx(:)];
    moffy          = [moffy;offy(:)];
end
%
if xytype == 1
    [~,indx] = sort(moffx);
else
    [~,indx] = sort(moffy);
end
outind = [];
for ni = 1:numel(strikes)
    ilr  = outcell{indx(ni)};
    if isempty(cilr)==1
        rmax = 0;
    else
        rmax = max(cilr(:,1));
    end
    cilr   = [cilr;ilr(:,1) + rmax ilr(:,2)];
    outind = [outind;tindx{indx(ni)}];
end
%
mfpara   = cfpara(outind,:);
ilr      = cilr;
[~,ind]  = sort(ilr(:,1));
ilr      = ilr(ind,:);
mfpara   = mfpara(ind,:);
%
