function psokinv(inf,uzone,numcpu)
 %
 % PSO-Simplex-based OKada INVersion package (PSOKINV)
 % Being developed by Dr. Wanpeng Feng, since 2007
 %
 % During the development of PSOKINV, Prof. Lisheng Xu (IGP-CEA), Prof.
 % Zhonghuai Xu(IGP-CEA), Dr. Yong Zhang(Peking University) and many others, 
 % some of whom I even haven't met with, have provided countless guidiances
 % on the general geophysical inversion. 
 %
 % The First version of PSOKINV was completed when I visited Dr. Zhenghon Li 
 % at UoG (Glasgow) in 2009. With his great suggestions on the structure of 
 % the inversion package,
 % I then keep the entire structure of PSOKINV without any change. The
 % InSAR-downsampling pacakage was developed based on a few original m-codes from Dr.
 % Gareth Funning (UCR). Rowana Lohman (Cornell Uni) gave lots of help on
 % cathcing up with the resolution-based downsampling algorithm. 
 % 
 % Add some log information when none input parameters!
 % by Wanpeng Feng, 20090903
 % Add a new function, the model can be constraint with the fixed rake angle.
 % by Feng W.P, 20090903
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Version2.0
 %
 % 1) Mofidied some ambiguous definition, psoksar not oksar in the codes.
 %    Now in the package all output ascii model in psoksar format.
 %    NOTICE!!
 %    To the early configuration file, the package can not input them correctly.
 % 2) Now the cofficient parameters can work well in the inversion.
 % 3) Now a new output file will be generated at the end of processing...,
 %    e.g std.mod
 % 4) Enhance the rake constraints,modified by Feng,Wanpeng,10/02/2011
 %    now the psokinv code has been updated to ver2.5.
 %
 %************************************************************
 % Version 3.0
 % 1) now standarlize the output format, OKSAR, Feng, W.P, 2011-04-15, @ BJ
 % 2) fix a bug in oksar define, Feng, W.P, 2011-04-15, @ BJ
 %************************************************************
 % Version 3.5 by Feng, W.P., 2011-08-29 @ BJ, wanpeng.feng@hotmail.com
 % 1) now fix a bug in MPSO nonlinear algorithm
 % 2) improve the Laplacian when multiple segments will interact together. 
 %************************************************************
 % Version 4.0 by FWP, @ UoG, 2012-09-01, wanpeng.feng@hotmail.com
 % 1) ???
 %************************************************************
 % Version 4.5 by FWP, @ UoG, 2013-03-08, wanpeng.feng@hotmail.com
 % 1) automatically construct a configure file for inversion using a inp file;
 % 2) return a robust fault model using rake angle constraints
 %*************************************************************
 % Version 5.0 by FWP, @CCRS/CCMEO/NRCan, 2016-11-28, wanpeng.feng@hotmail.com
 % 1) This is a latest release with a serie of updates that have been made in the last few years.
 % 2) I will certainly keep working with this package for next few years.
 %    However, I start considering a new python based inversion package
 %    since I do love python now. Loads of headaches in the current version
 %    should be overcome in the new python version. But certainly this can
 %    take years to finally finish...
 % 3) PSOKINV was gradually improved through several previous investigations,
 %    including
 %    Feng, W., et al.,2018,
 %           Geodetic Constraints of the 2017 Mw7.3 Sarpol Zahab, Iran Earthquake, and Its Implications on the Structure and Mechanics of the Northwest Zagros Thrust-Fold Belt, Geophys. Res. Lett., vol. 45, no. 14, pp. 6853â€?6861, Jun. 2018.
 %    Feng, W., et al.,2017
 %           A Slip Gap of the 2016 M w 6.6 Muji, Xinjiang, China, Earthquake Inferred from Sentinel-1 TOPS Interferometry, Seismol. Res. Lett., vol. 88, no. 4, pp. 1054â€?1064, 2017.
 %    Feng, W., et al, 2017,
 %           Surface deformation associated with the 2015 Mw 8.3 Illapel earthquake revealed by satellite-based geodetic observations and its implications for the seismic cycle. Earth Planet. Sci. Lett. doi:http://dx.doi.org/10.1016/j.epsl.2016.11.018
 %    Feng, W., et al, 2014,
 %           Patterns and mechanisms of coseismic and postseismic slips of the 2011 MW7.1 Van (Turkey) earthquake revealed by multi-platform synthetic aperture radar interferometry. Tectonophysics 632, 188198. doi:10.1016/j.tecto.2014.06.011
 %    Feng, W., et al, 2016,
 %           Source Characteristics of the 2015 MW 7.8 Gorkha Earthquake and its MW 7.2 Aftershock from Space Geodesy. Tectonophysics. doi:10.1016/j.tecto.2016.02.029
 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global UTMZONE
%
if nargin < 3 || isempty(numcpu)
    numcpu = 1;
end
if numcpu > 1 
  eval(['matlabpool open ' num2str(numcpu)]); %
end
if nargin < 2 || isempty(uzone)
    uzone = [];
end
%
if isempty(uzone)==0
    uzone = MCM_rmspace(uzone);
    uzone = [uzone(1:length(uzone)-1),' ',upper(uzone(end))];
