function [outfiles,nfile] = sim_inpoutput(data,outname)
%
% create inp files with data number limitation for each inp file.
% Created by FWP, @UoG, 2012-10-31
% 
[bdir,bname,ext] = fileparts(outname);
%
if isempty(bdir)
    bdir = '.';
end
%
numfile = 0;
%
outfiles = cell(1);
nfile    = 0;
for ni=1:5000:numel(data(:,1))
    xs = ni;
    xe = ni + 5000 -1;
    %
    if xe > numel(data(:,1))
        xe = numel(data(:,1));
    end
    %
    numfile  = numfile + 1;
    coutname = [bdir,'/',bname,'_',num2str(numfile),ext];
    nfile    = nfile+1;
    outfiles{nfile} = coutname;
    fid      = fopen(coutname,'w');
    fprintf(fid,'%12.6f %12.6f %18.14f %12.6f %12.6f %12.6f %12.6f\n',data(xs:xe,:)');
    fclose(fid);
end
