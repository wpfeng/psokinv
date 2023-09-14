function [disf smodel dmodel] = sim_sm2R(smcfg)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Name+: 
%       sim_sm2R
% PURPOSE:
%       to estimate the resolution of the fault model
% Input:
%   <RAW version input variable>
%      matfile, the uniform fault model, mat format
%      inf,     the config file for uniform inversion
%      alpha,   the smoothing weight parameter
%      px,      x-step size, km
%      py,      y-step size, km
%      l,       the length along the strike direction
%      w,       the width along the dip direction
%  Latest version:
%      <smcfg, the configure file>
%*****************************************************
% Developed by Feng W.P, IGP-CEA, June 2009
% Added some usage info, Feng W.P, 12 AUG 2009
% Modified by Feng,Wanpeng, IGP-CEA, 25 AUG 2009, in Holand Airport.
%      -> change many input parameters into only smcfg file....
% 
if nargin<1
   disp('You must give the fullpath of the configue file for SM processing!');
   disf   = [];
   smodel = [];
   dmodel = [];
   return
end
sminfo  = sim_getsmcfg(smcfg);
matfile = sminfo.unifmat;
inf     = sminfo.unifinp;
alpha   = textscan(sminfo.unifsmps,'%s%s%s');
alpha   = alpha{1}{1};
%%%%%
pxsize  = textscan(sminfo.unifwsize,'%s%s%s');
pxsize  = pxsize{1}{1};
%%%%%
pysize  = textscan(sminfo.uniflsize,'%s%s%s');
pysize  = pysize{1}{1};
%%%%%
pw      = textscan(sminfo.unifwid,'%s%s%s');
pw      = pw{1}{1};
%%%%%
pl      = textscan(sminfo.uniflen,'%s%s%s');
pl      = pl{1}{1};
%%%%%
%
w       = str2double(pw);
l       = str2double(pl);
px      = str2double(pxsize);
py      = str2double(pysize);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mat   = load(matfile); 
fpara = mat.outfpara{1};
%
tmpabc= mat.abcsm{1};
abc   = [];
%
for ni = 1:numel(tmpabc)
    a = tmpabc(ni).a;
    b = tmpabc(ni).b;
    c = tmpabc(ni).c;
    tmp = [a,b,c];
    abc = [abc,tmp];
end
%
%disfpara,input,G,lap,lb,ub,am,cinput
[disf,input,G,lap]       = sim_pre4smest(fpara,inf,px,py,l,w,[],abc,0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
npara = size(G,2);
L     = zeros(npara);
indstr= 0;
for nii=1:numel(lap)
    tlap = lap{nii};
    cdim = size(tlap,1);
    L(indstr+1:indstr+cdim,indstr+1:indstr+cdim) = tlap;
    indstr = indstr+cdim;
    L(indstr+1:indstr+cdim,indstr+1:indstr+cdim) = tlap;
    indstr = indstr+cdim;
end
A            = [G;alpha.*L];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Referenced G. Funning paper(2005, JGR)
%
R            = (A'*A)\G'*G;%
ri           = diag(R);
disf(:,8)    = 1./sqrt(ri(1:size(disf,1)));
disf(:,9)    = 1./sqrt(ri(size(disf,1)+1:end));
smodel       = disf;
dmodel       = disf;
smodel(:,9)  = 0;
dmodel(:,8)  = 0;

