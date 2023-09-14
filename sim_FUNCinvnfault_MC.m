function sim_FUNCinvnfault_MC(invf,noloops)
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
%       inversion main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Varibles you must change based on your need.
% Logs:
% Modified by Feng W.P, IGP-CEA, 2010-05-03
% Normalized the weight of the input data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matlabpool open 8 ;% start matlab parallel toolbox...

tic;
%
%
global input fpara Inv index locals alpha symbols weighs cinput am wmatrix wVCM ...
       rake_isinv rake_value mvcm inv_VCM initialONE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the funcs into the system path.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if exist(invf,'file')==0
%    disp(['CONFIGURE file, ' invf ', does not exist, please double check...']); 
%    return
%else
%	disp(['CONFIGURE file, ' invf ', is being used...']);
%end
%disp('*****************************************');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[psoPS,cinput,symbols,outoksar,abccof,outmatf,fpara,...
 lamda,myu,scamin,scamax,Inv,locals,weighs,vcms,...
 ntimes,iterations,display,itersSIM,ismc,mcloops,...
 mcdir,mcsave,fismc,disofparts,rake_value,rake_isinv,isvcm] = sim_readconfig(invf);
%
weighs = weighs./sum(weighs(:));
alpha  = lamda/(lamda+myu);
index  = find(Inv==1);
npara  = numel(index);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if npara==0
   disp('There is no parameter to be inverted...');
   return
end
scale = zeros(npara,2);
scale(:,1) = scamin(index);
scale(:,2) = scamax(index);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%whos Inv
if exist('initialONE.inp','file')~=0
   initialONE  = load('initialONE.inp');
   %initialONE = bestfpara(Inv==1);
   %
else
   initialONE = rand.*(scale(:,2)-scale(:,1))+scale(:,1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cinput = sim_remcinpf(cinput,mcdir,fismc,noloops);
[am,cyeind,cnoind] = sim_mergin(cinput,abccof);
nset        = numel(cyeind);
input       = [];
fcounter    = 0;
if nset > 0
  for ni=1:nset
      inf  = cinput{cyeind(ni)};
      data = sim_inputdata(inf{1});
      input= [input;data];
      fcounter = fcounter+1;
	  disp(['Number ' num2str(fcounter) ': ' inf{1} ' found. ' ...
           num2str(numel(data(:,1))) ' points imported to the package...']);
  end
end
if numel(cnoind)>0
   for ni=1:numel(cnoind)
      inf  = cinput{cnoind(ni)};
      data = sim_inputdata(inf{1});
      input= [input;data];
      fcounter = fcounter+1;
      disp(['Number ' num2str(fcounter) ': ' inf{1} ' found.  ' ...
           num2str(numel(data(:,1))) ' points imported to the package...']);
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For structure the weight column matrix
cindex = [cyeind;cnoind];
ndata  = numel(cindex);
cnum   = zeros(ndata,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wmatrix = [];
%
if isvcm == 1
    dig_1= ones(size(input,1),1);
    mvcm = diag(dig_1);
else
    mvcm = 1;
end
%
novcm   = 0;
for ni=1:ndata
    inf = cinput{cindex(ni)};
    %data= load(inf{1});
    [data,np] = sim_inputdata(inf{1});
    cnum(ni) = np;
    tmp      = (zeros(cnum(ni),1)+1).*weighs(cindex(ni));
    wmatrix  = [wmatrix;tmp];
    start    = novcm+1;
    novcm    = novcm+np;
    %disp([start,novcm,size(mvcm)]);
    if isvcm == 1
        if strcmpi(vcms{cindex(ni)},'NULL')==0
            %disp(vcms{cindex(ni)})
            vcm      = load(vcms{cindex(ni)}{1});
            vcm      = vcm.vcm;
            mvcm(start:novcm,start:novcm) = vcm;
        end
    end
      
end
if isvcm == 1
    mvcm(mvcm<0) = 0;        % VCM should be a positive define matrix.
    inv_VCM      = inv(mvcm);
    wVCM         = chol(inv_VCM);
else
    wVCM         = 1;
    inv_VCM      = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp('****************************************************************');
disp( 'Summary:' );
disp(['Total number of datapoints for inversion: ' num2str(size(input,1))]);
disp(['Total number of parameters to be estimated: ' num2str(numel(index))]);
disp(['Total number of particles used in the inversion: ' num2str(psoPS)]);
disp('****************************************************************');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the options for simplex algorithm.
simplexoptions = optimset('TolFun',1.E-1,'Display',display,'MaxIter',itersSIM); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
options.iterations   = iterations;
options.DenThreshold = disofparts;
%
outfpara           = cell(1,1);
outfpswm           = outfpara;
outstd             = zeros(1,2);
abcm               = cell(1,1);
abcsm              = cell(1,1);
mabc               = struct();
%
for ni=1:ntimes
  [x fval xsimp fvalsimp maxtab fswarm] ...
                           = pso_localv4(@sim_obj_conrake,scale,psoPS,options,simplexoptions);
  % disp(x);
  initialONE               = xsimp(:)';
  [sfpara abc vobj1 vobj2] = sim_obj_psoksar_SLIPALP(xsimp);
  njj = 0;
  if nset > 0 
     counter   = 0;
     conNJJ    = zeros(1,1);
     conNJJ(1) = counter;
     for njj=1:nset
         % modified by Feng W.P, 2009-10-25
         % Now the package supports just a&&b inversion or just c inversion
         mabc(njj).fname = cinput{cindex(njj)};
         cofabc          = abccof(cindex(njj),:);
         if cofabc(3)==1
            counter = counter+2;
         end
         if cofabc(4)==1
            counter = counter+1;
         end
         conNJJ(njj+1) = counter;
         Cabc          = abc(conNJJ(njj)+1:conNJJ(njj+1));
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % the flag if the a&b need to invert. It's easy to clip C.
         %
         NowCON        = 0;
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
  abcsm{ni}               = mabc;
  abcm{ni}                = abc;
  outfpara{ni}            = sfpara;
  outstd(ni,:)            = [vobj1,vobj2];
  outfpswm{ni}            = fswarm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified by Feng, W.P, 2011-04-15, @ BJ
% in default, output will be in OKSAR format...%
%
outfile = outoksar{1};
if iscell(outfile)
    outfile = outfile{1};
end
[~,outname,outfix] = fileparts(outfile);
coutoksar =[outname,'_',num2str(ni),outfix];
%sim_fpara2oksar(sfpara,fullfile(savedir,coutoksar));
sim_fpara2oksar_SYN(sfpara,fullfile(mcsave{1}{1}, ['MC_' num2str(noloops) '_' coutoksar]));
%oksar2gmt(fullfile(savedir,coutoksar),[outname,'_'],'stitle',coutoksar,'outindex',4,'utmzone',UTMZONE,'minstd',min([vobj1,vobj2]));
sim_okinv2res(sfpara,mabc(:),ni,alpha);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eval(['save ' [fullfile(mcsave{1}{1}, ['MC_' num2str(noloops) '_' outmatf{1}{1}])] ' outfpara outfpswm outstd fpara abcm abcsm cinput cyeind cnoind']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['PSOKINV finished: PSO Number ' num2str(ni) '; MC inversion number: ' num2str(noloops) '.']);
end
nowtime = datestr(now());
toc;

%matlabpool close ; %Close the Parallel tools...

   
