function ps_bestdipstrike(cfg)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% batch_best_parameters estimation by Iterations.
% latest modified by Feng, W.P, 20110422, working for NZ inversion
% latest modified by Feng, W.P, 20110427, fixed a bug because of oksar
% 
% Modification:
%   by Feng,W.P., to estimate optimal strike and dip angles by iterations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    cfg    = 'psokinv_SM_2tracks_RB.cfg';
    cfg    = 'ps_sm_unif_2track.cfg';
end
info   = sim_getsmcfg(cfg);
step1  = 20;             % working for dip and strike
step2  = 2;              % working for x and y
pindex = {[3,4]};      % index of parameters, 1-x,2-y,3-strike,4-dip
findex = [1];            %[1,2,3,4,5,6]  ;          % index of faults
prec   = 10;             %
index  = [];      % 
threshold    = 0.25;     %
isjoint      = 1;        % From 3 to end segment, there is a curve plane
maxiteration = 1;       % the number of interation 
lenchanges   = 1;        % if change the lenght of faults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please don't change any codes below
[pathcfg,ncfg]      = fileparts(cfg);
[pathpsoksar,bname] = fileparts(info.unifmat);
[~,outname]         = fileparts(info.unifouts);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% modified by Feng, 20110422, add OKSAR support
[~,~,ext] = fileparts(info.unifmat);
%
if strcmpi(ext,'.OKSAR')
    fpara  = sim_oksar2SIM(info.unifmat);
else
    if strcmpi(ext,'.PSOKSAR')
        fpara  = sim_psoksar2SIM(info.unifmat);
    else
        dt     = load(info.unifmat);
        fpara  = dt.fpara;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ni=60:1:80
    for nj=80:1:100
        outcfg      = fullfile(pathcfg,[ncfg,'_',num2str(ni),'_',num2str(nj),'.cfg']);
        inpsoksar   = fullfile(pathpsoksar,[bname,'_',num2str(ni),'_',num2str(nj),'.oksar']);
        %types       = zeros(size(fpara,1),1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tfpara     = fpara;
        tfpara(1,3)= ni;
        tfpara(1,4)= nj;
        sim_fpara2oksar(tfpara,inpsoksar);
        if nj >= 3
            abic    = [0,nj,0,0,0];
        else
            abic    = [0,nj,0,0,0];
        end
        outmat      = [outname,'_',num2str(ni),'_',num2str(nj),'_Iter.mat'];
        sim_smcfg(outcfg,inpsoksar,info.unifinp,   info.unifwid,   info.uniflen,...
            outmat,          info.unifwsize, info.uniflsize, info.unifsmps,...
            info.bdconts,...
            info.minscale,num2str(info.rakecons),num2str(abic));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ps_smest(outcfg,isjoint);
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %disp(['No ',num2str(ni),'-',num2str(nj),': Finished with COR&&STD of ',num2str([corcof,stdv])]);
    end
end
end

