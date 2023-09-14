%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% 
% Check box for distributed slip inversion
% by FWP, @GU, 2014-01-20
% 
%%%%%%%
% One input only...
%
inp    = 'psokinvSM_20140120_mc.cfg';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please keep the codes unchanged. 
[~,bname] = fileparts(inp);
outcheckbox_oksar = [bname,'_CB.oksar'];
inpscfg           = [bname,'_CB_OBS.cfg'];
smestcfg          = [bname,'_CB_SMEST.cfg'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scfg    = sim_getsmcfg(inp);
sminfo  = scfg;
[~,smdir] = fileparts(inp);
outmat    = [smdir,'/',sminfo.unifouts];
forsoksar = [smdir,'/',outcheckbox_oksar];
inunfoksar= sminfo.unifmat;
utmzone   = sim_oksar2utm(inunfoksar);
obsinp    = sminfo.unifinp;
% Read Config...
%
[psoPS,insfile,forms,outpsoksar,abccof,outmatf,fpara,...
          lamda,myu,scamin,scamax,InV,locals,weighs,vcms,...
          ntimes,iterations,display,itersSIM,ismc,mcloops,...
          mcdir,mcsave,fismc,disofparts,rake_value,rake_isinv,isvcm,outrakeinfo,mwcoinfo] = ...
          sim_readconfig(obsinp);
[input,am,inps,vcm,intabc,mweight] = ...
           sim_sminpudata(obsinp);
%
if ~exist(outmat,'file');
    ps_smest(inp);
end
%
if exist(outmat,'file')
    fpara = sim_smgetre(outmat);
    cfpara= fpara;
    cfpara(:,8) = 0;
    cfpara(:,9) = 0;
    depths = cfpara(:,5);
    udep   = unique(depths);
    %
    for ni = 1:2:numel(udep)-1
        %
        flag1 = cfpara(:,5)>=udep(ni);
        flag2 = cfpara(:,5)< udep(ni+1);
        flag  = flag1.*flag2;
        %
        cindex = find(flag==1);
        cx        = cfpara(cindex,1);
        [~,sinde] = sort(cindex);
        cindex    = cindex(sinde);
        %
        xscale = 8;
        for ncind = 1:xscale:numel(cindex)
            cfpara(cindex(ncind),8) = 1;
            cfpara(cindex(ncind),9) = 1;
            %
            if ncind+1 < numel(cindex)
                cfpara(cindex(ncind+1),8) = 1;
                cfpara(cindex(ncind+1),9) = 1;
            end
            if ncind+2 < numel(cindex)
                cfpara(cindex(ncind+2),8) = 1;
                cfpara(cindex(ncind+2),9) = 1;
            end
        end
        %
    end
end
sim_fpara2oksar(cfpara,forsoksar,utmzone);
sim_fig3d(cfpara);
%
nfile  = numel(insfile);
outins = insfile;
for ni = 1:nfile
    %
    cinp = insfile{ni}{1};
    [sdir,sname,sext] = fileparts(cinp);
    outins{ni} = {[sdir,'/',sname,'_CB',sext]};
    %
    input           = sim_inputdata(cinp);
    osim = sim_checkinp(forsoksar,input,'oksar',0);
    input(:,3) = osim;
    %
    sim_input2outfile(input,outins{ni}{1});
end
intabc(:,4) = mweight(:);
intabc(:,1) = intabc(:,2);
sim_invconfig(inpscfg,1,0,[],...
                       outins,[],[],[],[],...
                       [],[],[],[],...
                       [],[],[],[],[],[],intabc,[]);
%
sim_smcfg(smestcfg,scfg.unifmat,inpscfg,...
            scfg.unifwid,scfg.uniflen,...
            outmat,scfg.unifwsize,scfg.uniflsize,...
            scfg.unifsmps,scfg.bdconts,...
            scfg.minscale,scfg.rakecons,...
            scfg.abicang,scfg.listmodel,scfg.smoothing,...
            scfg.xyzindex,scfg.extendingtype,scfg.maxvalue,scfg.mcdir,...
            scfg.dampingfactor,scfg.earthmodel,[scfg.isfix,cell2mat(scfg.fixindex)]);
%
ps_smest(smestcfg,'invalg','BVLS');
