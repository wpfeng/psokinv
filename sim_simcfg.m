function sim_simcfg(outname,oksarfile,incfile,azifile,unwfile,savedir,synmodel,poissonratio,prefix)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created by Feng, W.P, 2009
%**************************************************************************
% Modified by Feng,W.P, 2011-04-15, @ BJ
%   permit OKSAR format as main input
%
if nargin<1 || isempty(outname)==1
   outname = 'psokinv_SIM.cfg';
end
if nargin < 2 || isempty(oksarfile)
    oksarfile = 'Fmodel.oksar';
end
if nargin < 3 || isempty(incfile)
    incfile = 'NULL';
end
if nargin < 4 || isempty(azifile)
    azifile = 'NULL';
end
if nargin < 5 || isempty(unwfile)
    unwfile = 'NULL';
end
if nargin < 6
   savedir = 'simres';
end
if nargin < 7
    synmodel = 'los';
end
if nargin < 8
    poissonratio = 0.25;
end
if nargin < 9
    prefix = '_v1';
end
%
%
%
fid = fopen(outname,'w');
%
%********
% modified by Feng, Wanpeng, the code permits OKSAR format....
% 2011-04-15, @ BJ
fprintf(fid,'%s\n','# inp file for oksar Model');
fprintf(fid,'%s\n',oksarfile);
fprintf(fid,'%s\n','# directory to keep simulation results');
fprintf(fid,'%s\n',savedir);
fprintf(fid,'%s\n','# postfix of simulation results (keyword)');
fprintf(fid,'%s\n',prefix);
fprintf(fid,'%s\n','# prefix of simulation results');
fprintf(fid,'%s\n','SIM_');
fprintf(fid,'%s\n','# prefix of residuals');
fprintf(fid,'%s\n','RES_');
fprintf(fid,'%s\n','# prefix of orbital ramps');
fprintf(fid,'%s\n','ORB_');
fprintf(fid,'%s\n','# poisson ratio: 0.25 in default');
fprintf(fid,'%f\n',poissonratio);
fprintf(fid,'%s\n','# the simulation model: LOS ,RNG or AZI');
fprintf(fid,'%s\n',synmodel);
fprintf(fid,'%s\n','# CFS(bar), str(d), dip(d), rake(d), fri, dep(km),young(10e-5Pa),posi');
fprintf(fid,'%1.0f %4.1f %3.1f %4.1f %2.2f %3.1f %8.1f %3.2f\n',[0,0,0,0,0,0,800000,0.25]);
fprintf(fid,'%s\n','# number of simulation files');
fprintf(fid,'%s\n','1');
%
fprintf(fid,'%s\n','---------------------------------------------------------------------------');
fprintf(fid,'%s\n','# NO  SIM(0/1) ORB(0/1) RES(0/1) MODEL(mean/LOS) INCIDENCE AZIMUTH  UNWFILE');
fprintf(fid,'%s\n','---------------------------------------------------------------------------');
%
%
if strcmpi(incfile,'NULL')==0
   simmod = 'LOS';
else
   simmod = 'mean';
end
if strcmpi(unwfile,'NULL')==1
    isres = 0;
else
    isres = 1;
end
%isres
fprintf(fid,'%s %2d %5s %s %s %s\n','  1      1       1  ', isres, simmod, incfile,azifile,unwfile);%  NULL UNW.img');
fclose(fid);

