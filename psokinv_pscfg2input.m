function psokinv = psokinv_pscfg2input(cfg,nofault,noinp)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by FWP, @ BJ, 2011-03-03
% Original version 4 PSOKSAR-GUI
% Recompile to psokinv_pscfg2input by FWP, @ GU, 2013-03-29
%

if nargin < 1
    cfg = 'E:\EQw\PSOInversion\NewZealand\PSOKINV_6faults.cfg';
end
if nargin < 2
    nofault = 1;
end
if nargin < 3
    noinp = 1;
end
%%%
global rakeinfo
psokinv = psokinv_psokinv_variable();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(cfg)==0 || exist(cfg,'file')~=0
    fid = fopen(cfg,'r');
    fgetl(fid);
    tmp = fgetl(fid);
    ins = strfind(tmp,'General information: PS-OKINV parameter file');
    if isempty(ins)==0
        [psoPS,insfile,forms,outoksar,abccof,outmatf,fpara,...
            lamda,myu,scamin,scamax,InV,locals,weight,vcms,...
            ntimes,iterations,display,itersSIM,ismc,mcloops,...
            mcdir,mcsave,fismc,disofparts,rake_value,rake_isinv,...
            isvcm,rakeinfo] = ...
            sim_readconfig(cfg);
        %
        psokinv.fpara           = fpara;
        psokinv.numfaults       = size(fpara,1);
        psokinv.mcinversionloop = [mcloops{1},mcloops{2}];
        psokinv.rakes           = rakeinfo;
        psokinv.datamc          = fismc;
        psokinv.outdir          = mcsave;
        %mcdir{1}
        psokinv.mcinpdir = mcdir;
        switch upper(ismc)
            case 'YES'
                psokinv.ismcinversion = 1;
            case 'NO'
                psokinv.ismcinversion = 0;
        end
        psokinv.simpleiteration = itersSIM;
        switch upper(display)
            case 'OFF'
                psokinv.sampleinfoshow = 0;
            case 'ON'
                psokinv.sampleinfoshow = 1;
        end
        psokinv.psoiteration = iterations;
        %
        %
        psokinv.cfg        = cfg;
        faultintpara       = zeros(size(scamin,1),10,3);
        faultintpara(:,:,1)= fpara;
        faultintpara(:,:,2)= scamin;
        faultintpara(:,:,3)= scamax;
        psokinv.faultid    = nofault;
        psokinv.inpids     = noinp;
        psokinv.restartnum = ntimes;
        psokinv.vcms       = vcms;
        psokinv.weight     = weight;
        psokinv.locals     = locals;
        %
        psokinv.faultintpara = faultintpara;
        psokinv.clocal     = locals(nofault);
        psokinv.isinv      = InV;
        psokinv.faultminv  = scamin;
        psokinv.faultmaxv  = scamax;
        psokinv.lambda     = lamda;
        psokinv.mu         = myu;
        %
        psokinv.outmat     = outmatf{1}{1};
        psokinv.inpabc     = abccof;
        psokinv.particles  = psoPS;
        %
        for ni = 1:numel(insfile)
            insfile{ni} = insfile{ni}{1};
        end
        %
        psokinv.inps            = insfile;
        psokinv.outoksar        = outoksar{1}{1};
        psokinv.forms           = forms;
        psokinv.cforms          = forms(nofault,:);
        psokinv.cxrange         = [fpara(nofault,1),scamin(nofault,1),scamax(nofault,1)];
        psokinv.cyrange         = [fpara(nofault,2),scamin(nofault,2),scamax(nofault,2)];
        psokinv.cstrikerange    = [fpara(nofault,3),scamin(nofault,3),scamax(nofault,3)];
        psokinv.cdiprange       = [fpara(nofault,4),scamin(nofault,4),scamax(nofault,4)];
        psokinv.cdepthrange     = [fpara(nofault,5),scamin(nofault,5),scamax(nofault,5)];
        psokinv.clengthrange    = [fpara(nofault,6),scamin(nofault,6),scamax(nofault,6)];
        psokinv.cwidthrange     = [fpara(nofault,7),scamin(nofault,7),scamax(nofault,7)];
        psokinv.crakerange      = rakeinfo(nofault,1:3);
        psokinv.cisxinv         = InV(nofault,1);
        psokinv.cisyinv         = InV(nofault,1);
        psokinv.cisstrikeinv    = InV(nofault,3);
        psokinv.cisdipinv       = InV(nofault,4);
        psokinv.cislengthinv    = InV(nofault,7);
        psokinv.ciswidthinv     = InV(nofault,6);
        psokinv.cisdepthinv     = InV(nofault,5);
        %
        psokinv.cab             = abccof(noinp,2);
        psokinv.cc              = abccof(noinp,3);
        psokinv.cismc           = abccof(noinp,4);
        psokinv.cweight         = weight(noinp);
        %
        liststr = cell(size(faultintpara,1),1);
        for ni = 1:size(faultintpara,1)
            liststr{ni} = ['NO: ' num2str(ni,'%2d\n') ' Fault'];
        end
        %hid = findobj('tag','popupmenu_psokinv_list_of_faults');
        %set(hid,'String',liststr);
        %set(hid,'Value',1);
    else
        disp('UIpsokinv: PSOKINV-> The .cfg file you gave is not valid...');
        %psokinv
    end
end
%abccof
