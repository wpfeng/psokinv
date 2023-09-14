function [fpara,zone] = sim_readdlc(indlc)
%
%
% read slip model from Yuri's DLC slip model
%
fpara = [];
fid   = fopen(indlc,'r');
%
% jump a line
fgetl(fid);
%
while ~feof(fid)
    tline = fgetl(fid);
    tmp   = textscan(tline,'%f');
    tmp   = tmp{1};
    cfpara = [tmp(2),tmp(3),tmp(5),tmp(6),tmp(4),tmp(8),tmp(7),tmp(9),tmp(10),tmp(11)];
    fpara  = [fpara;cfpara];
end
%
fclose(fid);
%
mlon = mean(fpara(:,1));
mlat = mean(fpara(:,2));    
%
[x0,y0,zone] = deg2utm(mlat,mlon);
%
[x,y]      = deg2utm(fpara(:,1),fpara(:,2),zone);
fpara(:,1) = x./1000;
fpara(:,2) = y./1000;
%
% fpara = sim_fparaconv(fpara,1,0);