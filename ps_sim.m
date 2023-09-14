function ps_sim(siminp,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Usage:
%     ps_sim(siminp,refpoint); batch script for simulation\residual
% Input:
%      siminp, the configure file for simulation.
%     varagin, new parameters allowed
%              lonlat or zone for a given utm projetion zone if the data
%              with lonlat projection...
%
% Modification History:
%    Created by Feng, W,P
%    Original version finished @ Glasgow, 10/06/2009
% -> add keyworks, e.g. zone and lonlat
%    by Feng, W.P., 2011-08-23, @ BJ
%    Modified by Feng, W.P., @ GU, 2011/12/28
% -> make more easy usage...
% -> Improved by Feng, W.P.,@ GU, 2012-09-27
%    inc files can be jumped if you have no this file or unless you want to
%    use incdata at each pixel...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
global strike dip rake friction depth young posi rzone synmodel mu 
%
if nargin<1 || isempty(siminp)==1||exist(siminp,'file')==0
    disp('ps_sim(siminp,refpoint)');
    disp(' >>> siminp, the configure file for simulation');
    disp(' >>> numcpu, the number of cup for parallel computation');
    disp(' >>> varargin, the keywords for special control');
    disp('         lonlat -> given the reference points with lonlat for UTMZONE');
    disp('         zone   -> utm zone. If it is given, the lonlat will be invalid');
    disp(' >>> Version: 3.5');
    disp(' >>> Contact: Feng, W.P, wanpeng.feng@hotmail.com, 25/08/2011');
    %
    %disp('The SIM config file is not found...');
    return
end
%

% Fix bug, if inp does not exist, the code will make error
% modified by Feng, W.P., @ BJ, 2011-08-19
%
rootdir = pwd;
inpdir  = fullfile(rootdir,'inp');
if exist(inpdir,'dir') == 0
    mkdir('inp');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
siminfo = sim_getsimcfg(siminp);
synmodel = siminfo.synmodel;
mu       = siminfo.mu;
alp      = sim_poisson2mediaconstant(mu);
%%%
if exist(siminfo.savedir,'dir')==0
    mkdir(siminfo.savedir);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lonlat = [];
zone   = [];
numcpu = 1;
thd    = 0.000001;
v = sim_varmag(varargin);
for j = 1:length(v)
    eval(v{j});
end
%
% updated by fwp, @ GU, 2013-03-22
%
if ~exist(siminfo.oksarfile,'file') 
    disp([' PS_SIM: oksar file is not found. Please check ',siminfo.oksarfile]);
    disp( ' PS_SIM: Quit now...');
    return
end
%
[t_a,t_a,ext] = fileparts(siminfo.oksarfile);
ext = strrep(ext,' ','');
%
switch upper(ext)
    case '.OKSAR'
        uzone = sim_oksar2utm(siminfo.oksarfile);
    case '.SIMP'
        [t_a,uzone] = sim_simp2fpara(siminfo.oksarfile);
    otherwise 
        disp(['No match with an extension ',upper(ext)]) 
end
%
if ~isempty(uzone)
    zone = uzone;
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numcpu > 1
    eval(['matlabpool open ',num2str(numcpu)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(lonlat) && isempty(zone)
    rzone = [];
else
    if isempty(zone)==0
        rzone = zone;
    end
    if isempty(lonlat)==0
       [tmp_a,tmp_a,rzone] = deg2utm(lonlat(2),lonlat(1));
    end
end
%
% matlabpool open 3
%
if siminfo.numjob >0
    for ni=1:siminfo.numjob
        %
        incfrsc          = sim_checkfiles(siminfo.incf{ni},...
                                          siminfo.azif{ni},...
                                          siminfo.unwf{ni});
        if isempty(incfrsc)
            disp(' pS_SIM: no valid .rsc found. Please check cfg file');
            return
        end
        %
        [pathstr, bname] = fileparts(incfrsc);
        [t_a,bname]      = fileparts(bname);
        %
        outsim           = fullfile(siminfo.savedir,...
                           [siminfo.simpref,bname,siminfo.postfix]);
        outerr           = fullfile(siminfo.savedir,...
                           [siminfo.errpref,bname,siminfo.postfix]);
        outdif           = fullfile(siminfo.savedir,...
                           [siminfo.difpref,bname,siminfo.postfix]);
        %
        if siminfo.issim(ni) == 1
            if siminfo.coulomb(1) ==0
                sim_psokinv4SIM(siminfo.oksarfile,siminfo.incf{ni},siminfo.azif{ni},siminfo.models{ni},outsim,alp,thd,rzone,siminfo.unwf{ni});
                disp([outsim ' Coseismic have been created!']);
                %
            else
                strike   = siminfo.coulomb(2);
                dip      = siminfo.coulomb(3);
                rake     = siminfo.coulomb(4);
                friction = siminfo.coulomb(5);
                depth    = siminfo.coulomb(6);
                young    = siminfo.coulomb(7);
                posi     = siminfo.coulomb(8);
                sim_psokinv4COL(siminfo.oksarfile,siminfo.incf{ni},siminfo.azif{ni},siminfo.models{ni},outsim,0.5,thd,rzone);
                disp([outsim ' Coulomb have been created!']);
                siminfo.iserr = zeros(numel(siminfo.iserr),1);
                siminfo.isdif = siminfo.iserr;
            end
            
        end
        if siminfo.iserr(ni)==1
            sim_simerror(outsim,outerr,rzone);
            disp([outerr ' Error have been created!']);
        end
        if siminfo.isdif(ni)==1
            sim_simresi(siminfo.unwf{ni},outsim,outerr,outdif);
            disp([outdif ' Residual have been created!']);
        end
        %
        if exist('simres','dir')
            fid = fopen('simres/SIM.log','a');
            fprintf(fid','%s %s %s\n','>>>>>>>>>> On ',date,', one job is done!!! >>>>>>>>>>>>>>');
            fprintf(fid,'%s %s\n','  OKSARFILE: ',siminfo.oksarfile);
            fprintf(fid,'%s %s\n','  INCFILE:',  siminfo.incf{ni});
            fprintf(fid,'%s %s\n','  AZIFILE:',  siminfo.azif{ni});
            fprintf(fid,'%s %s\n','  UNWFILE:',  siminfo.unwf{ni});
            fclose(fid);
        end
    end
end

%
if numcpu > 1
    matlabpool close;
end
