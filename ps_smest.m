function ps_smest(cfgfile,varargin)
%
%
% Name+:
%      ps_smest, distributed Slip model estimation...
% Purpose:
%      to estimate the distributed slip model
% Input:
%      cfgfile, the configure file, necessary to work correctly.
%      varargin:
%        typejoint, if there are more one fault patch,(different strike),
%                   then this keyword will tell you if the tow parts join
%                   together.
%        invalg,  the algorithm for linear least-square problem.
%                 "cgls", "bvls","nnls" or "lsqlin"
%
%*********************************************
% Created by Feng, W.P, IGP-CEA, JULY, 2009
% Added log information by Feng, W.P, 25 Aug 2009, in Holand Airport.
%*********************************************
% Improved by Feng W.P, Now the program will save the G matrix for deep
% analysis...
% -> 2010-05-01,IGP-CEA, in Beijing, China
%*********************************************
%       0 for NONE ABC estimation
% -> 2010-07-14,IGP-CEA, in Beijing, China
%  add a new choice for linear least-square problem.
%  now the code supports three algorithms for linear problem...
%*********************************************
% -> by Feng, W.P, 2010-10-13,in Beijing, China
%   tidy up the header info of the function
%*********************************************
% -> by Feng, W.P, 2011-04-15,@ BJ, China
%    now package supports OKSAR format of fault models...
%    version has been updated to v3.0
%*********************************************
% -> Updated by Feng,W.P., 2012-09-27, @ Glasgow,
%    the constraints of rake angles can be changed all time and the green
%    matrix don't need change unless the geometry parameters don't.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global isjoint cfgname cfgpath xyzindex invmethod rakecons extendingtype ...
    vcmtype earthmodel Grakecons version utmzone globalinfo listmodel isokada3d....
    smoothingfact maxvalue mcdir dampingfactor isfix fixindex smcfg isrefine isopening ...
    smoothingmodel

version = 5.0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 1 || isempty(cfgfile) == 1 || exist(cfgfile,'file') == 0
    disp('Usage: ps_smest(smcfg,varargin)');
    disp('  ');
    disp('Parameters could be used below:');
    disp('    smcfg, the configure file for slip distribution estimation');
    disp('    varargin:');
    disp('      invalg, the algorithm for linear problem. can be nnsl,cgls,bvls and lsqlin');
    disp('      typejoint, 0 or 1 for smoothing constraints type.');
    disp('      inpvcmtype, the type of weight matrix definition');
    disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
    disp('    Latest modifed by Feng,W.P.,@ GU , 2012-09-27');
    disp('    Latest modifed by Feng,W.P.,@ GU , 2013-03-03');
    disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
typejoint  = 0;
invalg     = 'cgls';     % ls algorithm: bvls, cgls,nnls or lsqlin...
%
% seems that BVLS could make hight chance to
% retrieve the 'real' value... Changed by FWP, @UoG, 2013-03-30
% 
% change back to "cgls", @IGPP of SIO, UCSD, 2013-10-24
% 
inpvcmtype = 'cov';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ni=1:2:numel(varargin)
    %
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
    %
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vcmtype       = inpvcmtype;
%%%
isjoint       = typejoint;
invmethod     = invalg;
sminfo        = sim_getsmcfg(cfgfile);
globalinfo    = sminfo;
xyzindex      = sminfo.xyzindex;
smoothingfact = sminfo.smoothing;
smoothingmodel= sminfo.smoothingmodel;
mcdir         = sminfo.mcdir;
isfix         = sminfo.isfix;
fixindex      = sminfo.fixindex;
smcfg         = cfgfile;
isrefine      = sminfo.refinesize;
isopening     = sminfo.isopening;
isokada3d     = sminfo.isokada3d;
%
if isfield(sminfo,'earthmodel')
    earthmodel = sminfo.earthmodel;
else
    earthmodel = 'ELA';
end
%
%
% Updated by FWP, @ GU, 2013-03-25
if isfield(sminfo,'listmodel')==0
    sminfo.listmodel = [0,0,0,0];
