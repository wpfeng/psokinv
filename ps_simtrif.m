function ps_simtrif(siminp,poi,show,refpoint)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<1 || isempty(siminp)==1||exist(siminp,'file')==0
   disp('ps_simtrif(siminp,poisson,ishow,refpoint)');
   disp(' >>> siminp, the configure file for simulation');
   disp(' >>> poisson, the poisson ratio, the necesssary for the media, e.g,0.25');
   disp(' >>> isshow,  the type about if some info will be printed, e.g, 1:yes');
   disp(' >>> refpoint, the reference point in Lonlat, e.g,[lon,lat]');
   %disp('The SIM config file is not found...');
   return
end
siminfo = sim_getsimcfg(siminp);
%disp(siminfo)
if exist(siminfo.savedir,'dir')==0
   mkdir(siminfo.savedir);
end
if nargin<2 || isempty(poi)==1
    poi = 0.25;
end
if nargin<3 || isempty(show)==1
    show = 1;
end
if nargin<4 || isempty(refpoint)==1
   rzone         = [];
else
  [x0,y0,rzone] = deg2utm(refpoint(2),refpoint(1));
end
%
global poisson isshow pi
poisson = poi;
isshow  = show;
pi      = 3.141592653589793;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if siminfo.numjob >0
   for ni=1:siminfo.numjob
       [pathstr, bname] = fileparts(siminfo.incf{ni});
       outsim                      = fullfile(siminfo.savedir,...
                                     [siminfo.simpref,bname,siminfo.postfix]);
       outerr                      = fullfile(siminfo.savedir,...
                                     [siminfo.errpref,bname,siminfo.postfix]);
       outdif                      = fullfile(siminfo.savedir,...
                                     [siminfo.difpref,bname,siminfo.postfix]);
       if siminfo.issim(ni)==1
          sim_psokinv4SIMTRIF(siminfo.oksarfile,siminfo.incf{ni},siminfo.azif{ni},siminfo.models{ni},outsim,0.5,0.005,rzone);
          disp([outsim ' SERIES have been created!']);
       end
       if siminfo.iserr(ni)==1
          sim_simerror(outsim,outerr,rzone);
          disp([outerr ' SERIES have been created!']);
       end
       if siminfo.isdif(ni)==1
          sim_simresi(siminfo.unwf{ni},outsim,outerr,outdif);
          disp([outdif ' SERIES have been created!']);
       end
       
          
   end
end
