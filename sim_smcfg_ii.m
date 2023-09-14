function sim_smcfg_ii(instrcut,varargin)
%
%
% sim_smcfg_ii(instruct,varargin)
% Creat a configure file for ps_smest from a matlab structure
% This function will be much useful if we plan to update some of parameters...
%
% Developed by Feng, W.P., @ Yj, 2015-05-27
% Updated by Feng, W.P., @NRCan, 2015-10-11
%   -> grid searcing for optimal geometric parameters available for layered
%      crust structure...
%
if nargin < 1
    disp('sim_smcfg_ii(instrcut,varargin)');
    return
end
%
outnames    = 'psokinvSM.cfg';
unifmat     = 'psoksar.mat';
unifinp     = 'PSOKINV.cfg';
unifwid     = 20;
uniflen     = 20;
unifouts    = 'SMEST.mat';
unifwsize   = 1;
uniflsize   = 1;
unifsmps    = [0.1,1,0.2];
nf          = 1;
bdconts     = [0,0,1,0];
minscale    = 0;
rakecons    = [0,0,0];
inputmodel  = 'NULL';
%
abicang             = [0,0,0,0,0];
listmodel           = zeros(1,4);
smoothing           = 1;            % smoothing matrix rebuilding...
xyzindex            = {1};
extendingtype       = 'w';
maxvalue            = 100000;
mcdir               = 'NULL';
dampingfactor       = 1.0;
earthmodel          = 'ELA';
fixindex            = [0,1,2];
refinesize          = 0;
thresholdoksar      = [];
topdepth            = '0';
isuncertainty       = 0;
istri               = 0;
isfix               = 0;
layeredfold         = '';
indist              = 'NULL';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deliver value from the given structure variable...
% by Feng, W.P., @ Yj, 2015-05-27
%
paras = fieldnames(instrcut);
%
for ni = 1:numel(paras)
    par = paras{ni};
    val = getfield(instrcut,par);  %#ok<GFLD>
    eval([par,'=val;']);