end
%
%
UTMZONE = uzone;
%
nfill   = 60;
fillstr = [repmat('#',1,nfill),'\n'];
skipstr = '\n';
msgstr  = fillstr;
%
msgstr(round(nfill)/2-18:round(nfill/2)+17)='          PSOKINV (Ver 5.0)         ';
fprintf([skipstr,fillstr,msgstr]);
tmpstr='Developer: Wanpeng Feng (IGP/UoG/CCRS)';
msgstr(round(nfill)/2-numel(tmpstr)/2:round(nfill/2)+(numel(tmpstr)-numel(tmpstr)/2)-1)=tmpstr;
fprintf(msgstr);
msgstr  = fillstr;
msgstr(round(nfill)/2-18:round(nfill/2)+17)='        Oct  2009,by FWP(v1.1)      ';
fprintf(msgstr);
msgstr  = fillstr;
msgstr(round(nfill)/2-18:round(nfill/2)+17)='        Feb  2011,by FWP(v2.0)      ';
fprintf(msgstr);
msgstr  = fillstr;
msgstr(round(nfill)/2-18:round(nfill/2)+17)='        Apr  2011,by FWP(v2.5)      ';
fprintf(msgstr);
msgstr  = fillstr;
msgstr(round(nfill)/2-18:round(nfill/2)+17)='        Agu  2011,by FWP(v3.0)      ';
fprintf(msgstr);
msgstr  = fillstr;
msgstr(round(nfill)/2-18:round(nfill/2)+17)='        Sep  2012,by FWP(v4.0)      ';
fprintf(msgstr);
msgstr  = fillstr;
msgstr(round(nfill)/2-18:round(nfill/2)+17)='        Mar  2013,by FWP(v4.5)      ';
fprintf(msgstr);
msgstr  = fillstr;
msgstr(round(nfill)/2-18:round(nfill/2)+17)='        Nov  2016,by FWP(v5.0)      ';
fprintf(msgstr);
msgstr  = fillstr;
msgstr(round(nfill)/2-18:round(nfill/2)+17)='  Python-based version coming soon  ';
fprintf(msgstr);
msgstr  = fillstr;
%msgstr(round(nfill)/2-19:round(nfill/2)+19)=' A python-based version coming soon... ';
fprintf(msgstr);
%
%**************************************************************************
%*8

if nargin <1 || isempty(inf)==1
   disp('')
   disp('  A configure file is needed...');
   disp('  Usage: psokinv(<configure_file>.cfg,[UTMZONE],[numcpus])');
   disp('        <configure_file>.cfg can be generated with an internal function, sim_invconfig');
   disp('        A further editor will surely requrired to return an expecting fault model');
   disp('        [UTMZONE],this can be ignored in default. The UTMZONE number can also be collected from the downsampled InSAR points, which is part of filename in default');
   disp(' ')
   %
   nowtime = datestr(now());
   disp('*****************************************');
   disp(['Starting Time: ' nowtime ]);
   disp('*****************************************');
   return
end
if exist(inf,'file')==0
    disp(['CONFIGURE file, ' inf ', does not exist, please check...']); 
    return
else
    disp(['CONFIGURE file, ' inf ', is used...']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%isplay,simiters,a1,a2,a3,a4,a5,...
%    disofparts,rake_value,rake_isinv,isvcm,rakeinfo,mwconinfo,...
%    obsunit,mwall,UTMZONE
%
 [psoPS,insfile,forms,outpsoksar,abccof,outmatf,fpara,...
          lamda,myu,scamin,scamax,InV,locals,weighs,vcms,...
          ntimes,iterations,display,itersSIM,ismc,mcloops,...
          mcdir,mcsave,fismc,mindis,rake_value,rake_isinv,...
          isvcm,rakeinfo,mwconinfo,obsunit,mwall,UTMZONE] = sim_readconfig(inf);

%
%
disp(['# Elastic constant: (lambda)           ->' num2str(lamda)]);
disp(['# Elastic constant: (mu)               ->' num2str(myu)]);
disp(['# number of particles                  ->' num2str(psoPS)]);
disp(['# PSO: maximum restart number          ->' num2str(ntimes)]);
disp(['# PSO: total iteration number          ->' num2str(iterations)]);
disp(['# PSO: minimum DIS of PSOs to stop INV ->' num2str(mindis)]);
disp(['# SIMPLEX: maximum iteration number    ->' num2str(itersSIM)]);
disp(['# SIMPLEX: Info to be shown            ->' display]);
disp(['# Monte Carlo Estimation               ->' ismc]);
disp(['# UTMZONE of the displacements         ->' UTMZONE]);
if strcmpi(ismc,'YES')==1
    %
    disp(['# Monte Carlo: Directory of InputFiles ->' mcdir{1}{1}]);
    disp(['# Monte Carlo: Directory of OutputFiles->' mcsave{1}{1}]);
    if exist(mcsave{1}{1},'dir')==0
       mkdir(mcsave{1}{1});
    end
end
%
disp(['# Output file name: matlab format      ->' outmatf{1}{1}]);
%
%
if strcmpi(ismc,'YES')==1
    %
   disp('*****************************************');
   disp('********* Monte Carlo Inversion *********');
   if isempty(mcloops) ==1 
      disp('plese google');
      return
   end
   %
   loops = [mcloops(1) mcloops(2)];
   parfor noloops=loops(1):loops(2)
       %
       disp('*****************************************');
       disp(['Importing MC dataset, Number ' num2str(noloops) ' ...']);
       sim_FUNCinvnfault_MCv2(inf,noloops);
       disp('*****************************************');
       fprintf('MC Inversion finished, Number: %3f %s\n',noloops,'. Well done!');
       disp('*****************************************');
   end
else
    disp('*****************************************');
    disp('************* PS  Inversion *************');
    sim_FUNCinvnfault(inf);
	disp('*****************************************');
    disp('PS Inversion finished.  Well done!');
    disp('*****************************************');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add parallel control work... Close the batch job...
if numcpu > 1
   matlabpool close;  
end
