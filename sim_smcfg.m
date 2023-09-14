function sim_smcfg(outnames,unmat,uncfg,wid,len,outmat,psw,psl,alphas,...
    bounds,minscale,rakecons,abic,listmodel,issensitiveanalysis,...
    xyzindex,extendingtype,maxvalue,mcdir,dampingfactor,earthmodel,...
    fixmodel,refinesize,thresholdoksar,topdepth,isuncertainty,alp,indist,...
    smoothingmodel,nolap)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% sim_smcfg(outnames,unmat,uninp,wid,len,outmat,psw,psl)
%   Produce a configure files for Smoothing parameters determination.
% Input:
%      outnames, configure file's name
%      psoksar,  the uniform model MAT file
%      uncfg,    the configure file for uniform inersion
%      wid,      the width size in distributed-slip inversion, 2*W(u)
%      len,      the length size in distributed-slip inversion, 2*L(u)
%      outmat,   the distributed slip inversion results, all you need
%      psw,      the patch size in dip direction
%      psl,      the patch size in strike direction
% Created by Feng W.P (skyflow2008@hotmail.com)
% Institute of Geophysics, Chinese Earthquake Administration
% Completed this work in University of Glasgow
% 3 July,2009 v0.1
% Now the latest version the output mat should be saved in the given dir..
% Version:2.1
% Now the latest version suppport change abic
% modified by Feng, Wanpeng, 2011-01-26
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now the latest version is v3.0 which supports the OKSAR format as input
% modified by Feng, Wanpeng, 2011-04-15
%
if nargin < 1 || isempty(outnames)==1
    outnames = 'psokinvSM.cfg';
end
if nargin < 2 || isempty(unmat)==1
    unmat = 'psoksar.mat';
end
if nargin < 3 || isempty(uncfg)==1
    uncfg = 'PSOKINV.cfg';
end
if nargin < 4 || isempty(wid)==1
    wid = 20;
end
if nargin < 5 || isempty(len)==1
    len = 20;
end
if nargin < 6 || isempty(outmat)==1
    outmat = 'SMEST.mat';
end
if nargin < 7 || isempty(psw)==1
    psw = '1';
end
if nargin < 8 || isempty(psl)==1
    psl = '1';
end
if nargin < 9 || isempty(alphas)==1
    alphas = num2str([0.025,0.025,0.025]);
end
if nargin < 10 || isempty(bounds)==1
    if isnumeric(len)
        nf = numel(len);
    else
        nf = numel(str2double(len));
    end
    %
    bounds = num2str(zeros(1,nf*4));
end
if nargin < 11 || isempty(minscale)==1
    minscale = '0';
end
if nargin < 12 || isempty(rakecons)==1
    rakecons = [0,0,0];
end
if nargin < 13 || isempty(abic)
    abic = num2str([0,0,0,0,0]);
end
if nargin < 14 || isempty(listmodel)
    listmodel = zeros(1,4);
end
if nargin < 15 || isempty(issensitiveanalysis)
    issensitiveanalysis = 1;
end
if nargin < 16 || isempty(xyzindex)
    xyzindex = {0 1 2 3};
end
if nargin < 17 || isempty(extendingtype)
    extendingtype = 'w';
end
if nargin < 18 || isempty(maxvalue)
    maxvalue = 100000;
end
if nargin < 19
    mcdir = 'NULL';
end
if nargin < 20
    dampingfactor = 1.2;
end
if nargin < 21
    earthmodel = 'ELA';
end
if nargin < 22
    fixmodel = [0,1,2];
end
if nargin < 23
    refinesize = 0;
end
if nargin < 24
    thresholdoksar = [];
end
if nargin < 25
    topdepth = '0'; 
end
if nargin < 26
    % the flag for slip uncertainty estimation...
    % 0: no and 1:yes...
    % updated by fWP,@ UoG, 2014-09-09
    %
    isuncertainty = 0;
end
if nargin < 27
    alp = '0.5';
end
if nargin < 28
    indist='NULL';
end
if nargin < 29
    smoothingmodel='XYZ';
end
if nargin < 30
    nolap=0;
