function utmzone = sim_oksar2utm(oksarfile)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
% Created by Feng, W.P., @ GU, 2012-08-12
%
utmzone = [];
%oksarfile
fid = fopen(oksarfile,'r');
while ~feof(fid)
    tline = fgetl(fid);
    if isempty(strfind(tline,'UTM'))==0
        tmp     = textscan(tline,'%s %s','delimiter','---');
        utmzone = MCM_rmspace(tmp{1}{1});
    end
end
fclose(fid);
