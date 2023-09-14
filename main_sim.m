function main_sim(siminp)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
if nargin<1 || isempty(siminp)==1||exist(siminp,'file')==0
   disp('The SIM config file is not found...');
   return
end
siminfo = sim_getsimcfg(siminp);
if exist(siminfo.savedir,'dir')==0
   mkdir(siminfo.savedir);
end
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
          sim_psokinv4SIM(siminfo.oksarfile,siminfo.incf{ni},siminfo.azif{ni},siminfo.models{ni},outsim,0.5,0.05);
          disp([outsim ' SERIES have been created!']);
       end
       if siminfo.iserr(ni)==1
          sim_simerror(outsim,outerr);
          disp([outerr ' SERIES have been created!']);
       end
       if siminfo.isdif(ni)==1
          sim_simresi(siminfo.unwf{ni},outsim,outerr,outdif);
          disp([outdif ' SERIES have been created!']);
       end
       
          
   end
end