end
%
%
isopening = 0;
isokada3d = 0;
%
fid = fopen(outnames,'w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Feng, W.P, Now the code supports OKSAR format...
% 20110415
fprintf(fid,'%s\n','# Uniform Model MAT ,OKSAR or PSOKSAR');              % the uniform fault model in matlab mat format
fprintf(fid,'%s\n',unmat);
fprintf(fid,'%s\n','# Uniform Inversion CFG');           % the configure file when uniform model inversion.
fprintf(fid,'%s\n',uncfg);
fprintf(fid,'%s\n','# Distributed Model WIDTH(km)');     % the width size   (km), when multiple faults, the width will be n*1.
fprintf(fid,'%s\n',num2str(wid));
fprintf(fid,'%s\n','# Distributed Model LENGTH(km)');    % the length size (km), the same with obve.
%
if isnumeric(len)
    len = num2str(len);
end
%
fprintf(fid,'%s\n',len);
fprintf(fid,'%s\n','# Distributed Model PatchSize(W)');  % same with obove
fprintf(fid,'%s\n',psw);
fprintf(fid,'%s\n','# Distributed Model PatchSize(L)');  % same with length
fprintf(fid,'%s\n',psl);
fprintf(fid,'%s\n','# Distributed Model Topdepth(km)');  % the length size (km), the same with obve.
fprintf(fid,'%s\n',topdepth);
fprintf(fid,'%s\n','# Smoothing Wight Parameter');       % you must give three
fprintf(fid,'%s\n',alphas);
fprintf(fid,'%s\n','# Smoothing model, e.g. XYZ, XY, XZ or YZ');       % you must give three
fprintf(fid,'%s\n',smoothingmodel);
fprintf(fid,'%s\n','# ABIC to estimation of DIP angles: e.g, nofault,nopara,minv,step,maxv');
%
if ischar(abic)
    %
    fprintf(fid,'%s\n',abic);
else
    fprintf(fid,'%s\n',num2str(abic));
end
%
fprintf(fid,'%s\n','# Boundary zero constraints: default, R L U B; 0 Yes,1 No');
fprintf(fid,'%s\n',bounds);
%
fprintf(fid,'%s\n','# Depth-dependent patchsize (damping factor)');
fprintf(fid,'%f\n',dampingfactor);
%
%Added by Feng W.P., @GU, 2014-07-17
fprintf(fid,'%s\n','# Refine the Patch Size based on the Sensitivity Analysis');
fprintf(fid,'%d\n', refinesize);
% 
fprintf(fid,'%s\n','# Specify the discretized subfaults');
fprintf(fid,'%s\n',indist);
%
fprintf(fid,'%s\n','# If we adopt triangular dislocation model...');
fprintf(fid,'%s\n','0');
% issensitiveanalysis
fprintf(fid,'%s\n','# Sensitivity analysis for smoothing');
fprintf(fid,'%f\n',issensitiveanalysis);
%
fprintf(fid,'%s\n','# Earth model: Elastic half-space(ELA) or layered(LAY)...');
fprintf(fid,'%s\n',earthmodel);
%
%
fprintf(fid,'%s\n','# Eastic Property: ALP, 0.5 in default');
fprintf(fid,'%s\n',alp);
%
% Flag of fault opening 
% updated by Feng, Wanpeng, @NRCan, 2016-04-18
%
fprintf(fid,'%s\n','# Flag of opening movements (Volcano modelling)');
fprintf(fid,'%d\n',isopening);
%
fprintf(fid,'%s\n','# Flag of Okada3D');
fprintf(fid,'%d\n',isokada3d);
%
fprintf(fid,'%s\n','# Reference columns for smoothing constraints->[1,2],[1,5],or,[2,5]');
%
for nkk = 1:numel(xyzindex)
    cindex = xyzindex{nkk};
    cstring = num2str(cindex(:)');
    fprintf(fid,'%s\n',cstring);
end
%
fprintf(fid,'%s\n','# the extending type: w,d or foc');
fprintf(fid,'%s\n',extendingtype);
fprintf(fid,'%s\n','# the boundary for maxima slip over the fault plane ');
fprintf(fid,'%d\n',maxvalue);
fprintf(fid,'%s\n','# the model resolution determination by Monte Carlo analysis ');
fprintf(fid,'%s\n',mcdir);
fprintf(fid,'%s\n','# Slip uncertainty estimated by the Monte-Carlo Method based on the RMS  ');
fprintf(fid,'%d\n',isuncertainty);
%
fprintf(fid,'%s\n','# Slip Inversion bound Constraints, a simp file or NULL ');
if isempty(thresholdoksar)
    thresholdoksar = 'NULL';
end
%
fprintf(fid,'%s\n',thresholdoksar);
%
%
fprintf(fid,'%s\n','# a listric fault modeling...');
if numel(listmodel) < 4
    a                     = zeros(1,4);
    a(1:numel(listmodel)) = listmodel;
    listmodel             = a;
end
%
fprintf(fid,'%d %d %d %d\n',listmodel(1:4));
fprintf(fid,'%s\n','# Fixed model type: Flag (0/1);index1,index2');
if isnumeric(fixmodel)
    outstr = [num2str(fixmodel(1)),';',num2str(fixmodel(2:end))];
else
    outstr = fixmodel;
end
fprintf(fid,'%s\n',outstr);
%
fprintf(fid,'%s\n','# If we constrain the rake angle in DSM inversion ... ');
for ni = 1:size(rakecons,1)
    fprintf(fid,'%s\n',num2str(rakecons(ni,:),'%d %d %d\n'));
end
fprintf(fid,'%s\n','# Minumn Moment Scale Wight Parameter');
fprintf(fid,'%s\n',minscale);
fprintf(fid,'%s\n','# Output Result');
fprintf(fid,'%s\n',outmat);
%

fclose(fid);




