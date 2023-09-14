function ps_reestwithnewweights(searchprefix,varargin)
%
% Rerun Inversion by iterating data relative weights
% Developed by Feng, W.P., @NRCan, 2015-10-27
% Re-estimate slip model with an updated data weight for each dataset. 
% datadir can be different as defined in the original configure file.
%
%
if nargin < 1
    disp('ps_reestwithnewweights(searchprefix,varargin)');
    disp(' keyword: weights for new results')
    disp('          newmat  corresponding to new weights')
    disp(' Created by Wanpeng Feng, @CCRS/CCMEO/NRCan, 2015-10-27')
    disp(' Sorted by Feng, Wanpeng, @Ottawa, 2016-11-06')
    %
    return
end
%
cfgdir        = [];%                [pwd,'/'];%'/insar2/wafeng/Modelling/EQs/Nepal_201504/pSM_elas_1019dip_depth_Optv1/';
datadir       = [];%                [pwd,'/'];%'/insar2/wafeng/Modelling/EQs/Nepal_201504/';
weights       = [1,1,1,1,1,1];
senssmoothing = 1;
unifsmps      = 20;
newmat        = 'SMEST_GPS1.mat';
isuncertainty = [];
isupdate      = 0;
%
for ni = 1:2:numel(varargin)
    %
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
    %
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
cfgs = dir([searchprefix,'.cfg']);
%
for ni = 1:numel(cfgs)
    %
    info = sim_getsmcfg(cfgs(ni).name);
    %
    if ~isempty(datadir)
        %
        [t_mp,bname,bext] = fileparts(info.unifinp);
        info.unifinp      = [datadir,bname,bext];
    end
    %
    if ~isempty(cfgdir)
        [t_mp,bname,bext] = fileparts(info.unifmat);
        info.unifmat      = [cfgdir,bname,bext];
    end
    %
    if ~isempty(isuncertainty)
        info.isuncertainty = isuncertainty;
    end
    %
    info.unifouts     = newmat;
    info.smoothing    = senssmoothing;
    info.unifsmps     = unifsmps;
    sim_smcfg_ii(info,'outnames',cfgs(ni).name);
    %
    [t_mp,bname]      = fileparts(cfgs(ni).name);
    %
    if exist([bname,'/weight.info'],'file')
       %
       sim_updateweightsfile([bname,'/weight.info'],weights);
       %
    end
end
%
for ni = 1:numel(cfgs)
    %
    ps_smest(cfgs(ni).name);
end
%