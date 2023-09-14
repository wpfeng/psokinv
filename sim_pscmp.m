function data = sim_pscmp(inp,refoutfile,topdir,isupdate)
%
%
%
% Created by Feng, W.P., @ GU, 2012-08-10
% gr ,unit of micogal in default, 1 micogal = 10^(-8) m/s^2;
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4
    isupdate = 0;
end
%
if nargin < 3
    topdir = [pwd,'/'];
end
%
[t_mp,outdir] = fileparts(inp);
%
topoutdir  = [topdir,'/',outdir,'/'];
if ~exist(topoutdir,'dir')
    mkdir(topoutdir);
end
%
%
allfile = dir([topdir,'/',outdir,'/def_no*.dat']);

%disp(allfile)
%
if nargin < 2
    if numel(allfile) > 0
        refoutfile = allfile(1).name;
    else
        refoutfile = {'def_no0.dat'};
    end
end
%
%
logfile = [topdir,'/',outdir,'/',outdir,'.log'];
%
if ~exist([topdir,'/',outdir,'/',refoutfile{1}],'file') || isupdate == 1
    system(['echo ',inp,'|pscmp08 >',logfile]);
end
%
%
allfile = dir([topdir,'/',outdir,'/',refoutfile{1}]);
data    = cell(1);
for ni = 1:numel(allfile)
    cfile = [topdir,'/',outdir,'/',allfile(ni).name];
    %
    cdata = [];
    disp([' Reading ',num2str(cfile), ' now.']);
    fid = fopen(cfile,'r');
    fgetl(fid);
    %
    while ~feof(fid)
        tline = fgetl(fid);
        tmp   = textscan(tline,'%f');
        dtemp = tmp{1};
        cdata  = [cdata;dtemp(:)'];
    end
    fclose(fid);
    %
    % Convert from m/s^2 to mical
    % by fWP, @UoG,2014-06-26
    %
    if numel(cdata(1,:))==16
        cdata(:,16) = cdata(:,16).*10^8;
    end
    data{ni} = cdata;
end
%
data = cdata;