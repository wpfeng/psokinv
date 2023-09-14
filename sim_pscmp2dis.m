function outdata = sim_pscmp2dis(oksar,greendir,data,varargin)
%
%
% Predict surface deformation with a given slip model under a layered earth
% structure.
% oksar,    slip model in either oksar format or simp format
% greendir, response of mulptile crust layers
% data,     observation points, (i.e. long,lat)
%
% Deveoped by Wanpeng Feng, @ Ottawa, 2015-10-12
%
%
isupdate    = 0;
ndata       = numel(data(:,1));
numcal      = 0;
outdir      = ['Sim_PSCMP_',date];
pscmp_isove = 0;
utmproj     = [];
thre        = [2,2];                % size control for oversampling 
days        = 0;
icmpflag    = [1 0.600000 0.000000 126.0262 89.99000 180.000000 0.000000 0.000000 0.000000];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ni = 1:2:numel(varargin)
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if ~exist(outdir,'dir')
    mkdir(outdir);
end
% [t_mp,rootgreendir] = fileparts(greendir);
% topdir = pwd;
for ni = 1:5000:ndata
    if ni+5000-1 < ndata
        endind = ni+5000-1;
    else
        endind = ndata;
    end
    cdata  = data(ni:endind,1:2);
    numcal = numcal + 1;
    outpscmpcfg = [pwd,'/',outdir,'/','psCMP_',num2str(numcal),'.cfg'];
    outpscmpcfg = [outdir,'/','psCMP_',num2str(numcal),'.cfg'];
    %
    [topdir,outfilenames] = sim_pscmpcfg(oksar,cdata,....
        'greendir', greendir,...
        'outinp',   outpscmpcfg,...
        'isove',    pscmp_isove,...
        'thre',     thre,...
        'icmpflag', icmpflag,...
        'utmproj',  utmproj,...
        'days',     days);
    %
    tdata = sim_pscmp(outpscmpcfg,outfilenames,[topdir,'/'],isupdate);
    %
    if iscell(tdata)
        tdata = tdata{1};
    end
    %
    tmpE  = tdata(:,4)';
    tmpN  = tdata(:,3)';
    tmpU  = tdata(:,5)'.*-1;
    tmpGR = tdata(:,16)';
    tmpCOL= tdata(:,17)';
    tmpNor= tdata(:,18)';
    %
    if numcal==1
        outdata = [cdata tmpE(:) tmpN(:) tmpU(:) tmpGR(:),tmpCOL(:),tmpNor(:)];
    else
        outdata = [outdata;cdata tmpE(:) tmpN(:) tmpU(:) tmpGR(:),tmpCOL(:),tmpNor(:)];
    end
end
