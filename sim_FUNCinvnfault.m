function sim_FUNCinvnfault(invf)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%function sim_invnfault(invf,logfile)
%
% Purpose:
%       the main program of nonlinear inversion  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Varibles you must change based on your need.
% Logs:
%   Modified by Feng W.P, IGP-CEA, 2010-05-03
%       Normalized weights of the input data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cdir = cd();
%global UTMZONE
%
nowtime = datestr(now());
tic;
if nargin <1 || isempty(invf)==1
   disp('An input file should be specified...');
   disp('Usage: sim_FUNCinvnfault(invf)');
   return
end
%
%
global input fpara Inv index locals alpha symbols weighs cinput am wmatrix mvcm wVCM ...
       rake_value rake_isinv inv_VCM rakeinfo initialONE UTMZONE mwconinfo  ...
       WholeData obsunit mwall
%
iscov = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[psoPS,cinput,symbols,outoksar,abccof,outmatf,fpara,...
    lamda,myu,scamin,scamax,Inv,locals,weighs,vcms,...
    ntimes,iterations,display,simiters,a1,a2,a3,a4,a5,...
    disofparts,rake_value,rake_isinv,isvcm,rakeinfo,mwconinfo,...
    obsunit,mwall,UTMZONE] = sim_readconfig(invf);
%
%
% updated by FWP for a critical bug for multiple segments...
% 2013-06-14
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fpara
tzone  = []; % update utm zone from inp file
%
% Below few lines are Obsoluted by Wanpeng Feng since 2018-08-11, @SYSU
% Now we only allow to specify the utm zone in the configure file with a keyword
% # utmzone of displacements, e.g. 19Q
%
% for ni = 1:numel(cinput)
%     czone = sim_inp2uzone(cinput{ni}{1});
%     if isempty(czone)==0
%         tzone = czone;
%     end
% end
%
savedir = a4{1}{1};
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obsoleted by Feng, W.P., @ EOF of NTU, Singapore, 2015-06-25
% Modified by FWP, @UoG, 2014-03-13
%
% Updated by Wanpeng Feng, @CCRS/NRCan, Canada, 2017-04-27
% Utilize pre-determined fault models in the initial parameters...
%
if exist(savedir,'dir')==0
   mkdir(savedir);
end
%
alpha = lamda/(lamda+myu);
%
index = find(Inv==1);
npara = numel(index);
if npara==0
   disp('There is no parameter to be inverted...');
   return
end
scale      = zeros(npara,2);
scale(:,1) = scamin(index);
scale(:,2) = scamax(index);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%whos Inv
if exist('initialONE.inp','file')~=0
   initialONE  = load('initialONE.inp');
else
   initialONE = rand.*(scale(:,2)-scale(:,1))+scale(:,1);
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% am is the cofficent matrix for offset and (or) orbit error inversion
% cyeind, the indices of the data set, in which orbital ramps or offsets 
% will be inverted. And cnoind, no operation will be carried out for them. 
% 
[am,cyeind,cnoind] = sim_mergin(cinput,abccof);
%
nset               = numel(cyeind);
input              = [];
fcounter           = 0;
%
% I am not sure why I gave some controls in the blow lines...
% temporarily stop running them since 2018-08-11
% by Wanpeng Feng, @SYSU, 2018-08-11
%
norm_am            = max(abs(am));
for ni = 1:size(am,2)
    am(:,ni) = am(:,ni)./norm_am(ni);
end
% %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nset > 0
  for ni=1:nset
      inf  = cinput{cyeind(ni)};
      %data = load(inf{1});
      data  = sim_inputdata(inf{1});
      input = [input;data];
      fcounter = fcounter+1;
      disp(['Number ' num2str(fcounter) ': ' inf{1} ' found(ABC). ' ...
           num2str(numel(data(:,1))) ' points imported to the package...']);
  end
