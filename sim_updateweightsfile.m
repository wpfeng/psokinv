function sim_updateweightsfile(infile,newweights)
%
%
% by feng, w.p., @Ottawa, 2015-10-17
%
fid      = fopen(infile,'r');
outfiles = [];
ni       = 0;
while ~feof(fid)
    tline = fgetl(fid);
    tmp   = textscan(tline,'%s %f');
    ni = ni + 1;
    outfiles{ni} = tmp{1}{1};
end
fclose(fid);
%
fid = fopen(infile,'w');
%
for nk = 1:ni
    fprintf(fid,'%s %f\n',outfiles{nk},newweights(nk));
end
fclose(fid);
%