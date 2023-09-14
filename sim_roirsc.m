function info = sim_roirsc(headerf)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created by Feng, W.P, working to read infomation from a ROI_RAC rsc file
% First version was done by Wanpeng Feng, @IGP/CEA, Beijing, 2008-12-25
% Updated by Wanpeng Feng, @GU, 2014-04-30
% Some keywords added for SB-InSAR analysis
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 1
    headerf = 'test.rsc';
end
if nargin < 2
    isshowerror = 0;
end
info.tempbaseline = [];
info.source                = 'ROI_PAC';
info.TIME_SPAN_YEAR        = 0;
info.masterdate            = 0;
info.slavedate             = 0;
info.TRACKNUMBER           = 0;
info.P_BASELINE_TOP_HDR    = 0;
info.P_BASELINE_BOTTOM_HDR = 0;
info.lookingdir            = 'right';
info.pbaseline   = [];
info.width       = 0;   % WIDTH
info.file_length = 0;   % FILE_LENGH
info.xmin        = 0;
info.xmax        = info.width-1;
info.ymin        = 0;
info.ymax        = info.file_length-1;
info.x_first     = 1;   % Geo-x-coordiante at the first pixel
info.y_first     = 1;   % Geo-y-coordiante at the first pixel
info.x_step      = 1;   % Pixel x-size
info.x_unit      = 'degres';
info.y_step      = 1;   % Pixel y-size
info.y_unit      = 'degres';
info.heading_deg = -167;   % the satellite header direction with clockwise, North is zero.
info.projection  = 'LATLON'; % the projection
info.incidence   = [];
info.wavelength  = 0.056;%
info.utmzone     = [];
info.datum       = 'WGS84';
info.abc         = [0 0 0];
info.hemi        = [];
info.z_scale     = 1;
info.z_offset    = 0;
info.utmzone     = [];
info.range_pixel_size = 4;
info.azimuth_pixel_size = 3.5;
info.look_ref         = [];
info.rngsampling_freq = [];
info.prf              = [];
info.chirpslope       = [];
info.pulselength      = [];
info.rngbandwidth     = 0;
info.centre_frequency = 0;
info.poly             = [];
info.TIME_SPAN_YEAR   = 0;
%
%
%
lookref = [];
if nargin==1 && exist(headerf,'file')~=0
    fid = fopen(headerf);
    while feof(fid)==0
        str = fgetl(fid);
        if isempty(str)
            str = '99999999999999999999999999999999999999999999999999';
        end
        %
        index = strfind(str,'WIDTH');
        if isempty(index)==0
            tmp = textscan(str,'%s %10.0f');
            %str
            if strcmpi(tmp{1}{1},'WIDTH')
                info.width  = tmp{2};
            end
            %
        end
        %%%%%
        % updated on 2014-04-30 by FWP, @GU
        %
        index = strfind(str,'TIME_SPAN_YEAR');
        if isempty(index)==0
            tmp = textscan(str,'%s %7.5f');
            if strcmpi(tmp{1}{1},'TIME_SPAN_YEAR')
                info.TIME_SPAN_YEAR  = tmp{2};
            end
        end
        %
        index = strfind(str,'SOURCE');
        if isempty(index)==0
            tmp = textscan(str,'%s %s');
            if strcmpi(tmp{1}{1},'source')
                info.source  = tmp{2}{1};
            end
        end
        %
        index = strfind(str,'P_BASELINE_TOP_HDR');
        if isempty(index)==0
            tmp = textscan(str,'%s %8.3f');
            if strcmpi(tmp{1}{1},'P_BASELINE_TOP_HDR')
                info.P_BASELINE_TOP_HDR  = tmp{2};
            end
        end
        index = strfind(str,'P_BASELINE_BOTTOM_HDR');
        if isempty(index)==0
            tmp = textscan(str,'%s %8.3f');
            if strcmpi(tmp{1}{1},'P_BASELINE_BOTTOM_HDR')
                info.P_BASELINE_BOTTOM_HDR  = tmp{2};
            end
        end
        index = strfind(str,'MASTERDATE');
        if isempty(index)==0
            tmp = textscan(str,'%s %8.3f');
            if strcmpi(tmp{1}{1},'masterdate')
                info.masterdate  = tmp{2};
            end
        end
        index = strfind(str,'SLAVEDATE');
        if isempty(index)==0
            tmp = textscan(str,'%s %8.3f');
            if strcmpi(tmp{1}{1},'SLAVEDATE')
                info.slavedate  = tmp{2};
            end
        end
        %%%%%
        %
        index = strfind(str,'FILE_LENGTH');
        if isempty(index)==0
            tmp = textscan(str,'%s %10.0f');
            info.file_length  = tmp{2};
        end
        %%%%%%
        % Updated by ISCE rsc...
        %%%%%%
        tempstring = textscan(str,'%s %f');
        %
        if strcmp(tempstring{1}{1},'LENGTH')
            % tmp = textscan(str,'%s %10.0f');
            info.file_length  = tempstring{2};
        end
        %
        index = strfind(str,'X_FIRST');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.x_first  = tmp{2};
        end
        % perpendicular baseline...
        index = strfind(str,'PBASELINE');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.pbaseline  = tmp{2};
        end
        %track number
        index = strfind(str,'TRACKNUMBER');
        if isempty(index)==0
            tmp = textscan(str,'%s %s');
            tmp = tmp{2};
            if numel(tmp)==0
                info.TRACKNUMBER  = [];
            else
                info.TRACKNUMBER = tmp{1};
            end
        end
        %
        %LAT_REF1
        index = strfind(str,'LAT_REF1');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            LAT_REF1  = tmp{2};
        end
        %LAT_REF2
        index = strfind(str,'LAT_REF2');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            LAT_REF2  = tmp{2};
        end
        %LAT_REF2
        index = strfind(str,'LAT_REF3');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            LAT_REF3  = tmp{2};
        end
        %LAT_REF2
        index = strfind(str,'LAT_REF4');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            LAT_REF4  = tmp{2};
        end
        % tempbaseline
        % look ref1
        index = strfind(str,'TEMPBASELINE');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.tempbaseline = tmp{2};
        end
        % look ref1
        index = strfind(str,'LOOK_REF1');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            lookref(1)  = tmp{2};
        end
        % look ref2
        index = strfind(str,'LOOK_REF2');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            lookref(2)  = tmp{2};
        end
        % look ref3
        index = strfind(str,'LOOK_REF3');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            lookref(3)  = tmp{2};
        end
        % look ref4
        index = strfind(str,'LOOK_REF4');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            lookref(4)  = tmp{2};
        end
        %%%
        %LON_REF1
        index = strfind(str,'LON_REF1');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            LON_REF1  = tmp{2};
        end
        %LON_REF2
        index = strfind(str,'LON_REF2');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            LON_REF2  = tmp{2};
        end
        %LON_REF2
        index = strfind(str,'LON_REF3');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            LON_REF3  = tmp{2};
        end
        %LON_REF4
        index = strfind(str,'LON_REF4');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            LON_REF4  = tmp{2};
        end
        %
        %%%
        %
        index = strfind(str,'Y_FIRST');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.y_first  = tmp{2};
        end
        %
        index = strfind(str,'HEADING_DEG');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.heading_deg  = tmp{2};
        end
        %
        index = strfind(str,'X_STEP');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.x_step  = tmp{2};
        end
        %
        index = strfind(str,'RANGE_PIXEL_SIZE');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.range_pixel_size  = tmp{2};
        end
        %
        index = strfind(str,'AZIMUTH_PIXEL_SIZE');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.azimuth_pixel_size  = tmp{2};
        end
        % RANGE_SAMPLING_FREQUENCY
        index = strfind(str,'RANGE_SAMPLING_FREQUENCY');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.rngsampling_freq  = tmp{2};
        end
        % PRF
        index = strfind(str,'PRF');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.prf  = tmp{2};
        end
        %
        % PULSE_LENGTH
        index = strfind(str,'PULSE_LENGTH');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.pulselength  = tmp{2};
        end% PULSE_LENGTH
        index = strfind(str,'CHIRP_SLOPE');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.chirpslope  = tmp{2};
        end
        %
        index = strfind(str,'Y_STEP');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.y_step  = tmp{2};
        end
        % CENTRE_FREQUENCY
        index = strfind(str,upper('centre_frequency'));
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.centre_frequency = tmp{2};
        end
        %
        index = strfind(str,'WAVELENGTH');
        if isempty(index)==0
            tmp = textscan(str,'%s %20.15f');
            info.wavelength = tmp{2};
            %working for ALOS(from zhenhong);
            if info.wavelength < 0.005
                info.wavelength = info.wavelength*100;
            end
        end
        %
        index = strfind(str,'XMIN');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.xmin = tmp{2};
        end
        %
        index = strfind(str,'XMAX');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.xmax = tmp{2};
        end
        %
        %
        index = strfind(str,'YMIN');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.ymin = tmp{2};
        end
        %
        index = strfind(str,'YMAX');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.ymax = tmp{2};
        end
        %
        index = strfind(str,'PROJECTION');
        if isempty(index)==0
            tmp = textscan(str,'%s %s');
            b = tmp{2};
            if size(b)>0
                info.projection = tmp{2}{1};
            end
        end
        %
        index = strfind(str,'X_UNIT');
        if isempty(index) == 0
            tmp = textscan(str,'%s %s');
            info.x_unit = tmp{2}{1};
        end
        %
        index = strfind(str,'Y_UNIT');
        if isempty(index)==0
            tmp = textscan(str,'%s %s');
            info.y_unit = tmp{2}{1};
        end
        %
        index = strfind(str,'INCIDENCE');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.incidence = tmp{2};
        end
        %
        index = strfind(str,'UTMZONE');
        if isempty(index)==0
            tmp = textscan(str,'%s %s');
            zone = tmp{2};
            if isempty(zone)==0
                
                if iscell(zone)
                    info.utmzone = zone{1};
                else
                    info.utmzone = zone;
                end
            end
        end
        %
        index = strfind(str,'DATUM');
        if isempty(index)==0
            tmp = textscan(str,'%s %s');
            info.datum = tmp{2}{1};
        end
        %
        %
        index = strfind(str,'ABC');
        if isempty(index)==0
            tmp = textscan(str(4:end),'%f');
            tmp = cell2mat(tmp);
            tmp = tmp(:)';
            abc = tmp;%[tmp{2} tmp{3} tmp{4}];
            %
            % updated by FWP, @gU, 2014-03-20
            % coefficients for 2 order planes (6 parameters) have been allowed...
            %
            %            if numel(abc) ~= 3
            %                abc = zeros(3,1);
            %            end
            info.abc = abc;
        end
        %add new parameters
        % hemi, hemisphere, given north or south
        index = strfind(str,'HEMI');
        if isempty(index)==0
            tmp = textscan(str,'%s %s');
            info.hemi = tmp{2}{1};
        end
        index = strfind(str,'Z_SCALE');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.z_scale = tmp{2};
        end
        index = strfind(str,'Z_OFFSET');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            info.z_offset = tmp{2};
        end
        index = strfind(str,'LOOK_REF');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            lookreft = tmp{2};
            if isempty(info.look_ref)
                info.look_ref = lookreft;
            else
                info.look_ref = mean([info.look_ref,lookreft]);
            end
        end
        %
        index = strfind(str,'RNGBANDWIDTH');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            %str
            info.rngbandwidth  = tmp{2};
            %
        end
        index = strfind(str,'LOOKINGDIR');
        if isempty(index)==0
            tmp = textscan(str,'%s %s');
            %str
            info.lookingdir  = tmp{2}{1};
            %
        end
        %
        index = strfind(str,'PULSELENGTH');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            %str
            info.pulselength  = tmp{2};
            %
        end
        %
        index = strfind(str,'CHIRPSLOPE');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            %str
            info.chirpslope  = tmp{2};
            %
        end
        % rngsampling_freq
        index = strfind(str,'RNGSAMPLING_FREQ');
        if isempty(index)==0
            tmp = textscan(str,'%s %f');
            %str
            info.rngsampling_freq  = tmp{2};
            %
        end
    end
    fclose(fid);
