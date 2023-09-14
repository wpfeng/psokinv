function ps_triest(cfgfile,typejoint,invalg,which)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Name+:
 %      ps_smest, distributed Slip model estimation...
 % Purpose: 
 %      to estimate the distributed slip model
 % Input:
 %      cfgfile, the configure file, necessary to work correctly.
 %      typejoint, if there are more one fault patch,(different strike),
 %                 then this keyword will tell you if the tow parts join
 %                 together.
 %      which,   the flag if the ramp parameter, ABC, will be estimate.
 %*********************************************
 % Created by Feng, W.P, IGP-CEA, JULY, 2009
 % Added log information, by Feng, W.P, 25 Aug 2009, in Holand Airport.
 %%%%%%%
 % Improved by Feng W.P, Now the program will save the G matrix for deep
 % analysis...
 % -> 2010-05-01,IGP-CEA, in Beijing, China
 %*************************************************************************
 %       0 for NONE ABC estimation
 % -> 2010-07-14,IGP-CEA, in Beijing, China
 %  add a new choice for linear least-square problem.
 %  now the code supports thress algorithms for linear problem...
 %*************************************************************************
 % Modified from ps_smest. Usage for triangular model
 % by W.P Feng
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 global isjoint cfgname cfgpath invmethod
 if nargin < 1 || isempty(cfgfile) == 1 || exist(cfgfile,'file') == 0
     disp('ps_triest(smcfg,typejoint,which)');
     disp('The cfg file is not found. Please check it...');
    return
 end
 if nargin < 2 || isempty(isjoint)==1
    typejoint = 0;
 end
 if nargin < 3 || isempty(invalg)==1
     invalg   = 'cgls';
 end
 if nargin < 4 || isempty(which)==1
    which     = 0;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 isjoint   = typejoint;
 invmethod = invalg;
 sminfo    = sim_getsmcfg(cfgfile);
 matfile   = sminfo.unifmat;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [a,b,ext] = fileparts(matfile);
 if strcmpi('.MAT',ext)==1
    matpara = load(matfile);
    tfpara  = matpara.outfpara{1};
 else
    tfpara  = sim_psoksar2SIM(matfile);
 end
 nf                = size(tfpara,1);
 [cfgpath,cfgname] = fileparts(cfgfile);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if sminfo.abicang(1)==0
    mdip = [1,4,tfpara(1,4),4];
 else
    angs = sminfo.abicang(3):sminfo.abicang(4):sminfo.abicang(5);
    mdip = zeros(numel(angs),1);
    mdip(:,1) = sminfo.abicang(1);
    mdip(:,2) = sminfo.abicang(2);
    mdip(:,3) = angs(:);
 end
 %sminfo
 outmat  = sminfo.unifouts;
 inf     = sminfo.unifinp;
 swid    = textscan(sminfo.unifwid,'%f',nf);
 wid     = swid{1};
 slen    = textscan(sminfo.uniflen,'%f',nf);
 len     = slen{1};
 spx     = textscan(sminfo.uniflsize,'%f',nf);
 px      = spx{1};
 spy     = textscan(sminfo.unifwsize,'%f',nf);
 py      = spy{1};
 tmp     = textscan(sminfo.unifsmps,'%f %f %f');
 alpha   = [tmp{1},tmp{2},tmp{3}];
 minscale= str2double(sminfo.minscale);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 bnds    = textscan(sminfo.bdconts,'%f',nf*4);
 bnds    = bnds{1};
 bnds    = reshape(bnds,4,nf);
 bdconts = cell(1);
 txt     = {'L','R','U','B'};
 bdcontsc= cell(1);
 for nof=1:nf
   nbound = 0;
   for ni = 1:4
       flag = bnds(ni,nof);
       if flag ==1
          nbound      = nbound+1;
          bdconts{nbound} = txt{ni};
       end
   end
   if nbound == 0
      bdconts = [];
   end
   bdcontsc{nof} = bdconts;
   bdconts       = [];
   a = bdcontsc{nof};
   b = a;
   if numel(a)>0;
       for ni=1:numel(a)
           if strcmp(a{ni},'B')==1
              b{ni} = 'B';
           end
           if strcmp(a{ni},'U')==1
              b{ni} = 'U';
           end
       end
   end
   disp(['The NO:' num2str(nof) ' fault with boudary constraint->']);
   if size(b,2)>0
      for nb=1:size(b,2)
          if strcmpi(b{nb},'U')
             b{nb} = 'PS_SMEST-> The Upside    will not be constraint with ZEROS.!';
          end
          if strcmpi(b{nb},'B')
             b{nb} = 'PS_SMEST-> The Bottom    will not be constraint with ZEROS.!';
          end
          if strcmpi(b{nb},'L')
             b{nb} = 'PS_SMEST-> The LeftSide  will not be constraint with ZEROS.!';
          end
          if strcmpi(b{nb},'R')
             b{nb} = 'PS_SMEST-> The RightSide will not be constraint with ZEROS.!';
          end
          disp(b{nb});
      end
   end
 end
 %
 %
 if exist(matfile,'file')==0
    disp(['The uniform model file,' matfile ', is not found.']);
    return
 end
 if exist(inf,'file')==0
    disp(['The uniform inf file,' inf ', is not found.']);
    return
 end
 m  = [];
 dm = [];
 if which ==1
    [smest disf dismodel m dm cinput isabc abc osim input] = sim_smestabc(matfile,inf,alpha,px,py,len,wid,minscale,bdcontsc);%
 else
    [smest disf dismodel cinput isabc abc osim input mabicre] = sim_smest(matfile,inf,alpha,px,py,len,wid,minscale,bdcontsc,mdip);%;
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 lamda     = smest(:,1);
 std       = smest(:,2);
 roughness = smest(:,3);
 [a,bname] = fileparts(outmat);
 %
 [outdir,outname,ext] = fileparts(outmat);
 outmat = [outname,ext];
 disp(['Now the result have been saved into ' [cfgname,'/',outmat] '!']);
 eval(['save ' [cfgname,'/'] outmat ' lamda std roughness disf dismodel m dm cinput abc isabc osim input mabicre mdip']);
 [fpara index] = sim_resastat([cfgname,'/',outmat],[bname,'.psoksar'],0);
 eval(['save ' [cfgname,'/'] outmat ' lamda fpara std roughness disf dismodel m dm index cinput abc isabc osim input mabicre mdip']);
