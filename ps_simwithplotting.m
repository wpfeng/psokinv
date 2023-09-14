function ps_simwithplotting(simcfg,varargin)
%
%  
% New version for calculating simulation and residuals of Phase...
%
% Developed by Feng,W.P.,@ YJ, 2015-05-06
% Updated by Feng, W.P., @NRCan, 2015-10-14
% -> make it available for layered earth structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    disp('ps_simwithplotting(simcfg,varargin);');
    return
end
%
postfix      = 'Chile1509';
% 
mediamodel   = 'ELA';
greendir     = 'PSGRN';
jumpline     = 1;
ismaskzero   = 1;
outpixelsize = 0.001;
gmt_minwrap  = -0.1;  % m in default
gmt_maxwrap  =  0.1;  % m in default
simlmodel    = 'MO';  % or LBL, line by line
mode         = [];
enu          = [];
gmt_iswrap   = 1;
gmt_unit     = '(m)';
isdelete     = 1;
gmt_faulttop = [];
gmt_issyn    = 1;
gmt_mul      = [];
gmt_scale    = 1;
gmt_axstep   = '1';
gmt_aystep   = '1';
gmt_demgrd   = sar_dempath('global');
%
for ni =1:2:numel(varargin)
    %
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[t_mp,bname] = fileparts(simcfg);
if ~exist(bname,'dir')
    mkdir(bname);
end
%
cd(bname);
%
if isempty(enu)
    %
    enu = psokinv_simglobal(['../',simcfg],...
        'ispara',         0,...
        'greendir',       greendir,...
        'media_model',    mediamodel,...
        'simulation',     simlmodel,...
        'jumpline',       jumpline,...
        'outpixelsize',   outpixelsize);
end
%
siminfo    = sim_getsimcfg(['../',simcfg]);  
if isempty(mode)
    mode = siminfo.synmodel;
end
%
if gmt_issyn == 1
    %
    for ni = 1:numel(siminfo.unwf)
        %
        sar_phs2resfromenu(siminfo.unwf{ni},...
            enu{1},...
            enu{2},...
            enu{3},...
            'isdelete',     isdelete,...
            'gmt_unit',     gmt_unit,...
            'gmt_iswrap',   gmt_iswrap,...
            'mode',         mode,...
            'postfix',      postfix,...
            'gmt_minwrap',  gmt_minwrap,...
            'gmt_maxwrap',  gmt_maxwrap,...
            'gmt_faulttop', gmt_faulttop,...
            'gmt_mul',      gmt_mul,...
            'gmt_scale',    gmt_scale,...
            'gmt_axstep',   gmt_axstep,...
            'gmt_aystep',   gmt_aystep,...
            'ismaskzero',   ismaskzero,...
            'gmt_demgrd',   gmt_demgrd,...
            'ininc',        siminfo.incf{ni},...
            'inazi',        siminfo.azif{ni});
    end
end
%
cd ..
