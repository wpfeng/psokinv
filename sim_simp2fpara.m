function [fpara,zone,nf] = sim_simp2fpara(simp)
%
%
% Read fault slip from a simp file...
% by Feng, W.P., @ Yj, 2015-05-20
% All slip should be alwasy in meter. Noted by Wanpeng Feng, @Ottawa,
% 2017-04-16
%
fid = fopen(simp,'r');
fgetl(fid);
% Read UTM zone information
tmp  = fgetl(fid);
tmp  = textscan(tmp,'%s %s','delimiter',':');
zone = tmp{2}{1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read fault number
tmp = fgetl(fid);
tmp = textscan(tmp,'%s');
tmp = tmp{1};
nf = fix(str2double(tmp{5}));  % number of faults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jump one line...
fgetl(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fpara = textscan(fid,'%f %f %f %f %f %f %f %f %f %f\n');
fclose(fid);
%
fpara = cell2mat(fpara);