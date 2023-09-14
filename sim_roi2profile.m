function [outp,outstd,rowcol] = sim_roi2profile(file,datatype,x,y,axstep,aystep,factor)
%
% [outdata,outstd] = sim_roi2profile(file,datatype,x,y,axstep,aystep)
%
% Purpose:
%         extract a profile at (x,y) of points...
%
% Created  by Feng, W. P.  @ BJ, 2011-05-01
% Modified by Feng, W. P., @ UoG, 2012-09-04
%
% -> Fix a bug, when the region over the boundary, nan will be return...
%    Updated by Feng,W.P., @ UoG, 2014-05-14
% -> Output row and Column for each point.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    %file = 'E:\EQw\PSOInversion\NewZealand\data\data\geo_100813-100928_P337A_UTM59S.phs';
    disp('sim_roi2profile(file,datatype,x,y,axstep,aystep,factor)');
    return
end
if nargin < 7
    factor = 1;
end
%
if nargin < 2 || isempty(datatype)
    datatype = 'float';
end
if nargin < 5
    axstep = 1;
end
if nargin < 6
    aystep = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch upper(datatype)
    case 'FLOAT'
        boffset = 4;
        precision = '*float';
    case 'INTEGER'
        boffset = 2;
        precision = 'integer*2';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An additional operation...
%   to judge if the rsc file exists with the Image file...
%   modified by Feng, Wanpeng, @ 20110504
%
rsc = [file,'.rsc'];
if exist(rsc,'file')==0
   disp([' ',rsc,' is not found...']);
   outp    = [];
   outstd  = [];
   return;
end
info   = sim_roirsc(rsc);
%
xfirst = info.x_first;
yfirst = info.y_first;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yend   = yfirst;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid     = fopen(file,'r');
outp    = zeros(numel(x),1);
outstd  = outp;
counter = 0;
if numel(axstep) < numel(x)
    axstep = x.*0 + axstep(1);
end
if numel(aystep) < numel(x)
    aystep = x.*0 + aystep(1);
end
%%
rowcol = zeros(numel(x),2);
for ni=1:numel(x)
    %
    %
    xstep   = axstep(ni);
    ystep   = aystep(ni);
    counter = counter + 1;
    coffx   = fix((x(ni)-xfirst)/info.x_step)+1;
    coffy   = fix((yend-y(ni))/abs(info.y_step))+1;
    %
    % Output row and column for each point..
    % updated by FWP, @GU, 2014-05-14
    %
    rowcol(ni,:)   = [coffx,coffy];
    %
    coffx   = coffx-(xstep-1):1:coffx+(xstep-1);
    coffy   = coffy-(ystep-1):1:coffy+(ystep-1);
    %
    coffx(coffx>info.width)       = nan;
    coffy(coffy>info.file_length) = nan;
    %
    soffx                         = coffx(1);
    soffx(soffx > info.width)     = nan;
    soffx(soffx <= 0)             = nan;  
    %
    cout = zeros((xstep-1)*2+1,(xstep-1)*2+1);
    %
    % A bug fixed by Feng,W.P.,@ GU,2012-09-04
    missind = sum(isnan(coffx));
    %
    for ny = 1:numel(coffy)
        %
        %% modified by Feng,W.P.,@ GU, 2012-04-09
        %
        soffy = coffy(ny);
        %%
        if  isnan(soffx)~=1 && isnan(soffy)~=1
            %
            offsets = ((soffy-1)*info.width + soffx-1) * boffset;
            fseek(fid,offsets,'bof');
            %
            cout(isnan(coffx)==0,ny) = fread(fid,[(xstep-1)*2+1-missind,1],precision);
        else
            cout(:,ny) = nan;
        end
    end
    %
    % Modified by FWP, @UoG, 2014-05-20
    % 
    cout = cout .* factor;
    %
    outp(counter)     = mean(cout(isnan(cout)==0));
    outstd(counter)   =  std(cout(isnan(cout)==0));
    %
end
fclose(fid);
