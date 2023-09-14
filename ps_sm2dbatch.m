function ps_sm2dbatch
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
matlabpool open;
%
psokinv  = 'PSOKINV.cfg';
smcfg    = 'YS_SM.cfg';
Nofault1 = 1;
Nopara1  = 1;
rng1     = 230:5:300;
Nofault2 = 1;
Nopara2  = 2;
rng2     = 3660:1:3670;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info        = sim_getsmcfg(smcfg);
[~,cfgname] = fileparts(smcfg);
%
[psoksardir,parname,ext1] = fileparts(info.unifmat);
[~,matname] = fileparts(info.unifmat);
fpara       = sim_psoksar2SIM(info.unifmat);
moutcfg     = cell(1);
counter     = 0;
for ni=1:numel(rng1)
    fpara(Nofault1,Nopara1) = rng1(ni);
    for nj=1:numel(rng2)
        counter = counter + 1;
        fpara(Nofault2,Nopara2) = rng2(nj);
        nfpara = [psoksardir,'/',parname,'.',num2str(ni),'.',num2str(nj),ext1];
        sim_fpara2psoksar(fpara,nfpara);
        outmat = [matname,'.',num2str(ni),'.',num2str(nj),'.mat'];
        outcfg = [cfgname,'.',num2str(ni),'.',num2str(nj),'.cfg'];
        sim_smcfg(outcfg,nfpara,info.unifinp,...
                  info.unifwid,info.uniflen,...
                  outmat,info.unifwsize,info.uniflsize,...
                  info.unifsmps,info.bdconts,info.minscale);
        %disp(['Now Begin NO:', num2str(ni),'.',num2str(nj),' linear spare solution...']);
        %ps_smest(outcfg);
        moutcfg{counter} = outcfg;
    end
end
parfor ni = 1:counter
    ps_smest(moutcfg{ni});
end
matlabpool close;
