% v2
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% An rough version, to estimate uncertainty of the distributed slip resulting from the observations errors
%
% Created by Feng, Wanpeng, 2010-05-04
% wanpeng.feng@hotmail.com
%
% Updated version @ GU, 2013-06-30
% Updated by FWP, @GU, 2014-01-20
%
% ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sar_matlabparallel;
%
smcfg    = 'psokinvSM_csk_azi_v2.cfg';  %
smcfg    = 'psokinvSM_20140120_mc.cfg'; %
topoutmat= 'tk_dsmmc_2datasets.mc.mat'; %

outsmcfg = 'TK_dsmmc_20130630.cfg';     %
perts    = 'pert';                      %
niter    =  100;                        % maximum iterations or monte carlo random data sets
nfaults  = 1;                           %
clocals  = 7;                           %
[~,outdir] = fileparts(outsmcfg);
topoutmat  = [outdir,'/',topoutmat];
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please don't change any lines as followed...
%
scfg       = sim_getsmcfg(smcfg);
[input,am,inps,vcm,intabc,mweight] = ...
           sim_sminpudata(scfg.unifinp);
%
outmat     = scfg.unifouts;
[~,tmp]    = fileparts(outmat);
[~,in]     = fileparts(tmp);
[~,smbcfg] = fileparts(smcfg);
[~,bcfg]   = fileparts(scfg.unifinp);
%
for ni = 1:niter
  %
  finps = cell(numel(inps),1);
  for nj = 1:numel(inps)
      [~,bname,ext] = fileparts(inps{nj}{1});
      finps{nj} = [perts '/MC_' num2str(ni),'_', bname ext];
  end
  %
  inpscfg = [bcfg,'_',num2str(ni),'.cfg'];
  %
  intabc(:,4) = mweight(:);
  intabc(:,1) = intabc(:,2);
  %
  sim_invconfig(inpscfg,nfaults,clocals,[],...
                       finps,[],[],[],[],...
                       [],[],[],[],...
                       [],[],[],[],[],[],intabc,[]);
  outmat  = [in,'.NO',num2str(ni),'.mat'];
  %
  sim_smcfg(outsmcfg,scfg.unifmat,inpscfg,...
            scfg.unifwid,scfg.uniflen,...
            outmat,scfg.unifwsize,scfg.uniflsize,...
            scfg.unifsmps,scfg.bdconts,...
            scfg.minscale,scfg.rakecons,...
            scfg.abicang,scfg.listmodel,scfg.smoothing,...
            scfg.xyzindex,scfg.extendingtype,scfg.maxvalue,scfg.mcdir,...
            scfg.dampingfactor,scfg.earthmodel,[scfg.isfix,cell2mat(scfg.fixindex)]);
  %
  [~,bdir] = fileparts(outsmcfg);
  if exist(fullfile(bdir,outmat),'file')
      disp([' DSMEST: ' outmat ' is done. Jump for next...']);
  else
      %
      disp([' DSMEST: ' outmat ' starts...']);
      ps_smest(outsmcfg);
      disp([' DSMEST: ' outmat ' has been done...']);
  end
end
%
%
mats      = dir(fullfile(bdir,[in,'.NO*.mat']));
dslip     = [];
sslip     = [];
for ni=1:numel(mats)
    fpara = sim_smgetre(fullfile(bdir,mats(ni).name),[],3);
    dslip = [dslip;fpara(:,9)'];
    sslip = [sslip;fpara(:,8)'];
end
stdstr     = std(sslip);
stddip     = std(dslip);
fpara(:,8) = stdstr(:);
fpara(:,9) = stddip(:);
%
save(topoutmat,'fpara');
matlabpool close;
