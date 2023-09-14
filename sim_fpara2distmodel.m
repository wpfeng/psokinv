function [mfpara,outresult] = sim_fpara2distmodel(fpara,input,mrakecons,mC,mPS,alpha,minmoment,algor,whichbnds,outmat,ismc,updata)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% +Purpuose:
%     fpara,  cell format for multiple sets faults,cell(m,1)
%     input,  observation N*7
%  rakecons,  initial value of rake angle, m*3
%        mC,  the cell for covariance matrix
%       mat,  the Covarance matrix of observations
%     alpha,  the smooth constant
% minmoment,
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by Feng, Wanpeng, 2011-03-30
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
global slipscale
%
if nargin < 7
    algor = 'cgls';
end
if nargin < 6
    minmoment = 0;
end
if nargin < 5
    alpha = 20:10:100;
end
if nargin < 10
    outmat = 'temp.mat';
end
if nargin < 11
    ismc = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ismat = exist(outmat,'file');
fprintf('%s \n','<FixTrace Model> 1) Begin to calculate GREEN function by Okada85...');
if ismat ==  0
    %
    fprintf('%s \n',['<FixTrace Model>    ' outmat ' has not been found. So to re-calculate now...']);
    mG = cell(numel(fpara),1);
    mL = cell(numel(fpara),1);
    mR = cell(numel(fpara),1);
    %
    afpara = [];
    %
    for ni=1:numel(fpara)
        [G,rakes] = sim_fpara2green(fpara{ni},input,mrakecons{ni});
        lap       = sim_fpara2lap_bydist(fpara{ni});
        mG{ni}    = G;
        mL{ni}    = lap;
        mR{ni}    = rakes;      % all rake constraints
        afpara    = [afpara;fpara{ni}];
        %
    end
    %fprintf('%s \n','<FixTrace Model> 2) The G function is ok...');
    %a        = rakecons(:,2)==rakecons(:,3);
    inds    = 1:numel(fpara);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %mG       = mG(inds);
    G        = sim_mG2G(mG,mrakecons);
    L        = sim_mL2L(mL)./400;
    COV      = sim_mC2COV(mC);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %rakecons = rakecons(inds,:);
    mR       = mR(inds);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fr       = [];  % the first rake angle of each patch
    br       = [];  % the end   rake angle of each patch
    for ni = 1:numel(mR)
        cr = mR{ni};
        %
        for nj = 1:numel(cr(:,1))
            if cr(nj,1)==cr(nj,2)
                fr = [fr ;[]];
                br = [br;cr(nj,2)'];
            else
                fr = [fr;cr(nj,1)'];
                br = [br;cr(nj,2)'];
            end
        end
    end
    [UB,LB,mBND] = sim_mPS2bnd(fpara(inds),mPS(inds),whichbnds(inds),mR);
    eval(['save ' outmat ' G input L mR fr br mrakecons rakes LB UB COV mBND afpara']);
    fprintf('%s \n',['<FixTrace Model>    The calculation is finished. ' outmat ' has been saved for future use...']);
else
    fprintf('%s \n',['<FixTrace Model>    ' outmat ' has been found. Directly load it now...']);
    eval(['load ' outmat ]);
    %['load ' outmat ]
    %fprintf('%s \n','<FixTrace Model>    Object mat has been found. Directly load it now...');
    fprintf('%s \n','<FixTrace Model>    G have been got...');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pause(0.1);
%whos G
mfpara = cell(numel(alpha),1);
%
fprintf('%s \n','<FixTrace Model> 2) Begin to invert the slip model...');
%
outresult = zeros(numel(alpha),3);
%
% update for MC error estiamte
%
if ismc == 1
   input(:,3) = updata;
end
%
parfor ni = 1:numel(alpha)
    %
    slips = sim_lsq(G,input(:,3),L,alpha(ni),COV,algor,minmoment,LB,UB,input(:,7));
    osim  = G*slips;
    res   = input(:,3)-osim;
    roug  = abs(L*slips);
    roug  = sort(roug,'descend');
    outs  = fix(numel(roug)/2);
    roug  = roug(1:outs);
    outresult(ni,:) = [alpha(ni),std(res),sum(roug)/numel(roug)];
    nf    = numel(fr);
    nb    = numel(br);
    sslip = slips(1:end/2);
    dslip = slips(end/2+1:end);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    afpara = [];
    for nj = 1:numel(fpara)
        afpara      =[afpara;fpara{nj}];
    end
    %
    afpara(:,8) = sslip.*cosd(fr) + dslip.*cosd(br);
    afpara(:,9) = sslip.*sind(fr) + dslip.*sind(br);
    mfpara{ni}  = afpara;
    %fprintf('%s \n','<FixTrace Model>    Begin to invert the slip model...');
    fprintf('%s %3d %s %7.4f %s\n','<FixTrace Model>    NO: ',ni,' (ALPHA:',alpha(ni),') it is ok now...');
end
fprintf('%s \n','<FixTrace Model> 3) Distributed-Slip model is ok. Please check them...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    
    
