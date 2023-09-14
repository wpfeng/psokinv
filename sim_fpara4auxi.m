function [wfpara,cellfpara,mrakecons] = sim_fpara4auxi(fpara,dx,dy,L,W,rakecons)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %%
 % + Purose:
 %   Calculate the auxiliary parameters to determine slip distribution 
 %
 % + Input:
 %   fpara,   a cell variable for n-segments uniform fault
 %      dx,   lengths for each patch in each segment
 %      dy,   widths for each patch in each segment
 %       L,   lengths for each segment
 %       W,   widths for each segment
 %
 % + Log:
 %  Created by Feng, W.P., @ GU, 2012-09-26
 %
 %%
 %
 global listmodel
 subf = size(fpara,1);
 if size(rakecons,1) == 0
     rakecons      = zeros(subf,3);
     rakecons(:,2) = 0;
     rakecons(:,3) = 90;
 end
 tmprakecons = [];
 %% ++ initialize the output, added by Feng,W.P.,@ GU, 2012-09-26
 %
 nf     = size(fpara,1);
 outfp  = cell(nf,1);
 wfpara = [];
 %%
 % modified by Feng, W.P, 
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
 %%
 for nof = 1:nf
    %
    tmp        = sim_fpara2whole(fpara(nof,:));
    % tem        = sim_fpara2dist(tmp,L(nof),W(nof),dx(nof),dy(nof));
    if listmodel(1) == 0
        tem = sim_fpara2dist(tmp,L(nof),W(nof),dx(nof),dy(nof));
    else
        switch listmodel(1)
            case 1
                tem = sim_fpara2dist_listric(tmp,W(nof),listmodel(2),L(nof),dx(nof),dx(nof),listmodel(3),'linear');
        end
    end
    outfp{nof} = tem;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    wfpara  = [wfpara;tem];
    numf    = size(tem,1);
    % update by feng,w.p., @ GU, 2012-09-26
    % add a new col for identify of fault...
    %
    curcons      = zeros(numf,4);
    curcons(:,1) = rakecons(nof,1);
    curcons(:,2) = rakecons(nof,2);
    curcons(:,3) = rakecons(nof,3);
    curcons(:,4) = nof;
    tmprakecons  = [tmprakecons;curcons];
 end    
 mrakecons = tmprakecons;
 %%
 cellfpara = outfp;
 