end
listmodel = sminfo.listmodel;
%
matfile  = sminfo.unifmat;
maxvalue = sminfo.maxvalue;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ++ update utm zone from inp input
tzone         = []; % update utm zone from inp file
[t_mp,cinput] = sim_readconfig(sminfo.unifinp);
%
for ni = 1:numel(cinput)
    %
    czone = sim_inp2uzone(cinput{ni}{1});
    if isempty(czone)==0
        tzone = czone;
    end
end
utmzone = tzone;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(sminfo.indist)
if ~exist(matfile,'file') && strcmpi(sminfo.indist,'NULL')
    disp(['ps_smest: Sorry for not finding the input fault model ', matfile]);
    disp('           Please check the fullpath of the given file. Then run again!');
    return
end
%
if ~strcmpi(sminfo.indist,'NULL')
    tfpara = sim_openfault(sminfo.indist);
    tfpara = tfpara(1,:);
    %
else
    [t_mp,t_mp,ext] = fileparts(matfile);
    if strcmpi('.MAT',ext)==1
        matpara = load(matfile);
        tfpara  = matpara.outfpara{1};
    else
        % Modified by Feng, Wanpeng, 20110415
        % now support OKSAR format based on the POSTFIX
        %
        [t_mp,t_mp,postfix] = fileparts(matfile);
        tfpara = sim_openfault(matfile);
        %
    end
end
%
nf                = numel(tfpara(:,1));
%
[cfgpath,cfgname] = fileparts(cfgfile);
rakecons          = sminfo.rakecons;
Grakecons         = rakecons;
dampingfactor     = sminfo.dampingfactor;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sminfo.abicang(1) == 0
    %
    mdip = [1,4,tfpara(1,4),4];
else
    abicv= sminfo.abicang; 
    if numel(abicv) ~= 5
       %
       % add error-handling by Feng, W.P., @BJ, 2015-02-03
       %
       disp(' *************************  PSOKINV  ****************************');
       disp(' Please check given value of ABIC. There is no enough input for inversion.');
       disp(' ABIC should include <flag> <no-para> <start-value> <step> <end-value> ')
       disp(' ************************* TERMINATED ****************************');
       return
    end
    %
    angs = sminfo.abicang(3):sminfo.abicang(4):sminfo.abicang(5);
    mdip = zeros(numel(angs),1);
    mdip(:,1) = sminfo.abicang(1);
    mdip(:,2) = sminfo.abicang(2);
    mdip(:,3) = angs(:);
end
%sminfo
extendingtype = sminfo.extendingtype;
outmat  = sminfo.unifouts;
inf     = sminfo.unifinp;
swid    = textscan(sminfo.unifwid,'%f',nf);
wid     = swid{1};
slen    = textscan(sminfo.uniflen,'%f',nf);
len     = slen{1};
spx     = textscan(sminfo.uniflsize,'%f',nf);
px      = spx{1};
spy     = textscan(sminfo.unifwsize,'%f',nf);
py      = spy{1};
tmp     = textscan(sminfo.unifsmps,'%f');
%
% Updated by FWP,@GU, 2014-08-22
%
if ~isnumeric(sminfo.topdepth)
    if ~isempty(sminfo.topdepth)
        topdepth = textscan(sminfo.topdepth,'%f');
        topdepth = topdepth{1};
    else
        topdepth = len.*0;
    end
else
    topdepth = sminfo.topdepth;
end
%
%
%
alpha   = tmp{1};
alpha   = alpha';
if numel(alpha)<3
    disp(['PS_SMEST-> alpha(smoothing parameter) : ' num2str(alpha(1)) ' is accepted for smoothing constraints']);
    alpha = [alpha(1),alpha(1),alpha(1)];
end
%
minscale= str2double(sminfo.minscale);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bnds    = textscan(sminfo.bdconts,'%f',nf*4);
bnds    = bnds{1};
%
% Updated by fWP, @UoG, 2014-05-16
% to avoid error when fixmodel is available
if isfix == 1
    nf = numel(fixindex);
    bnds    = reshape(bnds(1:4*nf),4,nf);
