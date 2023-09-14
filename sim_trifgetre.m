function [trif,outflag,besttrif] = sim_trifgetre(matfile,cdip,thd,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% created by Feng, Wanpeng, working to return the triangluar best-fitting
% model automatically due to input information..
% 2010-06-20. Beijing...
% Version: 2.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1 || exist(matfile,'file')==0
   disp('Please give a proper matfile path!!');
   trif = [];
   return
end
if nargin < 3
    thd = 0.02;
end
if nargin < 4
    isplot = 1;
end
eval(['load ' matfile]);
nmodel   = size(msmest,1);
outflag  = zeros(nmodel,4);
besttrif = cell(nmodel,1);
fig1 = figure('Name','STD && Roughness');
fig2 = figure('Name','Roughness && MW');
fig3 = figure('Name','OSIM && OBS');
for ni=1:nmodel
    smest = msmest{ni,1};
    mslip = msmest{ni,2};
    osim  = msmest{ni,3};
    trif  = msmest{ni,5};
    %whos osim
    %
    index = find(abs(smest(:,3)-thd)==min(abs(smest(:,3)-thd)));
    if isempty(index)==1
       index = 1;
    end
    if isplot==1
        figure(fig1);
        plot(smest(:,3),smest(:,2),'o-b');
        hold on
        text(smest(end,3),smest(end,2),['DIP:',num2str(smest(1,5))]);
        hold on
        index = find(abs(smest(:,3)-thd)==min(abs(smest(:,3)-thd)));
        plot(smest(index(1),3),smest(index(1),2),'*r');
        %
        figure(fig2);
        tmpflag = zeros(numel(mslip),2);
        for nii=1:numel(mslip)
            cslip = mslip{nii};
            for nk=1:numel(trif)
                trif(nk).ss = cslip(nk);
                trif(nk).ds = cslip(nk+numel(trif));
            end
            tmpflag(nii,1) = smest(nii,1);
            [~,~,mw] = sim_trif2moment(trif);
            tmpflag(nii,2) = mw;
        end
        hold on
        plot(tmpflag(:,1),tmpflag(:,2),'o-r');
        %%%%%
        figure(fig3);
        plot(input(:,3),'-r','LineWidth',2.5);
        hold on
        plot(osim{index(1)},'-b','LineWidth',1.0);
        corr(osim{index(1)},input(:,3))
        legend('OBS','SIM');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tmposim = osim{index(1)};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %index
    cslip = mslip{index(1)};
    for nk=1:numel(trif)
        trif(nk).ss = cslip(nk);
        trif(nk).ds = cslip(nk+numel(trif));
    end
    % index
    outflag(ni,1) = index(1);
    % std,obs-sim
    outflag(ni,2) = smest(index(1),2);
    % smooth
    outflag(ni,3) = smest(index(1),3);
    % dip
    outflag(ni,5) = smest(index(1),5);
    % mw
    [~,~,mw]      = sim_trif2moment(trif);
    outflag(ni,6) = mw;
    besttrif{ni}  = trif;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oindex = find(outflag(:,6)==min(outflag(:,6)));
if nargin < 2 || isempty(cdip)==1
   cdip   = outflag(oindex(1),5);
end
iindex    = find(outflag(:,5)==cdip);
trif      = besttrif{iindex(1)};
%disp(outflag);
%disp(iindex);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isplot == 1
   figure('Name','Dip && Mw');
   plot(outflag(:,5),outflag(:,6),'o-r');
   hold on
   plot(outflag(oindex(1),5),outflag(oindex(1),6),'dk');
   plot(outflag(iindex(1),5),outflag(iindex(1),6),'*g');
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   figure('Name','Dip && STD');
   plot(outflag(:,5),outflag(:,2),'o-r');
   hold on
   plot(outflag(oindex(1),5),outflag(oindex(1),2),'dk');
   plot(outflag(iindex(1),5),outflag(iindex(1),2),'*g');
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   figure('Name','Trif Model in 3D');
   sim_trifshow(trif,'syn');
end
