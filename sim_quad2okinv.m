function data = sim_quad2okinv(unwfile,incfile,azifile,output_path,...
                               qtblocksize,qtmaxblocksize,qtminvar,qtmaxvar,...
                               qtfrac,remove_near_field,isdisp,startrow,startcol,outname,zone,smethod)
%
%************** FWP Work ************************
%Developed by FWP, @UoG/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************

%
% Developed by FWP, @UoG, 2009/07/01
% Some minor changes was made by Feng,W.P, @ UoG, 2011-10-04
% Some comments were added by fWP, @ UoG, 2014/05/15
%
global datatype OUTPROJ UTMZONE CPROJ ISKM dsminfo lookingdir outputunit

if nargin < 1 || isempty(unwfile)==1 ||exist(unwfile,'file')==0
    disp('UNW file can not be loaded. Check it!');
    return
end
%
if nargin < 4 || isempty(output_path)==1|| exist(output_path,'dir')==0
    disp('------   Saving DIR can not be found!   -----');
    disp('--- Default save DIR is current directory ---');
    output_path = '.';
end

if nargin <  5 || isempty(qtblocksize)==1
    qtblocksize    = 1  ;      % minimum block size for quadtree
end
if nargin <  6 || isempty(qtmaxblocksize)==1
    qtmaxblocksize = 128;      % maximum block size (in pixels)
