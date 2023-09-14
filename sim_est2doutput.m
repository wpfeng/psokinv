function data = sim_est2doutput(index,givendir,searchmat,newweights)
%
%
% Developed by Feng, W.P.,@ Yj, 2015-05-27
% Udpated by Feng, W.P., @ Ottawa, 2015-10-17
%
if nargin < 3
    searchmat = [];
end
if nargin < 4
    newweights = [];
end
%
if nargin < 2
    givendir = pwd;
end
%
data = [];
dirs = dir('*.cfg');
%
for ni = 1:numel(dirs)
    %
    cdir          = dirs(ni).name;
    [t_mp,bdir]   = fileparts(cdir);
    info          = sim_getsmcfg(cdir);
    if ~isempty(searchmat)
        outmat = searchmat;
    else
        outmat = info.unifouts;
    end
    %
    cd(bdir);
    %
    if ~exist(info.unifmat,'file')
        %
        [t_mp,bname,bext] = fileparts(info.unifmat);
        cfile = [givendir,bname,bext];
    else
        cfile = info.unifmat;
    end
    % disp(cfile);
    fpara      = sim_oksar2SIM(cfile);
    cvalue     = fpara(1,index);
    cdata      = sim_sortsmre(outmat,0,newweights);
    %
    data       = [data;cdata(:,1).*0+cvalue,cdata];
    %
    cd ..
    %
end
%
    
    
    
    
   
    
    
    
    
    
   






















