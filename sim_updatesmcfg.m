function sim_updatesmcfg(incfg,outcfg,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Developed by FWP, @IGPP of SIO, UCSD, 2013-11-28
%
%
%
if nargin < 1
    info   = sim_getsmcfg;
    fnames = fieldnames(info);
    for ni = 1:numel(fnames)
        disp(fnames{ni});
    end
    return
end
if nargin < 2
    outcfg = incfg;
end
%
%
info  = sim_getsmcfg(incfg);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v = sim_infovarmag(varargin);
for j = 1:length(v)
    eval(v{j});
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfixindex = [num2str(info.isfix),';'];
fixindex = info.fixindex;
for ni = 1:numel(fixindex)
   tmp = fixindex{ni};
   if ni < numel(fixindex)
       postfix = ',';
   else
       postfix = '';
   end
   outfixindex = [outfixindex,num2str(tmp'),postfix];
end
sim_smcfg(...
    outcfg,... configure file name!!!
    info.unifmat,...     input fault model: .mat, .oksar or .psoksar!!!!
    info.unifinp,...
    info.unifwid,....
    info.uniflen,...
    info.unifouts,...
    info.unifwsize,...
    info.uniflsize,...
    info.unifsmps,...  alpha for smoothing...
    info.bdconts,...
    info.minscale,...
    info.rakecons,...
    info.abicang,...abic,...
    info.listmodel,...issensitiveanalysis,...
    info.smoothing,...
    info.xyzindex,...
    'w',...extendingtype,
    info.maxvalue,...
    info.mcdir,....
    info.dampingfactor,....
    info.earthmodel,...
    outfixindex);
