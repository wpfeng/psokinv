function psokinv_quickuncertainty(incfg,nsets)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% New version for uncertainty estimation of fault geometry parameters...
% by FWP,@GU, 2014-05-18
%%% 
if nargin < 1
    incfg = 'psokinv_08mw63_s.cfg';
end
if nargin < 2
    nsets = 100;
end
%
%
[psoPS,insfile,forms,outoksar,abccof,outmatf,fpara,...
          lamda,myu,scamin,scamax,InV,locals,weights,vcms,...
          ntimes,iterations,display,itersSIM,ismc,mcloops,...
          mcdir,mcsave,fismc,disofparts,rake_value,rake_isinv,isvcm,outrakeinfo,mwcoinfo] = ...
          sim_readconfig(incfg);
      
%
%
[~,boksar,boksarext] = fileparts(outoksar{1}{1});
checkOksar = [mcsave{1}{1},'/',boksar,'_',num2str(ntimes),boksarext];
%
if exist(checkOksar,'file')
    fpara = sim_oksar2SIM(checkOksar);
    %
else
    disp(' You need run TopCfg now to determine parameters...');
    psokinv(incfg);
    %
    psokinv_quickuncertainty(incfg)
end
%
if ~exist(mcdir{1}{1},'dir')
    mkdir(mcdir{1}{1});
end
%
%
for ni = 1:numel(insfile)
    cfile            = insfile{ni}{1};
    [osim,~,~,input] = sim_checkinp(fpara,cfile,'fpara',0);
    rms              = sqrt((input(:,3)-osim).^2);
    % 
    [~,bname,bext] = fileparts(cfile);
    %
    for noset = 1:nsets
     cinput      = input;
     cinput(:,3) = (rand(numel(input(:,1)),1)-0.5).*2.*rms + input(:,3);
     outfile     = [mcdir{1}{1},'/',bname,'_MC_',num2str(noset),bext];
     %
     disp(outfile);
     sim_input2outfile(cinput,outfile);
    end
end
%
[~,bname,bext] = fileparts(incfg);
outcfg         = [bname,'_MC',bext];
info.ismc      = 1;
info.ntimes    = 3;
info.outoksar  = [boksar,'_MC',boksarext];
info.fismc     = [1,1];
%
sim_psokinvcfg_update(incfg,outcfg,info);

