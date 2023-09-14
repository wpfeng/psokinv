function sim_sm2oksar(matfile,outoksar,cdip,thr)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
% Created by Feng,W.P.,@ GU, 2012-09-27
%
if nargin < 3
    cdip = [];
end
if nargin < 4
    thr = 10;
end
%
outmat = load(matfile);
%
fpara = sim_smgetre(matfile,cdip,3,thr);
uzone = outmat.utmzone;
%
[bdir,bname] = fileparts(outoksar);
if ~exist(bdir,'dir')
    mkdir(bdir);
end
sim_fpara2oksar(fpara,outoksar,uzone);
