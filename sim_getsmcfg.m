function sminfo = sim_getsmcfg(inpfile)
%
% Name+:
%      sim_getsmcfg
% Purpose:
%      to get the configure parameters for cfgfile.
% Input:
%      inpfile, the standard configure file for SM processing
%               You can use "sim_smcfg" to create a template.
%               It's necessary. If no input, only NULL will be returned.
% Output:
%      sminfo, the structure for configure to SM processing.
%
%************************************************
% Created by Feng, Wanpeng, IGP-CEA, July 2009
% Added some log information, 25th of Aug 2009, in Holand airport.
%************************************************
% Add a new keyword, istri, working for triangular dislocation inversion
% by Feng W.P, 2010-07-28
%
sminfo.smoothingmodel = 'XYZ';
sminfo.unit          = 'm';
sminfo.isokada3d     = 0;
sminfo.isopening     = 0;
sminfo.bname         = [];
sminfo.abicang       = 0;
sminfo.istri         = 0;
sminfo.rakecons      = [0,0,0];
sminfo.listmodel     = [0,0,0,0];
sminfo.smoothing     = 0;
sminfo.xyzindex      = {[0,1]};
sminfo.extendingtype = 'w';
sminfo.maxvalue      = 100000;
sminfo.mcdir         = 'NULL';
sminfo.dampingfactor = 1;
sminfo.isfix         = 0;
sminfo.fixindex      = {1;2};
sminfo.unifmat       = 'psoksar.mat';
sminfo.unifinp       = 'PSOKINV.cfg';
sminfo.unifwid       = '20';
sminfo.uniflen       = '20';
sminfo.unifwsize     = '1';
sminfo.uniflsize     = '1';
sminfo.unifsmps      =  '0.025  0.025  0.025';
sminfo.bdconts       = '0  0  0  0';
sminfo.earthmodel    = 'ELA';
sminfo.minscale      = '0';
sminfo.unifouts      = 'SMEST.mat';
sminfo.layeredfold   = 'N/A';
sminfo.refinesize    = 0;
sminfo.refoksar      = 'NULL';
sminfo.indist        = 'NULL';
sminfo.topdepth      = [];
sminfo.isuncertainty = 0;
sminfo.elasticALP    = 0.5;
%
%
if nargin < 1
    return
