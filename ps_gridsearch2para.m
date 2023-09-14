function ps_gridsearch2para(cfg,varargin)
%
% Estimate 2 parameters with a grid search method
%
% Developed by Feng, W.P., @ EOS of NTU in Singapore, 2015-06-20
%
% Updated by FEng, W.P., @NRCan, 2015-10-09
% -> redirect to a new file with a prefix, ps_
%
%
attri   = {'x','y','s','d','de'};
postfix = 'Optv1';
prefix  = 'psOPT_Nepal_';
index   = [4,5];
%
rng     = [2,1,18;...
           2,1,18];
isclean = 0;
%
if nargin < 1
    %
   disp('ps_gridsearch2para(cfg,varargin)');
   return
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ni = 1:2:numel(varargin)
    %
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
    %
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
info    = sim_getsmcfg(cfg);
%
objdir  = [prefix,attri{index(1)},'_',attri{index(2)},'_',postfix];
if ~exist(objdir,'dir')
    mkdir(objdir);
end
%
values     = rng(1,1):rng(1,2):rng(1,3);
coksar     = info.unifmat;
topdir     = pwd;
[t_mp,boksar] = fileparts(coksar);
%
testcfg = cell(1);
info.abicang = [1,index(2),rng(2,:)];
%
[t_mp,t_mp,bext] = fileparts(coksar);
%
for ni = 1:numel(values)
    %
    switch upper(bext)
        %
        case '.OKSAR'
          [fpara,zone] = sim_oksar2SIM(coksar);
        case '.SIMP'
          [fpara,zone] = sim_simp2fpara(coksar);
        otherwise
          disp('postfix cannot be identified. Please check again...');
          return
    end
    %
    if strcmpi(info.extendingtype,'foc')
        %
        cfpara           = sim_fparaconv(fpara,0,3);
        cfpara(index(1)) = values(ni);
        cfpara           = sim_fparaconv(cfpara,3,0);
        %
        outoksar         = [topdir,'/',objdir,'/',objdir,'_',attri{index(1)},num2str(values(ni)),'.oksar'];
        disp(outoksar);
        sim_fpara2oksar(cfpara,outoksar,zone);
        info.unifmat     = outoksar;
        %
    end
    testcfg{ni} = [topdir,'/',objdir,'/',objdir,'_',attri{index(1)},num2str(values(ni)),'.cfg'];
    sim_smcfg_ii(info,'outnames',testcfg{ni});
end
% 
cd(objdir);
for ni = 1:numel(testcfg)
    [t_mp,cdir] = fileparts(testcfg{ni});
    if isclean ~= 1
       %
       if ~exist([cdir,'/',info.unifouts],'file')
        ps_smest(testcfg{ni});
       end
       %
    else
       disp(pwd);
       findfolders = dir([cdir,'/psCMP*']);
       for nfold = 1:numel(findfolders)
           if findfolders(nfold).isdir==1
              disp(['deleting ',cdir,'/',findfolders(nfold).name]);
              system(['rm ',cdir,'/',findfolders(nfold).name,' -rf']);
           end
       end
    end
end
cd ..