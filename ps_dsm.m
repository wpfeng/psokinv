function ps_dsm(dsmcfg)
 %
 %
 % +Usage:
 %      Downsampling phase by an way you like from three methods.
 % +Input:
 %      dsmcfg, the configure file for down-sampling
 %    fixangle, it's valid if you chose DBASE method.
 %       invis, is's also working for DBASE method. If you open this
 %              switcher, the data will be more density in the far field, not in
 %              near.
 % +Output:
 %    the data will be extract into some ascii files with region info.
 %
 % Created by Feng, Wanpeng,IGP/CEA, 2009/06
 % Updated by Feng, Wanpeng,IGP/CEA, 2010/07
 %
 % Version: 2.1
 %*************************************************************************
 % Modified by Feng, Wanpeng, 2011-04-15, @ BJ
 % support different fault format
 % Version 3.0
 %  
 %*************************************************************************
 % Modified by Feng, Wanpeng, 2011-04-25, @BJ
 %  -> add datatype, specify the date type, phase, azi-offset or rng-offset
 %*************************************************************************
 % Add a new control, outproj, by Feng, W.P, 2011-05-05, @BJ
 %  -> OUTPROJ, the default setting is "UTM"
 %
 %*************************************************************************
 % Add 'topdepth', which will be used in fault discretization. 
 % by Wanpeng Feng, @CCRS/NRCan, 2017-10-26
 %
 
 global isinv datatype OUTPROJ earthmodel dsminfo lookingdir outputunit extendingtype
 %%%%%%%%%%%%%%%%%%%%%%%%%
 %version = 2.1;
 %version = 3.0 ;    %2011-04-15, Feng, W.P, @ BJ
 %version    = 4.5;   %2012-10-28, FWP, @ GU
 version    = 5.0;   % @NRCan, 2015-12-02, FWP
 topdepth   = 0.;    % @NRCan, 2017-10-26, FWP
 %
 %
 earthmodel = 'ELA';
 if nargin < 1
    disp('ps_dsm(dsmcfg,mode[insar or azi])');
    return
 end
 % 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Fix dip angle with size of 90.
 %
 invis    = 0;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(['Now down-sampling phase by version ' num2str(version)]);
 %
 % Modified by Feng, W.P, 2011-04-15, @ BJ
 %  change the function's name with sim_getdsmcfg. Now it's esier to
 %  remember.
 %
 dsminfo    = sim_getdsmcfg(dsmcfg);
 % fpara = sim_openfault(dsminfo.psoksar);
 % added by FWP, @CCRS/NRCan, 2017-10-26
 % extendingtype will be needed for the Rbased algarithm since now. 
 %
 extendingtype   = dsminfo.extendingtype;
 %
 % Change the following line to a new mdoel
 % obsrevation model, e.g. range or azimuth will be working since this
 % version
 % by Wanpeng Feng, @NRCan, 2017-04-15
 %
 datatype   = dsminfo.dataformat;
 % datatype = dsminfo.obsmodel;
 lookingdir = dsminfo.lookingdir;
 OUTPROJ    = 'LL';%dsminfo.zone;
 %
 switch upper(dsminfo.unit)
     %
     case 'M' 
         outputunit = 1.;
     case 'CM'
         outputunit = 100.;
     case 'MM'
         outputunit = 1000.;
     %    
 end
 % a directory to save output
 sdir     = dsminfo.outdir;
 %
 if ~exist(sdir,'dir')
     mkdir(sdir);
 end
 %
output_path    = dsminfo.outdir;                   %
qtblocksize    = str2double(dsminfo.minb);         % minimum block size for quadtree
qtmaxblocksize = str2double(dsminfo.maxb);         % maximum block size (in pixels)
qtminvar       = str2double(dsminfo.minvar);       % a value of variance above which the image will be subdivied.
qtmaxvar       = str2double(dsminfo.maxvar);       % a value of variance above which the image will be nulled.
qtfrac         = str2double(dsminfo.fractor);      % propotion of non-zero elements per block
isdisp         = dsminfo.isdisp;                   % 1 show the down-sampling result
zone           = dsminfo.zone;                     % if the projection of InSAR is LL, the zone is necessary.e.g, "UTM50S"
%
if isempty(zone)~=1
    %
    czone = MCM_rmspace(zone);
    zone  = [czone(end-2:end-1),' ',czone(end)];
end
%
if strcmpi(dsminfo.alg,'uniform')==1 || strcmpi(dsminfo.alg,'quad')==1
   %
   sim_quadfunc(dsminfo.unwfile,dsminfo.outname,dsminfo.incfile,dsminfo.azifile,...
                'isdisp',isdisp,'zone',zone,'qtfrac',qtfrac,'qtmaxvar',qtmaxvar,...);
                'qtminvar',qtminvar,'qtmaxblocksize',qtmaxblocksize,...
                'qtblocksize',qtblocksize,'output_path',output_path);
else
   % Modified by Feng, W.P,2011-04-15, @ BJ
   % to allow different fault formats, OKSAR or PSOKSAR
   % dsmcfg.psoksar
   %
   %[tmp,tmp,postfix] = fileparts(dsminfo.psoksar);
   %
   %dsmcfg.psoksar
   fpara = sim_openfault(dsminfo.psoksar);
   %
   nf    = size(fpara,1);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   threshold       = textscan(dsminfo.threshold,'%f',nf);      % the value close to zero, then the number of data will be high
   threshold       = threshold{1};
   lamd            = textscan(dsminfo.smp,'%f',nf);            % as above, decide the number of data.
   lamd            = lamd{1};                                 %
   lamd            = lamd';
   subxsize        = textscan(dsminfo.subx,'%f',nf);           %
   subxsize        = subxsize{1};                             % Distributed Slip Model's subfault size in STRIKE direction
   subxsize        = subxsize';
   subysize        = textscan(dsminfo.suby,'%f',nf);           %
   subysize        = subysize{1};                             % Distributed Slip Model's subfault size in DIP direction
   subysize        = subysize';
   flen            = textscan(dsminfo.flen,'%f',nf);
   flen            = flen{1};
   flen            = flen';
   fwid            = textscan(dsminfo.fwid,'%f',nf);
   fwid            = fwid{1};
   fwid            = fwid';
   topdepth        = fwid * 0. + topdepth;
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   cfpara = fpara;
   for ni = 1:numel(fpara(:,1))
       cfpara(ni,:) = sim_fpara2rand_UP(fpara(ni,:),10,10);
   end
   %
   fpara = cfpara;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   qtminvar = str2double(dsminfo.minvar);
   qtmaxvar = str2double(dsminfo.maxvar);
   %
   sim_rbfunc(fpara,dsminfo.unwfile,dsminfo.outname,dsminfo.incfile,dsminfo.azifile,...
              'threshold',threshold,'lamd',lamd,'subxsize',subxsize,'subysize',subysize,...
              'flen',flen,'fwid',fwid,'minblocksize',qtblocksize,'zone',zone,...
              'qtminvar',qtminvar,'qtmaxvar',qtmaxvar,...
              'maxblocksize',qtmaxblocksize,'isdisp',isdisp,'output_path',output_path)
   %
end
