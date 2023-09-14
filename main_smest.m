function main_smest(inpfile,which)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %which ,1 for ABC estimation;
 %       0 for NONE ABC estimation
 %
 if nargin < 1 || isempty(inpfile)==1 || exist(inpfile,'file')==0
    disp('The inp file is not found. Please check it...');
    return
 end
 if nargin < 2 || isempty(which)==1
    which = 0;
 end
 %
 sminfo  = sim_getsmcfg(inpfile);
 matfile = sminfo.unifmat;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 matpara = load(matfile);
 tfpara  = matpara.outfpara{1};
 nf      = size(tfpara,1);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if sminfo.abicang(1)==0
    mdip = [1,tfpara(4)];
 else
    angs = sminfo.abicang(3):sminfo.abicang(4):sminfo.abicang(5);
    mdip = zeros(numel(angs),2);
    mdip(:,1) = sminfo.abicang(2);
    mdip(:,2) = angs(:);
 end
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
 bdconts = cell(1);
 txt     = {'U','B','L','R'};
 nbound  = 0;
 for ni = 1:4
     flag = sminfo.bdconts(ni);
     if flag ==0
        bdconts{ni} = txt{ni};
        nbound      = nbound+1;
     end
 end
 if nbound >0 
    bdconts = bdconts(1:nbound);
 else
    bdconts = [];
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
    [smest disf dismodel m dm cinput isabc abc osim input] = sim_smestabc(matfile,inf,alpha,px,py,len,wid,minscale,bdconts);%
 else
    [smest disf dismodel cinput isabc abc osim input mabicre]      = sim_smest(matfile,inf,alpha,px,py,len,wid,minscale,bdconts,mdip);%;
 end
 %
 lamda     = smest(:,1);
 std       = smest(:,2);
 roughness = smest(:,3);
 [a,bname] = fileparts(outmat);
 %
 %
 eval(['save ' outmat ' lamda std roughness disf dismodel m dm cinput abc isabc osim input mabicre']);
 [fpara index] = sim_resastat(outmat,[bname,'.psoksar'],0);
 eval(['save ' outmat ' lamda fpara std roughness disf dismodel m dm index cinput abc isabc osim input mabicre']);