end
%
% Reset value again 
%
for ni = 1:2:numel(varargin)
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
fid = fopen(outnames,'w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Feng, W.P, Now the code supports OKSAR format...
% 20110415
fprintf(fid,'%s\n','# Uniform Model MAT ,OKSAR or PSOKSAR');              % the uniform fault model in matlab mat format
fprintf(fid,'%s\n',unifmat);
fprintf(fid,'%s\n','# Uniform Inversion CFG');                            % the configure file when uniform model inversion.
fprintf(fid,'%s\n',unifinp);
fprintf(fid,'%s\n','# Distributed Model WIDTH(km)');                      % the width size   (km), when multiple faults, the width will be n*1.
if isnumeric(unifwid)
    unifwid = num2str(unifwid);
end
fprintf(fid,'%s\n',unifwid);
fprintf(fid,'%s\n','# Distributed Model LENGTH(km)');                     % the length size (km), the same with obve.
if isnumeric(uniflen)
    uniflen = num2str(uniflen);
end
fprintf(fid,'%s\n',uniflen);
fprintf(fid,'%s\n','# Distributed Model PatchSize(W)');  % same with obove
%
if isnumeric(unifwsize)
    unifwsize = num2str(unifwsize);
end
fprintf(fid,'%s\n',unifwsize);
fprintf(fid,'%s\n','# Distributed Model PatchSize(L)');  % same with length
if isnumeric(uniflsize)
    uniflsize = num2str(uniflsize);
end
fprintf(fid,'%s\n',uniflsize);
fprintf(fid,'%s\n','# Distributed Model Topdepth(km)');  % the length size (km), the same with obve.
if isnumeric(topdepth)
    topdepth = topdepth(:)';
    topdepth = num2str(topdepth);
end
fprintf(fid,'%s\n',topdepth);
fprintf(fid,'%s\n','# Smoothing Parameter');       % you must give three
if isnumeric(unifsmps)
    unifsmps = num2str(unifsmps);
end
fprintf(fid,'%s\n',unifsmps);
fprintf(fid,'%s\n','# ABIC to estimation of DIP angles: e.g, nofault,nopara,minv,step,maxv');
%
if ischar(abicang)
    fprintf(fid,'%s\n',abicang);
else
    fprintf(fid,'%s\n',num2str(abicang));
end
%
fprintf(fid,'%s\n','# Boundary zero constraints: default, R L U B; 0 Yes,1 No');
if isnumeric(bdconts)
    bdconts = num2str(bdconts);
end
fprintf(fid,'%s\n',bdconts);
%
fprintf(fid,'%s\n','# Depth-dependent patchsize (damping factor)');
if isnumeric(dampingfactor)
    dampingfactor = num2str(dampingfactor);
end
fprintf(fid,'%s\n',dampingfactor);
%
%Added by Feng W.P., @UoG, 2014-07-17
fprintf(fid,'%s\n','# Refine the Patch Size based on the Sensitivity Analysis');
if isnumeric(refinesize)
    refinesize = num2str(refinesize);
end
fprintf(fid,'%s\n', refinesize);
% 
fprintf(fid,'%s\n','# If we adopt triangular dislocation model...');
if isnumeric(istri)
    istri = num2str(istri);
end
fprintf(fid,'%s\n',istri);
% issensitiveanalysis
fprintf(fid,'%s\n','# Sensitivity analysis for smoothing');
if isnumeric(smoothing)
    smoothing = num2str(smoothing);
end
fprintf(fid,'%s\n',smoothing);
%
fprintf(fid,'%s\n','# Earth model: Elastic half-space(ELA) or layered(LAY)...');
fprintf(fid,'%s\n',[earthmodel,' ',layeredfold]);
%
fprintf(fid,'%s\n','# Reference columns for smoothing constraints->[1,2],[1,5],or,[2,5]');
%
for nkk = 1:numel(xyzindex)
    cindex = xyzindex{nkk};
    cstring = num2str(cindex(:)');
    fprintf(fid,'%s\n',cstring);
end
%fprintf(fid,'%s\n','1');
%
fprintf(fid,'%s\n','# the extending type: w,d or foc');
fprintf(fid,'%s\n',extendingtype);
fprintf(fid,'%s\n','# the boundary for maxima slip over the fault plane ');
%
if isnumeric(maxvalue)
    maxvalue = num2str(maxvalue);
end
fprintf(fid,'%s\n',maxvalue);
fprintf(fid,'%s\n','# the model resolution determination by Monte Carlo analysis ');
fprintf(fid,'%s\n',mcdir);
fprintf(fid,'%s\n','# Slip uncertainty estimated by the Monte-Carlo Method based on the RMS  ');
if isnumeric(isuncertainty)
    isuncertainty = num2str(isuncertainty);
end
fprintf(fid,'%s\n',isuncertainty);
%
fprintf(fid,'%s\n','# Slip Inversion bound Constraints, an Oksar file or NULL ');
if isempty(thresholdoksar)
    thresholdoksar = 'NULL';
end
%
fprintf(fid,'%s\n',thresholdoksar);
%
%
fprintf(fid,'%s\n','# a listric fault modeling...');
if numel(listmodel) < 4
    a                     = zeros(1,4);
    a(1:numel(listmodel)) = listmodel;
    listmodel             = a;
end
%
fprintf(fid,'%d %d %d %d\n',listmodel(1:4));
fprintf(fid,'%s\n','# Fixed model type: Flag (0/1);index1,index2');
%
if iscell(fixindex)
    coutstr = [];
    for ni = 1:numel(fixindex)
        if ni == 1
            coutstr = num2str(fixindex{ni}');
        else
            coutstr = [coutstr,',',num2str(fixindex{ni}')];
        end
    end
    oustr = [num2str(isfix),';',coutstr];
else
    oustr = [num2str(isfix),';',num2str(fixindex(:)')];
end
%
fprintf(fid,'%s\n',oustr);
% Specify a given distributed geometry model
% updated by Wanpeng Feng, @Ottawa, 2016-11-06
%
fprintf(fid,'%s\n','# Specify the discretized subfaults, for example, a .simp');
fprintf(fid,'%s\n',indist);
fprintf(fid,'%s\n','# Minumn Moment Scale Wight Parameter');
if isnumeric(minscale)
    minscale = num2str(minscale);
end
fprintf(fid,'%s\n',minscale);
fprintf(fid,'%s\n','# If we constrain the rake angle in DSM inversion ... ');
for ni = 1:size(rakecons,1)
    fprintf(fid,'%s\n',num2str(rakecons(ni,:),'%d %d %d\n'));
end
fprintf(fid,'%s\n','# Minumn Moment Scale Wight Parameter');
if isnumeric(minscale)
    minscale = num2str(minscale);
end
fprintf(fid,'%s\n',minscale);
fprintf(fid,'%s\n','# Output Result');
fprintf(fid,'%s\n',unifouts);
%
fclose(fid);