end
if nargin <  7 || isempty(qtminvar)==1
    qtminvar       = 6.28;     % minimum quadtree threshold (splits cell if
end
% 			                   % variance > qtminvar
if nargin <  8 || isempty(qtmaxvar)==1
    qtmaxvar       = 600;      % maximum quadtree threshold (for removing noise)
end
% 			                   % removes data if variance > qtmaxvar
if nargin <  9 || isempty(qtfrac)==1
    qtfrac         = 0.5;      % fraction of non-zero elements per block
end
if nargin < 10 || isempty(remove_near_field)==1
    remove_near_field = 1 ;    % 1 removes high-variance data, 0 doesn't
end
if nargin < 11 || isempty(isdisp)==1
    isdisp=1;
end
if nargin < 12 || isempty(startrow)==1
    startrow = 1;
end
if nargin < 13 || isempty(startcol)==1
    startcol = 1;
end
if isempty(zone)~=1
    zone = MCM_rmspace(zone);
    zone = [zone(end-2:end-1),' ',zone(end)];
end
UTMZONE = zone;
%
if nargin < 16 || isempty(smethod)
    smethod = 'QUAD';
end
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
[quad,info] = sim_quadsub(unwfile,output_path,...
              qtblocksize,qtmaxblocksize,qtminvar,qtmaxvar,...
              qtfrac,remove_near_field,isdisp,startrow,startcol,outname,zone,smethod);
%
% disp(info)
disp([' +++++++++++++++++++++++++++++++++++++++++++++++++'])
disp([' ps_dsm: lookingdir from UNWFILE   is ',info.lookingdir])
disp([' ps_dsm: lookingdir from configure is ',lookingdir])

if ~strcmpi(info.lookingdir,lookingdir)
    info.lookingdir = lookingdir;
    disp([' ps_dsm: info.lookingdir is forced based on the cfg to ',info.lookingdir])
end
%
disp([' +++++++++++++++++++++++++++++++++++++++++++++++++'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmpoutdata = quad(:,3);
%
% A new option, outputunit was added by FWP, 2016-12-16 @Ottawa
% Now we can control the output unit, m in default
% 
disp([' +++++++++++++++++++++++++++++++++++++++++++++++++'])
disp([' ps_dsm: datatype->',datatype])
disp([' ps_dsm: output conversion factor: ',num2str(outputunit)])
disp( ' ps_dsm: 1 for m, 100 for cm and 1000 for mm')
%
switch upper(datatype)
    case 'PHASE'
        %
        tmpdata =   tmpoutdata.*info.wavelength/(-4*pi).*outputunit;
        %
    otherwise
        %
        tmpdata =   tmpoutdata; %.*outputunit;% *wavelength/(-4*pi);
end
quad(isnan(tmpdata)==0,3) = tmpdata(isnan(tmpdata)==0);
%
CPROJ = info.projection;
%
if isempty(OUTPROJ)
    %
    if isempty(strcmpi(CPROJ,'L'))
        OUTPROJ = 'UTM';
    else
        OUTPROJ = 'LL';
    end
end
%
%
if nargin <2 || isempty(incfile)==1 ||  strcmpi(incfile,'NULL')==1 || exist(incfile,'file')==0
    disp([' ',incfile,' is not available...']);
    incs = quad(:,3).*0+info.incidence;
else
    %
    incs   = sim_roi2profile(incfile,'float',quad(:,1),quad(:,2),1,1);
    %
    meaninc                = mean(incs(isnan(incs)==0));
    incs(isnan(incs))      = meaninc;
    incs(abs(incs)<0.0001) = meaninc;
    incs(incs<=meaninc-10) = meaninc;
    incs(incs>meaninc+10)  = meaninc;
    %
end
%
if nargin <3 || strcmpi(azifile,'NULL')==1 || isempty(azifile)==1 || exist(azifile,'file')==0
    azis = quad(:,3).*0+info.heading_deg;
else
    %
    % modified by Feng, it's a stupid bug, there should be azifile.
    % Modified by FWp,@BJ, 2011/02
    % Now the INC and AZI can have different file size comparing to the unw...
    % Noted by Wanpeng Feng, @CCRS/CCMEO, 2016-11-15
    % this sessing is working for ROI_PAC only
    %
    azis                   = sim_roi2profile(azifile,'float',quad(:,1),quad(:,2),1,1);
    meanazi                = mean(azis(isnan(azis)==0));
    azis(isnan(azis))      = meanazi;
    azis(abs(azis)<0.0001) = meanazi;
    azis(azis<=meanazi-10) = meanazi;
    azis(azis>meanazi+10)  = meanazi;
    % 
    % the below line should be discarded since now
    % by Wanpeng Feng, @NRCan, 2017-03-09
    %
    % azi = azis-90;
    %
end
%
%
if isempty(strfind(lower(info.projection),'utm'))==0
    %
    %
    if isempty(strfind(info.x_unit(1),'k'))==1
        quad(:,1) = quad(:,1)./1000;
    end
    if isempty(strfind(info.y_unit(1),'k'))==1
        quad(:,2) = quad(:,2)./1000;
    end
    if isempty(strfind(OUTPROJ,'UTM'))==1
        [quad(:,2),quad(:,1)] = utm2deg(quad(:,1).*1000,quad(:,2).*1000,UTMZONE);
    end
else
    if isempty(strfind(lower(OUTPROJ),'utm')) == 0
        [x0, y0] = deg2utm(quad(:,2),quad(:,1),UTMZONE);
        quad(:,1) = x0./1000;
        quad(:,2) = y0./1000;
    end
end
%
data = [quad incs azis quad(:,3).*0+1 quad(:,3).*0+1];
inp  = data;
%
%
% Improved by Feng, W.P, 2011-04-25, @ BJ
% the tools will support the another obs data of AZI or RNG
%
% Updated by FWP, @NRCan, 2016-08-10
% allow data from left looking
% A bug was found below. For left-looking SAR data, the azimuth measurements are 
% identical with right-looking data. The differences are only coming in range changes. 
% they should have opposite signs from e and n between left- and right-looking SAR data.
% Figured out by Wanpeng Feng, @NRCan, 2017-04-11
%
if strcmpi(lookingdir,'left')
   %
   leftlooking_sign = -1.;
else
   leftlooking_sign = 1.;
end
%
aziangle = data(:,5);
%
% More information will be printed out during downsampling
% by Wanpeng Feng, @NRCan, 2017-04-15
%
disp([' +++++++++++++++++++++++++++++++++++++++++++++'])
disp([' + ps_dsm: input data are ',dsminfo.obsmodel,' changes'])
disp([' +++++++++++++++++++++++++++++++++++++++++++++'])
switch upper(dsminfo.obsmodel)
    case 'E'
        inp(:,4)  =  1;
        inp(:,5)  =  0;
        inp(:,6)  =  0;
    case 'N'
        inp(:,4)  =  0;
        inp(:,5)  =  1;
        inp(:,6)  =  0;
    case 'V'
        inp(:,4)  =  0;
        inp(:,5)  =  0;
        inp(:,6)  =  1;
    case 'AZIMUTH'
	    %
        % Updated by Feng, W.P.,@UoG, 2012-10-09
        % Updated by Feng, W.P., @Yj, 2015-05-25
        % 
        inp(:,4)  =  sind(aziangle);
        inp(:,5)  =  cosd(aziangle);
        inp(:,6)  =  0;
    case 'RANGE'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% tinput(:,3)  = data(:,3).*wavelength./(-4*3.14159265);
		% updated by Wanpeng Feng, @NRCan, 2017-04-11
		% 
        inp(:,4)  =  -1.*cosd(aziangle).*sind(data(:,4)) .* leftlooking_sign;
        inp(:,5)  =      sind(aziangle).*sind(data(:,4)) .* leftlooking_sign;
        inp(:,6)  =                      cosd(data(:,4));
	
end

% updated by Feng, W.P.,@NRCan,2015-12-02
%
presetvec = dsminfo.presetvec;
%
if sum(isnan(presetvec)) < 1
    %
    inp(:,4) = presetvec(1);
    inp(:,5) = presetvec(2);
    inp(:,6) = presetvec(3);
end
%
data     = inp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outproj
%
wfile    = fullfile(output_path,[outname,'_',smethod,'_',OUTPROJ,'_',MCM_rmspace(UTMZONE),'.inp']);
fid      = fopen(wfile,'w');
fprintf(fid,'%15.8f %15.8f %11.8f %11.8f %11.8f %11.8f %11.8f\n',data');
fclose(fid);
%
%
if isempty(strfind(lower(OUTPROJ),'utm'))==1
    [lat,lon] = deg2utm(data(:,2),data(:,1),UTMZONE);
    data(:,1) = lat./1000;
    data(:,2) = lon./1000;
    outinpT  = fullfile(output_path,[outname,'_',smethod,'_UTM' '_' MCM_rmspace(UTMZONE) '.inp']);
    fid      = fopen(outinpT,'w');
    fprintf(fid,'%15.8f %15.8f %11.8f %11.8f %11.8f %11.8f %11.8f\n',data');
    %
else
    if ISKM == 1
        [lat,lon] = utm2deg(data(:,1).*1000,data(:,2).*1000,UTMZONE);
    else
        [lat,lon] = utm2deg(data(:,1),data(:,2),UTMZONE);
    end
    data(:,1) = lon;
    data(:,2) = lat;
    outinpT  = fullfile(output_path,[outname,'_',smethod,'_LL.inp']);
    fid     = fopen(outinpT,'w');
    fprintf(fid,'%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f\n',data');
    %fclose(fid);
end
fclose(fid);
%whos data



