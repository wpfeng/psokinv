function [G,wfpara,outlap,lb,ub,oG,laps] = sim_fpara4G(fpara,dx,dy,L,W,topdepth,input,thd,alp,whichnon)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%Purose:
%   Automatic program for LS Slip inversion
%Input:
%   fpara, the Parameters from uniform inversion, N*10 matrix
%   dx,    the Length of each patch, km, N*1 matrix
%   dy,    the Width of each pathc, km, N*1 matrix
%   L,     the Length of new scaled fault, N*1 matrix
%   W,     the Width of new scaled fault, N*1 matrix
%     input, the Constraint data, M*5,matrix
%       thd, the threshold for cal green function...
%       alp, the alpha for media parameters in homogeous half-space...
%  whichnon, for boundary zero constraints
%Output:
%   outfp, a cell variable saving the distributed slip fpara.N*(L/dx*W/dy)
%          matrix
%**************************************************************************
% Created by Feng Wanpeng
% V1.0, 10/11/2008
% Modified by Feng W.P
% -> the boundary constraints created by the this function
%**************************************************************************
% Modified by Feng W.P., @GU, 2014-08-22
% -> the top depth should be taken into account...
%**************************************************************************
% Modified by Feng, W.P., @NRCan, 2016-04-18
% -> opening movement is allowed since this version...
% 
global rakecons Blb Bub mrakecons listmodel extendingtype dampingfactor ...
       isfix fixindex isrefine isopening smoothingmodel
%
%
nf     = size(fpara,1);
%
% Updated by FWP, @ UoG, 2013-06-27
%
if isempty(isfix)
    isfix = 0;
end
%
if size(extendingtype,1) == 0
    extendingtype = 'w';
end
%
% updated by fwp, @ IGPP of SIO, UCSD, 2013-10-02
if size(dampingfactor,1)==0
    dampingfactor = 1;
end
%
%
if size(rakecons,1) == 0
    rakecons      = zeros(nf,3);
    rakecons(:,2) = 0;
    rakecons(:,3) = 90;
end
if numel(rakecons(:,1))<nf
    rakecons = repmat(rakecons,nf,1);
end
%
meanstrike  = mean(fpara(:,3));
meandip     = mean(fpara(:,4));
%
switch extendingtype
    case 'foc'
        tfpara = sim_fparaconv(fpara,0,3);% Sensitivity Analysis
        meandepth = mean(tfpara(:,5));
    otherwise
        meandepth = mean(fpara(:,5));
end
%

tmprakecons = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfp  = cell(nf,1);
outlap = cell(nf,1);
wfpara = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lb    = zeros(2,nf);
ub    = zeros(2,nf);
alb_s = [];
alb_d = [];
aub_s = [];
aub_d = [];
%
% modified by Feng, W.P, @ BJ, 2010/01/01/
%
if size(fpara,1) ~= numel(L)
    L = zeros(size(fpara,1),1) + L(1);
end
if size(fpara,1) ~= numel(W)
    W = zeros(size(fpara,1),1) + W(1);
end
if size(fpara,1) ~= numel(dx)
    dx = zeros(size(fpara,1),1) + dx(1);
end
if size(fpara,1) ~= numel(dy)
    dy = zeros(size(fpara,1),1) + dx(1);
end
%
if isfix == 1
    nf = numel(fixindex);
