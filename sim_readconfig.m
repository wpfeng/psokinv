function [psoPS,insfile,forms,outpsoksar,abccof,outmatf,fpara,...
    lamda,myu,scamin,scamax,InV,locals,weighs,vcms,...
          ntimes,iterations,display,itersSIM,ismc,mcloops,...
          mcdir,mcsave,fismc,disofparts,rake_value,rake_isinv,...
          isvcm,outrakeinfo,mwcoinfo,obsunit,mwall,utmzone] = ...
          sim_readconfig(configf)
     
 %
 % Purpose:
 %        read a configure file to extract parameters.
 % Input: 
 %        a configure file, can be generated by sim_invconfig.m 
 % Output: 
 %        psoPS, particle number
 %      insfile, list of inp files
 %        forms, symbol of all variables
 %   outpsoksar, a full path for oksar format
 %        fpara, the initial parameters of the fault model
 %        lamda, the constant of lamda
 %          myu, the constant of lamda
 %       scamin, the minvalue of the parameters
 %       scamax, the maxvalue of the parameters
 %          InV, the type showing if-inverted of parameters
 %       weighs, the weight from different data set.
 %       abccof, the coefficient for the orbit error and offset.
 %         vcms, the FULL Covariance Matrix.
 % Author: Created by Feng Wanpeng
 %         wanpeng.feng@hotmail.com
 % University of Glasgow, 03 June 2009
 %
 %*************************************************************************
 % Modified by Feng, W.P, 2011-04-15, @ BJ
 %  more flexible to utilize
 %
 global rakeinfo
 psoPS      = 200;
 insfile    = [];
 forms      = [];
 outpsoksar = 'OUT.oksar';
 outmatf    = 'matfile.mat';
 fpara      = [];
 lamda      = 3.20e+010;
 myu        = 3.20e+010;
 scamin     = [];
 scamax     = [];
 InV        = [];
 weighs     = [];
 abccof     = [];
 locals     = [];
 vcms       = [];
 ntimes     = 1;
 iterations = 25;
 display    = 'off';
 itersSIM   = 2000;
 ismc       = 'NO';
 mcloops    = [];
 rake_value = zeros(1,1);
 rake_isinv = zeros(1,1);
 mcdir      = 'pert';
 mcsave     = 'result';
 fismc      = 0;
 disofparts = 10^(-1);
 isvcm      = 0;
 obsunit    = 'm';
 utmzone    = [];
 %
 % Added by Wanpeng Feng, @SYSU, 2018-08-05
 % Useful for multiple-fault cases. In default,
 % the moment magnitude of total fault model will be 
 % applied in objective functions, otherwise individual moment magnitude of
 % each fault segment will be considered.
 %
 mwall     = 1;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if ~exist(configf,'file')
     %
     disp(['Please check ',configf,'!!!!']);
     return
 end
 %
 fid = fopen(configf);
 while feof(fid)~=1
     strline = fgetl(fid);
     %
     index   = strfind(strline,'# elastic constant: lambda'); 
     if isempty(index)==0
        lamda = str2double(fgetl(fid));
     end
     %
     index = strfind(strline,'# elastic constant: mu');
     if isempty(index)==0
        myu = str2double(fgetl(fid));
     end
     %
     index   = strfind(strline,'# Weight Matrix from VCM');
     if isempty(index)==0
        tlins = fgetl(fid);
        isvcm = textscan(tlins,'%f');
        isvcm = isvcm{1};
     end
     %
     index   = strfind(strline,'# number of particles');
     if isempty(index)==0
        psoPS = str2double(fgetl(fid));
     end
     %
     % Options for moment magnitudes
     % by Wanpeng Feng, @SYSU, 2018-08-05
     %
     index   = strfind(strline,'# the mode of moment magnitudes for use in constraints');
     % 1 in default
     if isempty(index)==0
        mwall = str2double(fgetl(fid));
     end
     %
     index   = strfind(strline,'# PSO: minimum distance among');
     if isempty(index)==0
        disofparts = str2double(fgetl(fid));
     end
     %
     %index   = findstr(strline,'# PSO: inversion time');
     index   = strfind(strline,'# PSO: maximum restart number');
     if isempty(index)==0
         ntimes = str2double(fgetl(fid));
     end
     %
     index   = strfind(strline,'# PSO: total iteration number (default: 25)');
     if isempty(index)==0
         iterations = str2double(fgetl(fid));
     end
     %
     % unit of displacements
     % m, cm and mm
     % 2018-08-03
     %
     index   = strfind(strline,'# unit of displacements:');
     if isempty(index)==0
         obsunit = fgetl(fid);
     end
     %
     %
     index   = strfind(strline,'# utmzone of displacements');
     if isempty(index)==0
         utmzone = fgetl(fid);
     end
     %
     index   = strfind(strline,'# SIMPLEX: maximum iteration number (default: 1000)');
     if isempty(index)==0
        itersSIM = str2double(fgetl(fid));
     end
     %
     index   = strfind(strline,'# SIMPLEX: Info to be shown (1: Yes; 0: No)');
     if isempty(index)==0
        display = str2double(fgetl(fid));
        if display<1
           display = 'off';
        else
           display = 'iters';
        end
     end
     %
     index   = strfind(strline,'# Monte Carlo Estimation: 1: Yes; 0: No');
     if isempty(index)==0
         ismc = str2double(fgetl(fid));
         if ismc ==1
            ismc = 'yes';
         else
            ismc = 'no';
         end
     end
     %
     index   = strfind(strline,'# Monte Carlo: Loop numbers, e.g. from to');
     % updated by FWP, @GU, 2014-05-18
     %
     if isempty(index)==0
         %
         mcloops = textscan(fgetl(fid),'%f %f');
         if isempty(mcloops{2})
             mcloops = [1,mcloops{1}];
         else
             mcloops = cell2mat(mcloops);
         end
     end
     %
     index   = strfind(strline,'# Monte Carlo: Directory of InputFiles');
     if isempty(index)==0
         mcdir = textscan(fgetl(fid),'%s');
     end
     %
     index   = strfind(strline,'# Monte Carlo: Directory of OutputFiles');
     if isempty(index)==0
         mcsave = textscan(fgetl(fid),'%s');
     end
     %
     % Modified by Feng, W.P, 2011-04-15, @ BJ
     % now the code has more wide application...
     %
     index   = strfind(strline,'oksar');
     if isempty(index)==0
         outpsoksar = textscan(fgetl(fid),'%s');
     end
     %
     index   = strfind(strline,'# output file name: matlab format');
     if isempty(index)==0
         outmatf = textscan(fgetl(fid),'%s');
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index = strfind(strline,'Number of inputfiles:');
     if isempty(index)==0
        temp  = textscan(strline,'%s %s %s %f');
        nfiles= temp{4};
        % disp(nfiles);
        % Jump two lines
        fgetl(fid);
        fgetl(fid);
        insfile= cell (nfiles,1);
        % updated by Wanpeng Feng, @SYSU, 2018-08-11
        % to allow controls on system shift estimation for each input file.
        %
        abccof = zeros(nfiles,4);
        weighs = zeros(nfiles,1);
        vcms   = cell(nfiles,1);
        fismc  = zeros(nfiles,1);
        for nobv = 1:nfiles
            cline = fgetl(fid);
            %
            temp = textscan(cline,'%s %s %s %s %s %s %s %s');
            abccof(nobv,1) = str2double(temp{1});
            abccof(nobv,2) = str2double(temp{2});
            abccof(nobv,3) = str2double(temp{3});
            abccof(nobv,4) = str2double(temp{4});
            %
            weighs(nobv)   = str2double(temp{5});
            vcms{nobv}     = temp{6};
            fismc(nobv)    = str2double(temp{7});
            insfile{nobv}  = temp{8};
        end
        %disp(vcms);
     end
     %
     index   = strfind(strline,'Number of faults:');
     if isempty(index)==0
         temp   = textscan(strline,'%s %s %s %f');
         nfault = temp{4};
         fpara  = zeros(nfault,10);
         scamin = zeros(nfault,10);
         scamax = zeros(nfault,10);
         InV    = zeros(nfault,10);
         forms  =  cell(nfault,10);
         locals   = zeros(nfault,1);
         rakeinfo = zeros(nfault,4);
         mwcoinfo = zeros(nfault,4);
         for ni=1:nfault
             %% Get the definine of the reference points
             % Jump 1 lines
             %disp(ni)
             fgetl(fid);
             fgetl(fid);
             fgetl(fid);
             slocal = fgetl(fid);
             slocal = textscan(slocal,'%s %s');
             locals(ni) = str2double(slocal{2});
             %Jump one line
             fgetl(fid);
             %
             for nj=1:8
                 tmp = fgetl(fid);
                 a = textscan(tmp,'%s %s %s %s %s %s');
                 if nj<8
                     fpara(ni,nj)   = str2double(a{1});
                     scamin(ni,nj)  = str2double(a{2});
                     scamax(ni,nj)  = str2double(a{3});
                     InV(ni,nj)     = str2double(a{4});
                     forms{ni,nj}   = a{5};
                 else
                     rake_value(ni) = str2double(a{1});
                     rake_isinv(ni) = str2double(a{4});
                     rakeinfo(ni,1) = rake_value(ni);
                     rakeinfo(ni,2) = str2double(a{2});
                     rakeinfo(ni,3) = str2double(a{3});
                     rakeinfo(ni,4) = str2double(a{4});
                 end
                 %
                 if nj == 8
                     tmppos = ftell(fid);
                     tmp    = fgetl(fid);
                     if isempty(strfind(tmp,'MW'))
                         fseek(fid,tmppos,'bof');
                     else
                         %mwcoinfo
                         % update by FWP, @ GU, 2013-06-14
                         % new factor for constaints....
                         %
                         a = textscan(tmp,'%s %s %s %s %s %s');
                         mwcoinfo(ni,1) = rake_value(ni);
                         mwcoinfo(ni,2) = str2double(a{2});
                         mwcoinfo(ni,3) = str2double(a{3});
                         mwcoinfo(ni,4) = str2double(a{4});
                     end
                     %
                 end
                 %
             end
             %
             %
         end
     end
 end
 %
 fclose(fid);
%
outrakeinfo = rakeinfo;
 
