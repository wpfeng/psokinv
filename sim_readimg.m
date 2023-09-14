function [cdata,cx,cy,cinfo,proi] = sim_readimg(file,varargin)
%
%
% + Purpose:
%   to read a binary image data with .rsc headerinfo
%
% + USAGE:
%   file, the roi image file
%
% + INPUT:
%     file,              binary file
%     varargin can include ...
%       datatype,        integer,float,or complex
%       downsamplescale, integer number, i.e., 1,2,3,...n
%       isplot,          switch flag for quick show...
%       roi,             extract a sub region by
%                        [minlat,maxlon,minlat,maxlat]
%       iswrap,          switch flag: 1 for re-wrapping data by given value;
%                                     0 do nothing.
%       wrapsize,        available when iswrap is set with 1
%       outband,         if its multibands files...
%       ccolor,          color scale for quickshow. if not be set,
%                        [minv,maxv] will be adopted.
% + MODIFICATION History:
%   Created by Feng, W.P., @ YJ, 2015-05-04
%   the first version inheritates all functions from sim_defreadroi but
%   with more flexible inputs.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 1
    %
    disp('[cdata,cx,cy,cinfo] = sim_readimg(file,varargin)');
    disp('++++++++++++++++++++++++++++++++++++++++++++++++++++');
    disp(' read an image file with a rsc header ...')
    disp(' +Input:')
    disp('   refrsc     - a reference header rsc can be allowed to give file size');
    disp('   datatype   - float in default')
    disp('   isplot     - 0 in default. 1 for yes and 0 for no');
    disp('   iswrap     - 0 in default. as above');
    disp('   roi        - NULL in default. given spatial coverage')
    disp('   inbands    - 1 in default. number of bands are included in the given file');
    disp('   outbands   - 1 in default. the no band that will be operated');
    disp('  isbigendian - 0 in default. 1 for yes and 0 for no');
    disp('******************************************************');
    disp(' developed by Feng, W.P., @ YJ, 2015-05-05');
    disp(' Note: this function is recoded fully inheriting all options from sim_defreadroi');
    %
    cdata = [];
    cx    = [];
    cy    = [];
    cinfo = [];
    return
end
%
% Initilizing parameters
refrsc          = [];
datatype        = 'float';
roi             = [];
downsamplescale = 10;
isplot          = 0;
iswrap          = 0;
wrapsize        = 3.14;
outbands        = 1;
inbands         = 1;
isbigendian     = 0;
%
for ni = 1:2:numel(varargin)
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
end
%
% updated by FWP, @ GU, 2013-05-03
if numel(downsamplescale)==1
    downsamplescale = [downsamplescale,downsamplescale];
end
numband = inbands;
%
if inbands < numband
    inbands = numband;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isdatacomplex = 0;
switch upper(datatype)
    case 'FLOAT'
        boffset = 4;
        precision = '*float';
        classname = 'double';
    case 'INTEGERV1'
        boffset = 4;
        precision = 'integer*4';
        classname = 'int32';
    case 'INTEGERV2'
        boffset   = 1;
        precision = 'int8';
        classname = 'int8';
    case 'INTEGER'
        boffset = 2;
        precision = 'integer*2';
        classname = 'int16';
    case 'COMPLEX'
        boffset = 8;
        precision = '*float';
        classname = 'double';
        isdatacomplex = 1;
end
%classname
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add additional operation...
% to judge the hdr file if it's existing...
% modified by Feng, Wanpeng, @ 20110504
rsc = [file,'.rsc'];
%
if isempty(refrsc)==0 && exist(refrsc,'file')
    rsc = refrsc;
end
%
%
if exist(rsc,'file')==0
    disp([' ',rsc,' is not found...']);
    cdata = [];
    cx    = [];
    cy    = [];
    cinfo = [];
    return;
    
end
info   = sim_roirsc(rsc);
m      = info.file_length;
n      = info.width;
%
%%%%%%%%%%%%%%%%%%%%
% a bug fixed by Feng, W.P., @ GU, 15/10/2011
% -> previously, if the unit is m, the code will convert it into km. But
%    the sar_rsc2roi just keep original units. So there will be something wrong
%    happening. Now just keep raw unit in axis.
%
subx   = info.x_step;
suby   = abs(info.y_step);
xfirst = info.x_first;
yfirst = info.y_first;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
yend   = yfirst;
xend   = xfirst + (n-1) * subx;
yfirst = yend   - (m-1) * suby;
%
if nargin < 5 || isempty(roi)
    roi = sar_rsc2roi(rsc);
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
roi(1) = (roi(1) >= xend)    * xfirst + (roi(1) <  xend)   * roi(1);
roi(1) = (roi(1) <  xfirst)  * xfirst + (roi(1) >= xfirst) * roi(1);
roi(2) = (roi(2) <= xfirst)  * xfirst + (roi(2) >  xfirst) * roi(2);
roi(2) = (roi(2) >  xend)    * xend   + (roi(2) <= xend)   * roi(2);
%
roi(3) = (roi(3) <  yfirst)  * yfirst + (roi(3) >= yfirst) * roi(3);
roi(3) = (roi(3) >= yend)    * yend   + (roi(3) <  yend)   * roi(3);
roi(4) = (roi(4) >= yend)    * yend   + (roi(4) <  yend)   * roi(4);
roi(4) = (roi(4) <  yfirst)  * yfirst + (roi(4) >= yfirst) * roi(4);
%
if numel(roi)<6
    %
    % updated by Feng,W.P.@ UoG, 2012-10-01
    nx = round((roi(2)-roi(1))/info.x_step)+1;
    ny = round(abs((roi(4)-roi(3))/abs(info.y_step)))+1;
