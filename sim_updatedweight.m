function dweight = sim_updatedweight(sdir)
%
% Developed by Feng, W.P., @NRCan, 2015-10-16
% get some information printted during processing
% by Wanpeng Feng, @NRCan, 2016-11-06
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
dfile = dir([sdir,'/weight.info']);
%
dweight = [];
if numel(dfile) > 0
    %
    cfile = [sdir,'/',dfile(1).name];
    %
    fid = fopen(cfile,'r');
    while ~feof(fid)
        tline = fgetl(fid);
        tmp = textscan(tline,'%s %f');
        %
        data = load(tmp{1}{1});
        dweight = [dweight;data(:,1).*0+tmp{2}];
        disp(['SIM_SMEST: Updating data weights now: ',tmp{1}{1}, ' ',num2str(tmp{2})])
    end
    fclose(fid);
    
end
%