end
%
%
for nof = 1:nf
    %
    if isfix == 0
        %tmp        = sim_fpara2whole(fpara(nof,:));
        tmp  = fpara(nof,:);
        %
        if numel(listmodel)==0
            listmodel = zeros(1,4);
        end
        if listmodel(1) == 0
            % 
            % Updated by by FWP, @ IGPP of SIO, UCSD, 2013-10-02
            % 1) dampingfactor was added to control the patchsize with
            % variation of depth...
            %
            disp([' ps_smest: SIM_fpara4G -> subdividing a fault along ', extendingtype,...
                  ' with a dampling factor:',num2str(dampingfactor)]);
            %
            if dampingfactor == 1
                %
                tem  = sim_fpara2dist(tmp,L(nof),W(nof),dx(nof),dy(nof),extendingtype,topdepth(nof));
            else
                %
                tmpfpara = [];
                rdepth   = topdepth(nof);
                switch upper(extendingtype)
                    case 'W'
                        refdepth = W(nof)*sind(tmp(4));
                    otherwise
                        refdepth = W(nof);
                end
                subflength = L(nof);
                xsize      = dx(nof);
                ysize      = dy(nof);
                while rdepth < refdepth
                    %
                    npatch     = fix(subflength/xsize);
                    if npatch == 0
                        npatch = 1;
                    end
                    %
                    xsize      = subflength/npatch;
                    tempfpara  = sim_fpara2dist(tmp,subflength,ysize,xsize,ysize,extendingtype,rdepth);
                    %
                    if numel(tempfpara(:,1))==0
                        disp([ysize,xsize]);
                    end
                    %
                    [t_mp,t_mp,iz] = sim_fpara2corners(tempfpara(1,:),'dc');
                    rdepth     = iz;
                    subflength = sum(tempfpara(:,7));
                    tmpfpara   = [tmpfpara;tempfpara];
                    xsize      = xsize*dampingfactor;
                    ysize      = ysize*dampingfactor;
                    %
                end
                tem = tmpfpara;
                %
            end
        else
            switch listmodel(1)
                case 1
                    tem = sim_fpara2dist_listric(tmp,W(nof),listmodel(2),L(nof),dx(nof),dx(nof),listmodel(3),'linear');
            end
        end
    else
        %
        index_fixfault = fixindex{nof};
        for cindex = 1:numel(index_fixfault)
            fpara(index_fixfault(cindex),6) = W(nof);
            fpara(index_fixfault(cindex),7) = L(nof);
        end
        %
        tem = sim_fixfpara(fpara(fixindex{nof},:),dx(nof),dy(nof),dampingfactor);
        %
    end
    %
    [t_mp,tem]    = sim_fpara2index(tem);
    outfp{nof} = tem;
    lap        = sim_fpara2lapv2(tem);
    outlap{nof}= lap;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lb         = 0;
    ub         = 10000;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Updated by FWP, @IGPP of SIO, UCSD, 2013-10-02
    %
    [tlb,tub]  = sim_fpara2bdconstraints(tem,lb,lb,ub,ub,whichnon{nof});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    alb_s = [alb_s;tlb(1:end/2)];
    aub_s = [aub_s;tub(1:end/2)];
    alb_d = [alb_d;tlb(end/2+1:end)];
    aub_d = [aub_d;tub(end/2+1:end)];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    wfpara  = [wfpara;tem];
    numf    = size(tem,1);
    %
    % update by feng,w.p., @ UoG, 2012-09-26
    % add a new col for identify of fault...
    %
    curcons      = zeros(numf,4);
    curcons(:,1) = rakecons(nof,1);
    curcons(:,2) = rakecons(nof,2);
    curcons(:,3) = rakecons(nof,3);
    curcons(:,4) = nof;
    tmprakecons  = [tmprakecons;curcons];
end
%
mrakecons = tmprakecons;
lb  = [alb_s;alb_d];
ub  = [aub_s;aub_d];
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tested by Feng, W.P.,2014-07-17
disp([' sim_smest: isrefine (',num2str(isrefine),')'])
%
if isrefine == 1
    %
    [wfpara,mrakecons,ub] = sim_finefpara(wfpara,input,mrakecons,ub);
    lb = ub.*0;
    %
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Blb    = lb;
Bub    = ub;
% 
% Updated by Wanpeng Feng, @CCRS/NRCan, 2017-04-24
%
if exist('smoothingmode','var')==0
    smoothingmodel='XY';
end
%
% Updated by Wanpeng Feng, @CCRS/NRCan, 2017-09-25
% Since this version, the laplacian matrix can be reestimated based on all
% fault patches, but it is not necessray. Flag of "refine" will turn off/on
% the estimation of laplacian matrix...
%
laps = outlap;
if isrefine == 1
  disp(' sim_fpara4G: Re-estimating Laplacian matrix based on all fault segments') 
  lap = sim_fpara2lap_bydist(wfpara,smoothingmodel);
  outlap{1} = lap;
else
  disp(' sim_fpara4G: Combining Laplacian matrix')
  lap = sim_laps2lap(outlap);
  outlap = [];
  outlap{1} = lap; 
end
%
% Opening movements are allowed now for simulation of volcano activities...
% Updated by Wanpeng Feng, @NRCan, 2016-04-18
%
[G,sG,dG,oG]  = sim_oksargreenALP(wfpara,input,thd,alp,[],meanstrike,meandip,meandepth);
%
% isopening, 1 for pure opening
% isopening, 2 for opening + slip on fault
% isopening, 0 for pure slip
% Updated by Wanpeng Feng, @NRCan, 2016-05-30
%
disp([' sim_fpara4G: Flag of Opening-slip: ',num2str(isopening)])
%
if abs(isopening) == 1 
    G = oG;
else
    if isopening == 2
        %
        G = [sG dG oG];
        %
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