else
    if isshowerror ~= 0
        disp('Sorry! The header file is not available!');
    end
end
if isempty(strfind(lower(info.projection),'utm'))~=1
    %
    % info.projection
    if length(info.projection) >= 5
        info.utmzone = str2double(info.projection(4:5));
    else
        info.utmzone = 'XXXX';
    end
end
%
%
if isempty(info.hemi)
    if nargin > 1 || exist(headerf,'file') ~= 0
        [ipath,iname] = fileparts(headerf);
        hdrfile = fullfile(ipath,[iname,'.hdr']);
        if exist(hdrfile,'file') ~= 0
            hemi = '';
            fid  = fopen(hdrfile,'r');
            while ~feof(fid)
                tgetl = fgetl(fid);
                if isempty(strfind(tgetl,'map info'))==0
                    if isempty(strfind(tgetl,'South'))
                        hemi = 'N';
                    else
                        hemi = 'S';
                    end
                end
            end
            fclose(fid);
            info.hemi = hemi;
        else
            info.hemi = 'N';
        end
    else
        info.hemi = 'N';
    end
end
%
if isempty(info.utmzone)
    if isempty(strfind(lower(info.projection),'l'))
        info.utmzone = '59G';
    else
        [tmp,tmp,info.utmzone] = deg2utm(info.y_first,info.x_first);
    end
    info.utmzone = MCM_rmspace(info.utmzone);