else
    %
    num_elements = size(bnds,1);
    expected_num = 4 * nf;
    if num_elements < expected_num
       disp(' ps_smest: ERROR. No enough boundary constraint settings...');
       return 
    end
    bnds    = reshape(bnds,4,nf);
end

%
bdconts = cell(1);
txt     = {'L','R','U','B'};
bdcontsc= cell(1);
%
% updated by fWP, @IGPP of SIO, UCSD, 2013-10-10
%
for nof=1:nf
    nbound = 0;
    for ni = 1:4
        flag = bnds(ni,nof);
        if flag ==1
            nbound      = nbound+1;
            bdconts{nbound} = txt{ni};
        end
    end
    if nbound == 0
        bdconts = [];
    end
    bdcontsc{nof} = bdconts;
    bdconts       = [];
    a = bdcontsc{nof};
    b = a;
    if numel(a)>0;
        for ni=1:numel(a)
            if strcmp(a{ni},'B')==1
                b{ni} = 'B';
            end
            if strcmp(a{ni},'U')==1
                b{ni} = 'U';
            end
        end
    end
    disp('*************************************************************');
    disp(['**************** Welcome to use PS_SMESTv',num2str(version),' ****************']);
    disp('*************************************************************');
    %
    if isfix==1
        disp(['The NO:' num2str(nof) ' set of fault with boudary constrain in FIX Mode->']);
    else
        disp(['The NO:' num2str(nof) ' fault with boudary constraint with normal dividing mode->']);
    end
    %
    if size(b,2)>0
        for nb=1:size(b,2)
            if strcmpi(b{nb},'U')
                b{nb} = 'PS_SMEST-> The Upside    will not be constraint with ZEROS.!';
            end
            if strcmpi(b{nb},'B')
                b{nb} = 'PS_SMEST-> The Bottom    will not be constraint with ZEROS.!';
            end
            if strcmpi(b{nb},'L')
                b{nb} = 'PS_SMEST-> The LeftSide  will not be constraint with ZEROS.!';
            end
            if strcmpi(b{nb},'R')
                b{nb} = 'PS_SMEST-> The RightSide will not be constraint with ZEROS.!';
            end
            disp(b{nb});
        end
    end
end
%
if exist(inf,'file')==0
    disp(['The uniform inf file,' inf ', is not found.']);
    return
end
m  = [];
dm = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[outdir,outname,ext] = fileparts(outmat);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sminfo.istri==0
    %
    [smest disf dismodel cinput isabc abc osim input mabicre,slipuncertainty] = sim_smest(matfile,inf,alpha,px,py,len,wid,topdepth,minscale,bdcontsc,mdip);%;
    %
else
    [msmest trif input] = sim_trismest(matfile,inf,alpha,px,py,len,wid,minscale,bdcontsc,mdip);%;
    [t_mp,basen]        = fileparts(cfgname);
    savedir             = [basen,'_TRIF'];
    eval(['save ' savedir '/' outmat ' utmzone topdepth version invmethod msmest trif input']);
    disp(['PS_SMEST(trif)-> ' savedir '/' outmat ' has been created. You can check it now!']);
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lamda     = smest(:,1);
std       = smest(:,2);
roughness = smest(:,3);
[a,bname] = fileparts(outmat);
%
outmat    = [outname,ext];
disp(['Now the result have been saved into ' [cfgname,'/',outmat] '!']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eval(['save ' [cfgname,'/'] outmat ' utmzone rakecons version topdepth invmethod slipuncertainty lamda std roughness disf dismodel m dm cinput abc isabc osim input mabicre mdip']);
%
% updated by Feng, W.P., @ BJ, 2015-07-15
[fpara,abc] = sim_smgetre([cfgname,'/',outmat],[],3,[0.3,3]);
eval(['save ' [cfgname,'/'] outmat ' utmzone rakecons version topdepth invmethod slipuncertainty lamda fpara std roughness disf dismodel m dm cinput abc isabc osim input mabicre mdip']);
%matlabpool close;