end
if numel(cnoind)>0
   for ni=1:numel(cnoind)
      inf      = cinput{cnoind(ni)};
      data     = sim_inputdata(inf{1});
      if numel(data)==0
         return
      end
      input    = [input;data];
      fcounter = fcounter+1;
      disp(['Number ' num2str(fcounter) ': ' inf{1} ' found (NO-ABC).  ' ...
           num2str(numel(data(:,1))) ' points imported to the package...']);
   end
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For structure the weight column matrix
cindex = [cyeind;cnoind];
ndata  = numel(cindex);
cnum   = zeros(ndata,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wmatrix = [];
if isvcm ==1
   dig_1 = ones(size(input,1),1);
   mvcm  = diag(dig_1);
else
   mvcm  = 1;
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
novcm   = 0;
for ni=1:ndata
    inf       = cinput{cindex(ni)};
    [data,np] = sim_inputdata(inf{1});
    cnum(ni)  = np;
    tmp       = (zeros(cnum(ni),1)+1).*weighs(cindex(ni));
    wmatrix   = [wmatrix;tmp];
    start     = novcm+1;
    novcm     = novcm+np;
    if isvcm == 1
        if strcmpi(vcms{cindex(ni)},'NULL')==0
            %
            % VCM is available
            % Update by Feng, W.P., now support COV constraints
            % @ GU, 06/10/2011
            %
            [t_mp,bname] = fileparts(vcms{cindex(ni)}{1});
            [t_mp,t_mp,post]= fileparts(bname);
            %
            if isempty(strfind(upper(post),'COV'))==0
               iscov = 1;
            end
            vcm = load(vcms{cindex(ni)}{1});
            if iscov == 1
                vcm = vcm.cov;
            else
                vcm = vcm.vcm;
            end
            mvcm(start:novcm,start:novcm) = vcm;
        end
    end
end
if isvcm ==1
    mvcm(mvcm<0) = 0;
    %
    % Reference the Wright's Paper (2004, BSSA)
    % save test.mat mvcm
    %
    if iscov==0
        inv_VCM = inv(mvcm);
        wVCM    = chol(inv_VCM);
    else
        wVCM = mvcm;
    end
else
    wVCM    = 1;
    inv_VCM = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscov  == 1
    wVCM(isnan(wVCM)) = 1;
    wVCM(isinf(wVCM)) = 1;
    wVCM = wVCM-(min(wVCM(:))) + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp('****************************************************************');
disp(['Summary:']);
disp(['Total number of datapoints for inversion: ' num2str(size(input,1))]);
disp(['Total number of parameters to be estimated: ' num2str(numel(index))]);
disp(['Total number of particles used in the inversion: ' num2str(psoPS)]);
disp('****************************************************************');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the options for simplex algorithm.
if nargin < 3 || isempty(display)==1
   display = 'off';
end
% 
simplexoptions = optimset('TolFun',1.E-1,'Display',display,'MaxIter',simiters); 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
options.correction_factor = [0.8,1.5];
options.inertia           = 0.5;
options.iterations        = iterations;
options.DenThreshold      = disofparts;
%
outfpara           = cell(1,1);
outfpswm           = outfpara;
outstd             = zeros(1,2);
abcm               = cell(1,1);
abcsm              = cell(1,1);
mabc               = struct();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save test.mat wVCM
for ni= 1:ntimes
    %
    % psokinv_processing(scale,psoPS,options,simplexoptions);
    %
    [x fval xsimp fvalsimp maxtab fswarm] ...
        = pso_localv4(@sim_obj_conrake,scale,psoPS,options,simplexoptions);
    %
    % A test for tracing the process of the PSO method
    % save mpso.mat fswarm maxtab fvalsimp WholeData
    % modified by Feng, @ GU, 11/10/2011
    %
    if sum(isinf(x))>0 || sum(isnan(x)) > 0
        if ni > 1
           ni = ni -1;
        else
           ni = 1;
        end
        continue
    end
    initialONE               = xsimp(:)';
    %
    [sfpara abc vobj1 vobj2] = sim_obj_psoksar_SLIPALP(xsimp);
    %
    % Updated by Wanpeng Feng, @SYSU, 2018-04-21
    %
    outresults = ['WholeData_',num2str(ni),'.mat'];
    save(outresults,'WholeData');
    %
    njj = 0;
    if nset > 0
        counter   = 0;
        conNJJ    = zeros(1,1);
        conNJJ(1) = counter;
        for njj=1:nset
            %
            % modified by Feng W.P, 2009-10-25
            % Now the package supports just a&&b inversion or just c inversion
            %
            mabc(njj).fname = cinput{cindex(njj)};
            cofabc          = abccof(cindex(njj),:);
            if cofabc(3)==1
                counter = counter+2;
            end
            if cofabc(4)==1
                counter = counter+1;
            end
            conNJJ(njj+1) = counter;
            %counter
            Cabc          = abc(conNJJ(njj)+1:conNJJ(njj+1));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % the flag if the a&b need to invert. It's easy to clip C.
            %
            NowCON       = 0;
            if cofabc(3) == 1
                mabc(njj).a     = Cabc(1);
                mabc(njj).b     = Cabc(2);
                NowCON          = 2;
            else
                mabc(njj).a     = 0;
                mabc(njj).b     = 0;
            end
            if cofabc(4) == 1
                mabc(njj).c      = Cabc(NowCON+1:end);
            else
                mabc(njj).c      = 0;
            end
            mabc(njj).norm_abc   = norm_am;
        end
    end
    if numel(cnoind)>0
        for nij=(njj+1):(numel(cnoind)+njj)
            mabc(nij).fname = cinput{cnoind(nij-njj)};
            mabc(nij).a     = 0;%abc(((njj-1)*3)+1);
            mabc(nij).b     = 0;%abc(((njj-1)*3)+2);
            mabc(nij).c     = 0;%abc(((njj-1)*3)+3);
        end
    end
    %
    abcsm{ni}       = mabc;
    abcm{ni}        = abc;
    outfpara{ni}    = sfpara;
    outstd(ni,:)    = [vobj1,vobj2];
    outfpswm{ni}    = fswarm;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % now in default, the output format is OKSAR, Feng, W.P, 2011-04-15
    %
    outfile = outoksar{1};
    if iscell(outfile)
        outfile = outfile{1};
    end
    %
    [t_mp,outname,outfix] = fileparts(outfile);
    coutoksar          = [outname,'_',num2str(ni),outfix];
    %
    if isempty(UTMZONE)==0
        UTMZONE = [UTMZONE(1:2),' ',UTMZONE(end)];
        utmzone = UTMZONE;
    else
        %
        UTMZONE = [];
    end
    % updated by Feng,W.P.,@UoG, 2012-09-26
    % utmzone can be updated from inp file...
    %
    if isempty(utmzone)==0
        utmzone = [utmzone(1:2),' ',utmzone(end)];
    else
        utmzone = [];
    end
    if isempty(utmzone)==0
        UTMZONE = utmzone;
    end
    %
    % uzone should be added in oksar file in order to be used easily later...
    % updated by Feng,W.P., @ GU, 2012-09-26
    %
    % sfpara
    % updated by Wanpeng Feng, @CCRS/NRCan, 2017-09-19
    % "simp" will be a preferable format in PSOKINV.
    %
    [fdir,fname,fext] = fileparts(fullfile(savedir,coutoksar));
    if strcmpi(fext,'.simp')
       sim_fpara2simp(sfpara,fullfile(savedir,coutoksar),UTMZONE);
    else
       sim_fpara2oksar_SYN(sfpara,fullfile(savedir,coutoksar),UTMZONE);
    end
    %
    oksar2gmt(fullfile(savedir,coutoksar),[outname,'_'],'stitle',coutoksar,'outindex',4,'utmzone',UTMZONE,'minstd',min([vobj1,vobj2]));
    sim_okinv2res(sfpara,mabc(:),ni,alpha);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eval(['save ' fullfile(savedir,outmatf{1}{1}) ' outfpara outfpswm outstd fpara abcm abcsm cinput cyeind cnoind']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp([fullfile(savedir,outmatf{1}{1}) ' has been saved!']);
    disp(['Congratulations! PSOKINV finished JOB Number ' num2str(ni) '!']);
    %
end
nowtime = datestr(now());
disp(['Ending time: ' nowtime ' .']);
toc;


   
