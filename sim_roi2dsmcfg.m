function sim_roi2dsmcfg(in_roi,outdsmcfg,zone)
%
% Create a dsm configure file automatically
%
% Created by Wanpeng Feng, @NRCan, 2017-08-29
% 
if nargin < 2
    disp('sim_roi2dsmcfg(in_roi,outdsmcfg)')
    return
end
if nargin < 3
    zone = 'NONE';
end
phs = in_roi;
[fdir,fname,fext] = fileparts(phs);
%
if isempty(fdir)
    fdir = '.';
end
%
inc = dir([fdir,'/',fname,'.inc']);
azi = dir([fdir,'/',fname,'.azi']);
if length(inc) == 0 %#ok<ISMT>
    inc = dir([fdir,'/*.inc']);
    azi = dir([fdir,'/*.azi']);
end
inc = [fdir,'/',inc(1).name];
azi = [fdir,'/',azi(1).name];
%
if strcmpi(zone,'NONE')
    zone = MCM_rmspace(sar_rsc2zone([phs,'.rsc'],'cc'));
end
outname = fname;
sim_dsmcfg(outdsmcfg,'unwfile',{phs},'incfile',{inc},'azifile',{azi},...
                     'outname',{outname},'zone',zone);
%