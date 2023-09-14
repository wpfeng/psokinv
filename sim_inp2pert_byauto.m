function sim_inp2pert_byauto(inp)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
% Developed by FWP, @GU, 2014-01-20
%
if nargin < 1
    disp('sim_inp2pert_byauto(inp);');
    inp = 'PSOKINV_6tracks_msk_asc.cfg';
    inp = 'PSOKINV_6tracks_msk_gps.cfg';
end
scale = 0.01;
%
%
[psoPS,insfile,forms,outpsoksar,abccof,outmatf,fpara,...
          lamda,myu,scamin,scamax,InV,locals,weighs,vcms,...
          ntimes,iterations,display,itersSIM,ismc,mcloops,...
          mcdir,mcsave,fismc,disofparts,rake_value,rake_isinv,isvcm,outrakeinfo,mwcoinfo] = ...
          sim_readconfig(inp);
%
s1 = mcloops{1};
s2 = mcloops{2};
%
odir = mcdir{1}{1};
if ~exist(odir,'dir')
    mkdir(odir);
end
%
%
for ni = 1:numel(insfile)
    cinp = insfile{ni}{1};
    %
    [~,bname,cext] = fileparts(cinp);
    %
    %
    %
    [data,np] = sim_inputdata(cinp);
    noisemc   = (rand(np,s2)-0.5).*2.*scale;
    outdata   = data;
    for nj = s1:s2
        outfile = [odir,'/MC_',num2str(nj),'_',bname,cext];
        %
        %exist(outfile,'file')
        if exist(outfile,'file')==0
            disp([outfile, ' does not exist!!!']);
            outdata(:,3) = data(:,3) + noisemc(:,nj);
            sim_input2outfile(outdata,outfile);
        end
    end
    %
end
%
