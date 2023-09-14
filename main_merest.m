function main_merest(inpfile,noise,nrand,which)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Model ERror ESTimation main_merest
 %
 if nargin < 1 || isempty(inpfile)==1 || exist(inpfile,'file')==0
     disp('main_merest(inpfile,noise,nrand)');
     disp('-> inpfile,inpfile');
     disp('-> noise, the noise level');
     disp('-> nrand, number of the noise set');
     disp('The inp file is not found. Please check it...');
    return
 end
 if nargin < 2 || isempty(noise)==1
    noise = 1;
 end
 if nargin < 3 || isempty(nrand)==1
    nrand = 1;
 end
 if nargin < 4 || isempty(which)==1
    which = 0;
 end
 %
 sminfo  = sim_getsmcfg(inpfile);
 matfile = sminfo.unifmat;
 outmat  = sminfo.unifouts;
 inf     = sminfo.unifinp;
 wid     = str2double(sminfo.unifwid);
 len     = str2double(sminfo.uniflen);
 px      = str2double(sminfo.uniflsize);
 py      = str2double(sminfo.unifwsize);
 tmp     = textscan(sminfo.unifsmps,'%f %f %f');
 alpha   = [tmp{1},tmp{2},tmp{3}];
 %
 %disp([wid,len,px,py]);
 %disp(alpha);
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
    [smest disf dismodel m dm cinput isabc abc] = sim_smestabc(matfile,inf,alpha,px,py,len,wid);%
 else
%     noise 
%     nrand
    [smest disf dismodel cinput isabc abc] = sim_merest(matfile,inf,alpha,px,py,len,wid,noise,nrand);%;
 end
 %
 %  whos smest
 
 lamda     = smest(:,:,1);
 std       = smest(:,:,2);
 roughness = smest(:,:,3);
 [a,bname] = fileparts(outmat);
 fpara     = [];
 %
 eval(['save ' outmat ' lamda std roughness disf dismodel m dm cinput abc isabc']);
 [models indexs] = sim_merstat(outmat,0);
 eval(['save ' outmat ' lamda fpara std roughness disf dismodel m dm indexs cinput abc isabc models']);
