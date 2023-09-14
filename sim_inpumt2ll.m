function sim_inpumt2ll(dirs,zone)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
files = dir([dirs,'/*.inp']);
for ni = 1:numel(files)
    cfile = fullfile(dirs,files(ni).name);
    data = sim_inputdata(cfile);
    [lat,lon] = utm2deg(data(:,1).*1000,data(:,2).*1000,zone);
    data(:,1) = lon;
    data(:,2) = lat;
    [ipath,iname] = fileparts(cfile);
    outfile = fullfile(ipath,[iname,'_LL.inp']);
    fid = fopen(outfile,'w');
    fprintf(fid,'%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f\n',data');
    fclose(fid);
end