end
%
if isempty(inpfile)==1 || exist(inpfile,'file')==0
    %
    disp('The SM config file is not found. Please check it...');
    sminfo = [];
    %
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[t_mp,broot] = fileparts(inpfile);
sminfo.bname = broot;
%
fid = fopen(inpfile);
while feof(fid)~=1
    str = fgetl(fid);
    %
    index = strfind(str,'# Fixed model type');
    if isempty(index)==0
        tmp = fgetl(fid);
        temp = textscan(tmp,'%d %s','delimiter',';');
        %
        sminfo.isfix = temp{1};
        a            = temp{2}{1};
        ttemp = textscan(a,'%s','delimiter',',');
        ttemp = ttemp{1};
        mindex = cell(1);
        
        for nkk = 1:numel(ttemp)
            cindex = textscan(ttemp{nkk},'%f');
            mindex{nkk}=cell2mat(cindex);
        end
        sminfo.fixindex = mindex;
        
    end
    %
    index = strfind(str,'# Uniform Model MAT');
    if isempty(index)==0
        tmp = fgetl(fid);
        if strcmpi(tmp(1),'#')==1
            disp('Uniform Model MAT is not set.');
            return
        end
        sminfo.unifmat = tmp;
    end
    %
    index = strfind(str,'# Uniform Inversion CFG');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.unifinp = tmp;
    end
    %
    index = strfind(str,'# Distributed Model WIDTH(km)');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.unifwid=tmp;
    end
    % A given pre-set distributed slip geometry model
    % If it is set, single fault patch will be desperated...
    % updated by Wanpeng Feng, @Ottawa, 2016-11-06
    %
    index = strfind(str,'# Specify the discretized subfaults');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.indist=tmp;
    end
    %
    index = strfind(str,'# Eastic Property');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.elasticALP=str2double(tmp);
    end
    % 
    % 
    % Updated by FWP, @GU, 2014-09-09
    % estimation of slip Model uncertainty: yes or no?
    %
    index = strfind(str,'# Slip uncertainty estimated by the Monte-Carlo Method');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.isuncertainty=str2double(tmp);
    end
    %
    %
    index = strfind(str,'# Distributed Model Topdepth(km)');
    if isempty(index)==0
        tmp = fgetl(fid);
        tmp = textscan(tmp,'%f');
        sminfo.topdepth = tmp{1};
    end
    %
    % updated by Feng, Wanpeng, @NRCan, 2016-04-18
    % opening movements are allowed since this version. 
    %
    index = strfind(str,'# Flag of opening movements (Volcano modelling)');
    if isempty(index)==0
        tmp = fgetl(fid);
        tmp = textscan(tmp,'%d');
        sminfo.isopening = tmp{1};
    end
    %
    % updated by Wanpeng Feng, @NRCan, 2016-04-21 
    % surface topography variation should be taken into account in some
    % cases. So 3D okada92 will be used instead of okada85
    index = strfind(str,'# Flag of Okada3D');
    if isempty(index)==0
        tmp = fgetl(fid);
        tmp = textscan(tmp,'%d');
        sminfo.isokada3d = tmp{1};
    end
    
    % updated by FWP, @ GU, 2013-03-25
    %
    index = strfind(str,'# a listric fault modeling');
    if isempty(index)==0
        tmp              = fgetl(fid);
        atmp             = textscan(tmp,'%f %f %f %f');
        sminfo.listmodel = [atmp{1},atmp{2},atmp{3},atmp{4}];
    end
    %
    index = strfind(str,'# Distributed Model LENGTH(km)');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.uniflen=tmp;
    end
    %Threshold oksar, updated by FWP, @GU, 2014-08-14
    %
    index = strfind(str,'# Slip Inversion bound Constraints');
    %
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.refoksar=tmp;
    end
    %
    %
    % Added by Feng, WP., @UoG, 2014-07-17
    %
    index = strfind(str,'# Refine the Patch Size');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.refinesize= str2double(tmp);
    end
    % # the boundaries for maxima slip over the fault plane
    index = strfind(str,'# the boundary for maxima slip');
    if isempty(index)==0
        tmp = fgetl(fid);
        tmp = textscan(tmp,'%f\n');
        %
        sminfo.maxvalue=tmp{1};
    end
    %
    index = strfind(str,'# Distributed Model PatchSize(W)');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.unifwsize=tmp;
    end
    %
    % # Reference columns for smoothing
    index = strfind(str,'# Reference columns for smoothing');
    %
    if isempty(index)==0
        %
        if exist(sminfo.unifmat,'file')
            [t_mp,t_mp,ext] = fileparts(sminfo.unifmat);
            switch upper(ext)
                case '.MAT'
                    %
                    matpara = load(sminfo.unifmat);
                    tfpara  = matpara.outfpara{1};
                case '.OKSAR'
                    %
                    tfpara  = sim_oksar2SIM(sminfo.unifmat);
                case '.SIMP'
                    %
                    tfpara = sim_simp2fpara(sminfo.unifmat);
            end
            disp(upper(ext))
            nfault = numel(tfpara(:,1));
        else
            nfault = 1;
        end
        %
        cid    = ftell(fid);
        isjump = 0;
        %
        mxyzindex = cell(1);
        for ncol = 1:nfault
            if isjump == 0
                cgetl = fgetl(fid);
            end
            if isempty(strfind(cgetl,'#'))
                %
                tmp = textscan(cgetl,'%d');
                tmp = tmp{1};
                if numel(tmp)==0
                    tmp = 0;
                end
            else
                isjump = 1;
                fseek(fid,cid,'bof');
            end
            mxyzindex{ncol} = tmp;
        end
        sminfo.xyzindex=mxyzindex;
    end
    %
    index = strfind(str,'# Distributed Model PatchSize(L)');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.uniflsize=tmp;
    end
    % earth model
    index = strfind(str,'# Earth model:');
    if isempty(index)==0
        tmp = fgetl(fid);
        tmp = textscan(tmp,'%s');
        tmp = tmp{1};
        sminfo.earthmodel=tmp{1};
        if strcmpi(sminfo.earthmodel,'LAY')==1
           if numel(tmp)>1
               sminfo.layeredfold = tmp{2};
           else
               sminfo.layeredfold = 'LAYERED_DIR';
           end
        end
    end
    % # the model resolution determination by Monte Carlo analysis
    index = strfind(str,'# the model resolution determination by Monte Carlo analysis');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.mcdir = tmp;
    end
    %
    index = strfind(str,'# Smoothing model');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.smoothingmodel = tmp;
    end
    %
    index = strfind(str,'# Smoothing Wight Parameter');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.unifsmps = tmp;
    end
    index = strfind(str,'# Smoothing Parameter');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.unifsmps = tmp;
    end
    index = strfind(str,'# Depth-dependent patchsize');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.dampingfactor = str2double(tmp);
    end
    %
    index = findstr(str,'# Output Result');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.unifouts = tmp;
    end
    index = strfind(str,'# If we constrain the rake angle in DSM inversion ');
    if isempty(index) == 0
        %
        curpos          = ftell(fid);
        isjump  = 0;
        outtemp = [];
        while isjump == 0
            tlines          = fgetl(fid);
            if isempty(strfind(tlines,'#'))
                temp            = textscan(tlines,'%f%f%f\n');
                outtemp         = [outtemp;temp{1},temp{2},temp{3}];
                curpos          = ftell(fid);
            else
                isjump = 1;
                fseek(fid,curpos,'bof');
            end
        end
        sminfo.rakecons = outtemp;
    end
    %
    index = strfind(str,'# Minumn Moment Scale Wight Parameter');
    if isempty(index)==0
        tmp = fgetl(fid);
        sminfo.minscale = tmp;
    end
    %
    index = strfind(str,'# the extending type');
    if isempty(index)==0
        tmp = fgetl(fid);
        %
        sminfo.extendingtype = tmp;
    end
    %
    %
    index = strfind(str,'# Boundary zero constraints: default');
    if isempty(index)==0
        tmp            = fgetl(fid);
        sminfo.bdconts = tmp;
    end
    index = strfind(str,'# ABIC to estimation of DIP angles:');
    if isempty(index)==0
        tmp  = fgetl(fid);
        data = textscan(tmp,'%f %f %f %f %f');
        sminfo.abicang = [data{1},data{2},data{3},data{4},data{5}];
    end
    index = strfind(str,'If we adopt triangular dislocation model');
    if isempty(index)==0;
        tmp = fgetl(fid);
        sminfo.istri = str2double(tmp);
    end
    index = strfind(str,'Sensitivity analysis for smoothing');
    if isempty(index)==0;
        tmp = fgetl(fid);
        sminfo.smoothing = str2double(tmp);
    end
end
fclose(fid);
