function siminfo = sim_getsimcfg(inf)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Wanpeng Feng, Created
 % working for input configure file working for simulation.
 %*************************************************************************
 % Modified by Feng, W.P, 2011-04-15, @ BJ
 % the package supports the file with the postfix of OKSAR or PSOKSAR
 % 
 siminfo.mu = 0.25; % poisson ratio...
 siminfo.oksarf  = '';
 siminfo.savedir = '';
 siminfo.postfix = '';
 siminfo.simpref = '';
 siminfo.difpref = '';
 siminfo.errpref = '';
 siminfo.numjob  = 0;
 siminfo.issim   = [];
 siminfo.isdif   = [];
 siminfo.iserr   = [];
 siminfo.incf    = [];
 siminfo.azif    = [];
 siminfo.unwf    = [];
 siminfo.models  = [];
 siminfo.coulomb = 0;
 siminfo.synmodel= 'los';
 %
 if nargin<1 || isempty(inf)==1|| exist(inf,'file')==0
    disp('You must give a correct fullname of the SIM-INP file.');
    return
 end
 %
 fid = fopen(inf);
 while feof(fid)~=1
     str   = fgetl(fid);
     index = findstr(str,'# directory to keep simulation results');
     if isempty(index)~=1
        siminfo.savedir = fgetl(fid);
     end
     %
     % Modified by Feng, W.P, 2011-04-15
     %  now input can be with different postfix, psoksar or oksar
     index = findstr(str,'# inp file for');
     if isempty(index)~=1
        siminfo.oksarfile = fgetl(fid);
     end
     %
     index = findstr(str,'# postfix of simulation results (keyword)');
     if isempty(index)~=1
        siminfo.postfix = fgetl(fid);
     end
     %
     index = findstr(str,'# prefix of simulation results');
     if isempty(index)~=1
        siminfo.simpref = fgetl(fid);
     end
     %
     index = findstr(str,'# prefix of residuals');
     if isempty(index)~=1
        siminfo.difpref = fgetl(fid);
     end
     %
     index = strfind(str,'# prefix of orbital ramps');
     if isempty(index) ~= 1
        siminfo.errpref = fgetl(fid);
     end
     %
     index = strfind(str,'# poisson ratio: 0.25 in default');
     if isempty(index) ~= 1
         tmp = fgetl(fid);
         tmp = textscan(tmp,'%f');
        siminfo.mu = tmp{1};
     end
     %
     index = strfind(str,'# the simulation model');
     if isempty(index) ~= 1
         siminfo.synmodel = MCM_rmspace(fgetl(fid));
     end
     %
     index = strfind(str,'# CFS');
     if isempty(index)~=1
         tmp = fgetl(fid);
         tmp = textscan(tmp,'%f%f%f%f%f%f%f%f');
         siminfo.coulomb = [tmp{1},tmp{2},tmp{3},tmp{4},tmp{5},tmp{6},tmp{7},tmp{8}];
         %disp(tmp);
     end
     index = strfind(str,'# number of simulation files');
     %
     if isempty(index)~=1
        tmp = fgetl(fid);
        tmp = textscan(tmp,'%f');
        siminfo.numjob = tmp{1};
        if siminfo.numjob >0
           fgetl(fid);
           fgetl(fid);
           fgetl(fid);
           for ni=1:siminfo.numjob
               tmp = fgetl(fid);
               %disp(tmp);
               temp= textscan(tmp,'%d %d %d %d %s %s %s %s');
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%
               siminfo.issim(ni)  = temp{2};
               siminfo.isdif(ni)  = temp{4};
               siminfo.iserr(ni)  = temp{3};
               siminfo.models{ni} = temp{5}{1};
               siminfo.incf{ni}   = temp{6}{1};
               siminfo.azif{ni}   = temp{7}{1};
               siminfo.unwf{ni}   = temp{8}{1};
           end
        end
     end
     %
     tmp   = [];
     index = [];
 end
 fclose(fid);
 
 
 
