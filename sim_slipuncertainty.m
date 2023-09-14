function fpara = sim_dsmmc_v2()
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% an rough version, Working for distributed slip uncertainty 
% Created by Feng, Wanpeng, 2010-05-04
% fengwp@cea-igp.ac.cn
% to calculate stddev properly, Z. Li, 17 Oct 2010
%
matlabpool open 5;
%addpath('/home/wfeng/psokinv_v2.1');
addpath('/home/zhli/usr_zhli/GeodeticInversion/PSOKINV_V2.1');
%smcfg = 'psokinv_SM_2Interf_3Fault_PSOKINV_RBv6_MC_DIP60.cfg';
smcfg = 'psokinv_SM_3Fault_3Interf_RB_V5d2_1km_NoOverlap.inp';
inps  = {'P487A','T498A', 'T004D'};
perts = 'perts';
niter = 500; % maximum iterations or monte carlo random data sets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please don't change any lines as followed...
%
%finps = inps;
scfg  = sim_getsmcfg(smcfg);
outmat  = scfg.unifouts;
[~,tmp] = fileparts(outmat);
[~,in]  = fileparts(tmp);
[~,unboot] = fileparts(scfg.unifinp);
[~,smboot] = fileparts(smcfg);
disp(unboot)
parfor ni=1:niter
  finps = cell(3,1);
  for nj = 1:3
      finps{nj} = [perts '/' inps{nj} '_' num2str(ni) '.okinv'];
  end
  %
  cscfg = [unboot,'.',num2str(ni),'.cfg'];
  sim_invconfig(cscfg,3,1:1:3,[],...
                       finps,[],[],[],[],...
                       [],[],[],[],...
                       [],[],[],[],[],[],[],[]);
  outmat  = [in,'.NO',num2str(ni),'.mat'];
  %disp('FENG testing...');
  sim_smcfg([smboot,'.',num2str(ni),'.cfg'],scfg.unifmat,cscfg,...
            scfg.unifwid,scfg.uniflen,...
            outmat,scfg.unifwsize,scfg.uniflsize,...
            scfg.unifsmps,scfg.bdconts,...
            scfg.minscale);
  %
  ps_smest([smboot,'.',num2str(ni),'.cfg']);
end
%
[~,iname] = fileparts(smcfg);
mats = dir([iname,'.',num2str(1),'/',in,'.NO*.mat']);
for ni=1:niter
    mats(ni)   = dir([iname,'.',num2str(ni),'/',in,'.NO*.mat']);
end
size(mats)
dslip     = [];
sslip     = [];
for ni=1:size(mats,2)
    disp(['processing ', num2str(ni)]);
    disp([iname,'.',num2str(ni),'/',mats(ni).name]);
    fpara = sim_smgetre([iname,'.',num2str(ni),'/',mats(ni).name],[],0);
    dslip = [dslip;fpara(:,9)'];
    sslip = [sslip;fpara(:,8)'];
end

stddslip = [];
stdsslip = [];
for ni=1:size(dslip,2)
  stddslip = [stddslip; std(dslip(:,ni))];
  stdsslip = [stdsslip; std(sslip(:,ni))];
end
fpara(:,8) = stdsslip;
fpara(:,9) = stddslip;

save slip_uncertainty.mat fpara;
matlabpool close;