end
if info.y_step==1
    info.y_first = info.file_length;
    info.y_step  = -1;
    info.x_step  = 1;
    info.x_first = 1;
end
if isempty(info.pulselength)==0 && isempty(info.chirpslope) == 0
    info.rngbandwidth = abs(info.pulselength/1e-5*info.chirpslope/1e11*1e6);
end
%
poly = [];
if exist('LAT_REF1','var')
    poly(1,2) = LAT_REF1;
end
if exist('LAT_REF2','var')
    poly(2,2) = LAT_REF2;
end
if exist('LAT_REF3','var')
    poly(4,2) = LAT_REF3;
end
if exist('LAT_REF4','var')
    poly(3,2) = LAT_REF4;
end
if exist('LON_REF1','var')
    poly(1,1) = LON_REF1;
end
if exist('LON_REF2','var')
    poly(2,1) = LON_REF2;
end
if exist('LON_REF3','var')
    poly(4,1) = LON_REF3;
end
if exist('LON_REF4','var')
    poly(3,1) = LON_REF4;
end
if ~isempty(poly)
    poly = [poly;poly(1,:)];
end
%
% plot(poly(:,1),poly(:,2),'-r');
%
% Update incidence...
%
if isempty(info.incidence)
    %
    if ~isempty(lookref)
        %
        info.incidence = mean(lookref(:))+3;
    else
        info.incidence = 21;
    end
end
%
info.poly = poly;
%
info.master = datestr(info.masterdate,'yyyymmdd');
info.slave  = datestr(info.slavedate,'yyyymmdd');
