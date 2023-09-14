function [UB,LB,mBND] = sim_mPS2bnd(mfpara,mPS,whichbnds,mR)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% +Purpose:
%   create the boundary constraits by given boundary conditions...
% +Input:
%     mfpara, the cell array for fault models
%        mPS, the cell array for points saving
% whichconds, the cell array for boudary conditions
%         mR, the cell array for rake constraints
% +Log:
% created by Feng, Wanpeng, 20110320, working for Japan 20110311 EQ
%
%   
if nargin < 3
    whichbnds{1} = {'U'};
end
%
mBND = sim_fpara2bnds(mfpara,mPS);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mUB = cell(1);
mLB = cell(1);
for nk=1:numel(mfpara)
    cBND = mBND{nk};
    %
    UB   = zeros(size(cBND,1),1)+100;
    % updated by Feng, 20110410
    % different segments should have different boundary constraints...
    %
    twhichbnds = whichbnds{nk};
    for ni=1:numel(twhichbnds)
        switch upper(twhichbnds{ni})
            case 'U'
                UB(cBND(:,8)==1)  = 0;
            case 'B'
                UB(cBND(:,8)==-1) = 0;
            case 'R'
                UB(cBND(:,8)==2)  = 0;
            case 'L'
                UB(cBND(:,8)==-2) = 0;
        end
    end
    LB      = UB.*0;
    mUB{nk} = UB;
    mLB{nk} = LB;
end
%
fUB = [];
bUB = [];
%
for ni=1:numel(mfpara)
    cr  = mR{ni};
    tUB = mUB{ni};
    
    if cr(ni,1)==cr(ni,2)
        fUB = [fUB;[]];
        bUB = [bUB;tUB];
    else
        fUB = [fUB;tUB];
        bUB = [bUB;tUB];
    end
end
UB = [fUB;bUB];
LB = UB.*0;
