function sim_quadfunc(unwfile,outname,incfile,azifile,varargin)
%
%%%************** FWP Work ************************
% Developed by FWP, @GU/BJ, 2007-2014
% contact by wanpeng.feng@hotmail.com
%%%************** Good Luck ***********************
%
% Created by Feng, Wanpeng, IGP/CEA, 2009/06
%     to downsample the interferogram into the discrete points
% + Input:
%       unwfile, an interferogram with a rsc file
%       outname, the root name of the outputs
%       incfile, corresponding incidence file (same file size in the first
%                version).
%       azifile, the similar as the incfile, but for azimuth angle
% + Output:
%       <outname>.inp for inp files for modelling
%       <outname>.xyz for corresponding rectangle locations...
% + History:
%       First version was finished in 2009/06 when I was working in UoG.
%       
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
global CPROJ UTMZONE OUTPROJ dsminfo
%
if iscell(incfile)==0
    incfile = {'NULL'};
end
if iscell(azifile)==0
    azifile = {'NULL'};
end
if nargin<4
    azifile = [];
end
if nargin<3
    incfile = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output_path       = 'inp';      %
qtblocksize       = 4 ;         % minimum block size for quadtree
qtmaxblocksize    = 64;         % maximum block size (in pixels)
qtminvar          = 3.14;       % a value of variance above which the image will be subdivied.
qtmaxvar          = 628;        % a value of variance above which the image will be nulled.
qtfrac            = 0.5;        % propotion of non-zero elements per block
remove_near_field = 1 ;         % 1 removes high-variance data, 0 doesn't
cisdisp           = 0;          % 1 show the down-sampling result
isdisp            = 1;          %
zone              = 'UTM50G';   % if the projection of InSAR is LL, the zone is necessary.e.g, "UTM50S"
smethod           = 'QUAD';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v  = ge_parse_pairs(varargin);
for j = 1:length(v)
    eval(v{j});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~strcmpi(smethod,'QUAD')
    %
    qtblocksize = qtmaxblocksize;
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
for ni=1:numel(unwfile)
    %
    if ~exist(unwfile{ni},'file')
        disp([unwfile{ni},' isnot found. Check first.']);
        return
    end
    %
    data = sim_quad2okinv(unwfile{ni},incfile{ni},azifile{ni},output_path,...
                          qtblocksize,qtmaxblocksize,qtminvar,qtmaxvar,...
                          qtfrac,remove_near_field,cisdisp,[],[],outname{ni},zone);
    %
    if isdisp ==1
        %
        figure('Color',[1,1,1]);
        %
        disp([outname{ni} '_',smethod,'_',OUTPROJ,'_',MCM_rmspace(UTMZONE),'.inp']);
        disp(fullfile(output_path,[outname{ni} '_',smethod,'_', OUTPROJ,'_',MCM_rmspace(UTMZONE),'.quad.box.xy']));
        %
        inpfile = fullfile(output_path,[outname{ni} '_',smethod,'_',OUTPROJ,'_',MCM_rmspace(UTMZONE),'.inp']);
        showquad(fullfile(output_path,[outname{ni} '_',smethod,'_', OUTPROJ,'_',MCM_rmspace(UTMZONE),'.quad.box.xy']),inpfile);%,CPROJ,UTMZONE);
        caxis([min(data(:,3)),max(data(:,3))]);
        colorbar();
        % add painters for rander
        % painters can speed up my hp laptop...
        %
        set(gcf,'renderer','painters');
    end
    %
end
