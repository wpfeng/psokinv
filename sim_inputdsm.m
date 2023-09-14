function dsmcfg = sim_inputdsm(cfgfile)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% 
% Name+:
%       sim_inputdsm(cfgfile)
% Purpose:
%       Input configure file for downsampling
% Input:
%       cfgfile, the full path of configure file
%*************************************************
% Created by Feng, Wanpeng, IGP-CEA,Aug 2009,in GLASGOW
% Added some log info, 25 AUG 2009, in Holand airport
%
dsmcfg.alg  = 'UNIFORM';
dsmcfg.minb = [];
dsmcfg.maxb = [];
dsmcfg.smp  = [];
dsmcfg.suby = [];
dsmcfg.suby = [];
dsmcfg.psoksar = [];

if nargin<1 || exist(cfgfile,'file')==0
   disp('dsmcfg = sim_inputdsm(cfgfile)');
   disp('cfgfile, configure file for batch Job of downsampling insar data');
   disp('You must input a configure file...');
   %
   dsmcfg = [];
   return
end
fid = fopen(cfgfile);
while feof(fid)==0
    tline = fgetl(fid);
    if isempty(findstr(tline,'# Algorithm to downsample data'))==0
       dsmcfg.alg = fgetl(fid);
    end
    %
    if isempty(findstr(tline,'# Minimum blocksize'))==0
       dsmcfg.minb = fgetl(fid);
    end
    %
    if isempty(findstr(tline,'# Maximum blocksize'))==0
       dsmcfg.maxb = fgetl(fid);
    end
    %
    if isempty(findstr(tline,'# Smoothing Parameter'))==0
       dsmcfg.smp = fgetl(fid);
    end
    %
    if isempty(findstr(tline,'# threshold of data resolution'))==0
       dsmcfg.threshold = fgetl(fid);
    end
    %
    if isempty(findstr(tline,'# Uniform model parameters'))==0
       dsmcfg.psoksar= fgetl(fid);
    end
    %
    if isempty(findstr(tline,'# Length of Distributed model(km)'))==0
       dsmcfg.flen= fgetl(fid);
    end
    %
    if isempty(findstr(tline,'# Width of Distributed model(km)'))==0
       dsmcfg.fwid= fgetl(fid);
    end
    %
    if isempty(findstr(tline,'# patch-size along strike of Distributed model(km)'))==0
       dsmcfg.subx= fgetl(fid);
    end
    %
    if isempty(findstr(tline,'# patch-size along dip of Distributed model(km)'))==0
       dsmcfg.suby= fgetl(fid);
    end
    %
%     if isempty(findstr(tline,'# patch-size along dip of Distributed model(km)'))==0
%        dsmcfg.suby= fgetl(fid);
%     end
    %
    if isempty(findstr(tline,'# the variance value above the block which the image will be subdivided'))==0
       dsmcfg.minvar= fgetl(fid);
    end
    if isempty(findstr(tline,'# the variance value above the block which the image will be nulled'))==0
       dsmcfg.maxvar= fgetl(fid);
    end
    if isempty(findstr(tline,'# Propotion of non-zero elements'))==0
       dsmcfg.fractor= fgetl(fid);
    end
    if isempty(findstr(tline,'# Display the result,e.g 1(yes)or 0(no)'))==0
       dsmcfg.isdisp= str2double(fgetl(fid));
    end
    if isempty(findstr(tline,'# projection in UTM, as "UTM50S"'))==0
       dsmcfg.zone= fgetl(fid);
    end
    if isempty(findstr(tline,'# the saving directory to inp file'))==0
       dsmcfg.outdir= fgetl(fid);
    end
    if isempty(findstr(tline,'# number of InSAR files'))==0
       dsmcfg.numf= str2double(fgetl(fid));
       fgetl(fid);
       fgetl(fid);
       unwfile = cell(1);
       incfile = cell(1);
       azifile = cell(1);
       outname = cell(1);
       for nj=1:dsmcfg.numf
           tmp  = fgetl(fid);
           temp = textscan(tmp,'%f%s%s%s%s');
           %whos temp
           unwfile{nj} = temp{2}{1};
           incfile{nj} = temp{3}{1};
           azifile{nj} = temp{4}{1};
           outname{nj} = temp{5}{1};
       end
       dsmcfg.unwfile = unwfile;
       dsmcfg.incfile = incfile;
       dsmcfg.azifile = azifile;
       dsmcfg.outname = outname;
    end
 end
