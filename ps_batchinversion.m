function ps_batchinversion(cfg)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    cfg    = 'psokinv_SM_2tracks_RB.cfg';
end
info   = sim_getsmcfg(cfg);
step1  = 20;             % working for dip and strike
step2  = 2;              % working for x and y
pindex = {[4]};      % index of parameters, 1-x,2-y,3-strike,4-dip
findex = [2,3,4,5];            %[1,2,3,4,5,6]  ;          % index of faults
prec   = 10;             %
index  = [];      % 
threshold    = 0.1;     %
%isjoint      = 1;        % From 3 to end segment, there is a curve plane
maxiteration = 20;       % the number of interation 
lenchanges   = 1;        % if change the lenght of faults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please don't change any code below
% Make sure any line below is SAFE!!!!
% Be careful if you want to change any line!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pathcfg,ncfg]      = fileparts(cfg);
[pathpsoksar,bname] = fileparts(info.unifmat);
[~,outname]         = fileparts(info.unifouts);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
invcounter          = 0;
%
for niter = 1:maxiteration
    % the more high precision with more iteration
    step1 = step1/niter;
    step2 = step2/niter;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
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
    if size(fpara,2)~=10
       disp('PS_batchinversion: the fault parameters are so stranger, please check it firstly...');
       return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for nf = 1:numel(findex)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ni      = findex(nf);
        cpindex = pindex{nf};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for nk = 1:numel(cpindex)
            invcounter  = invcounter+1;
            nj          = cpindex(nk);
            outcfg      = fullfile(pathcfg,[ncfg,'_',num2str(ni),'_',num2str(nj),'.cfg']);
            inpsoksar   = fullfile(pathpsoksar,[bname,'_',num2str(ni),'_',num2str(nj),'.oksar']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(index)==0
                tfpara         = fpara(index,:);
                tfpara         = sim_fpara2cross(tfpara);
                lens           = round(tfpara(:,7)');
                clens          = info.uniflen;
                clens          = textscan(clens,'%f');
                clens          = clens{1};
                clens          = clens';
                clens(index)   = lens;
                if lenchanges ~= 0 
                   info.uniflen   = num2str(clens);
                end
                fpara(index,:) = tfpara;
            end
            % Now code has been modified because of the replacement of
            % psoksar by OKSAR, 2011-04-22,by Feng, W.P
            %
            sim_fpara2oksar(fpara,inpsoksar);
            if nj >= 3
                abic    = [ni,nj,fpara(ni,nj)-step1/2,step1/prec,fpara(ni,nj)+step1/2];
            else
                abic    = [ni,nj,fpara(ni,nj)-step2/2,step2/prec,fpara(ni,nj)+step2/2];
            end
            outmat      = [outname,'_',num2str(ni),'_',num2str(nj),'.mat'];
            sim_smcfg(outcfg,inpsoksar,info.unifinp,   info.unifwid,   info.uniflen,...
                     outmat,          info.unifwsize, info.uniflsize, info.unifsmps,...
                     info.bdconts,...
                     info.minscale,...
                     num2str(info.rakecons),...
                     num2str(abic),...
                     [],[],...
                     info.xyzindex);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ps_smest(outcfg,'invalg','cgls');
            routmat = [ncfg,'_',num2str(ni),'_',num2str(nj),'/',outmat];
            %
            [~,~,corcof,stdv,~,~,nvara] = sim_smgetre(routmat,[],3,threshold);
            if invcounter==1
                lastcor = corcof;
                laststd = stdv;
            end
            if lastcor <= corcof
               fpara(ni,nj) = nvara;
               lastcor = corcof;
               laststd = stdv;
            else
               corcof = lastcor;
               stdv   = laststd;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp(['No ',num2str(ni),'-',num2str(nj),': Finished with COR&&STD of ',num2str([corcof,stdv])]);
        end
    end
    % inpsoksar = fullfile(pathpsoksar,[bname,'.psoksar']);
    % modified by Feng, W.P, 201104027, now psokinv mainly use oksar, but
    % not psokisar.
    %
    sim_fpara2oksar(fpara,info.unifmat);
    disp(['Now No-> ' num2str(niter) ' inversion working is OK. The OKSAR file has been updated...']);
end