else
    nx = roi(5);
    ny = roi(6);
end
%
xstartind = round((roi(1)-xfirst)/subx);
xstartind = (xstartind == 0) * 1 + (xstartind ~= 0)*xstartind;
xendind   = nx + xstartind -1 ;% round((roi(2)-xfirst)/subx)+1;
xendind   = (xendind <= info.width)*xendind + (xendind > info.width)*info.width;
xendind   = (xendind > info.width ) * (info.width-1) + (xendind <= info.width) * xendind;
ystartind = round((yend-roi(4))/suby);
ystartind = (ystartind == 0) * 1 + (ystartind ~= 0)*ystartind;
%
yendind   = ny + ystartind -1;%round((yend-roi(3))/suby)+1;
yendind   = (yendind > info.file_length ) * (info.file_length-1) + (yendind <= info.file_length) * yendind;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
proi = [xstartind,xendind,ystartind,yendind];
cm   = ceil((xendind-xstartind+1)/downsamplescale(1));
cn   = ceil((yendind-ystartind+1)/downsamplescale(2));
%
% Modified by Feng, W.P, now function support multiband data...
% 2011-06-10
fileinfo = dir(file);
thesize  = info.width*info.file_length*boffset.*inbands;
%
cdata = zeros(cm,cn,classname);
%
if isdatacomplex==1
    cdata = complex(cdata,cdata);
end
%
%
if fileinfo.bytes ~= thesize
    disp([num2str(thesize),' is expected for this file. But ', num2str(fileinfo.bytes),' is found. Check firstly!']);
    return
end
%
fid  = fopen(file,'r');
counter = 0;
%
for ni = ystartind : downsamplescale(2) : yendind
    %
    counter = counter + 1;
    %
    % offsets = info.width * (info.file_length * (outbands - 1) + (ni-1)) * boffset;
    % BIL format, band by band for each line
    %
    offsets = info.width*(outbands - 1) * boffset + ((ni-1)*info.width + xstartind-1) * boffset * numband;
    %
    fseek(fid,offsets,'bof');
    if isdatacomplex == 0
        %
        if isbigendian == 0
            tdata = fread(fid,[cm,1],precision,boffset*(downsamplescale(1)-1));
        else
            tdata = fread(fid,[cm,1],precision,boffset*(downsamplescale(1)-1),'ieee-be');
        end
    else
        %
        if isbigendian == 0
            real_img = fread(fid,[cm,1],precision,4*((downsamplescale(1)-1)*2+1));
        else
            real_img = fread(fid,[cm,1],precision,4*((downsamplescale(1)-1)*2+1),'ieee-be');
        end
        %
        fseek(fid,offsets+4,'bof');
        if isbigendian == 0
            imag_img = fread(fid,[cm,1],precision,4*((downsamplescale(1)-1)*2+1));
        else
            imag_img = fread(fid,[cm,1],precision,4*((downsamplescale(1)-1)*2+1),'ieee-be');
        end
        tdata        = complex(real_img,imag_img.*-1);
    end
    %
    cdata(:,counter) = tdata;
end
fclose(fid);
cdata   = cdata';
%
% modified by Feng, W.P, 2011/11/27, @ GU
%
[cx,cy] = meshgrid(roi(1):subx*downsamplescale(1):(roi(2)+subx*downsamplescale(1)),...
          roi(4):(-1*abs(suby*downsamplescale(2))):(roi(3)-abs(suby*downsamplescale(2))));
%
cx = cx(1:cn,1:cm);
cy = cy(1:cn,1:cm);
%
cinfo               = info;
cinfo.width         = cm;
cinfo.file_length   = cn;
cinfo.xmax          = cm - 1;
cinfo.ymax          = cn - 1;
%
cinfo.x_first       = roi(1);
cinfo.y_first       = roi(4);
cinfo.x_step        = subx*downsamplescale(1);
cinfo.y_step        = (-1)*suby*downsamplescale(2);
%cinfo

%
%
if isinteger(cdata) || isfloat(cdata)
    cdata(cdata==-32768)= 0;
    cdata(isnan(cdata)) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
tdata = cdata;
%whos tdata
%
if isinteger(tdata) == 1
    tdata = double(tdata);
end
if isplot==1
    %
    if isdatacomplex == 1
        tdata = angle(tdata);
    end
    %
    if iswrap == 1
        %wrapsize
        if nargin == 10
            tdata(tdata~=0) = tdata(tdata~=0) + adddata;
        end
        tdata = tdata;%.*wleng./(4*pi);
        tdata = sim_wrap(tdata,-1*wrapsize/2,wrapsize/2);
    end
    tdata(tdata==0) = nan;
    hidp            = pcolor(cx,cy,tdata);
    set(hidp,'LineStyle','none');
    axis equal
    set(gca,'YDir','normal');
    set(gca,'TickDir','out');
    set(gca,'XLim',[min(cx(:)),max(cx(:))]);
    set(gca,'YLim',[min(cy(:)),max(cy(:))]);
    %
    if nargin >=9
        %caxis(ccolor);
    end
end
cdata(isnan(cdata)) = 0;
