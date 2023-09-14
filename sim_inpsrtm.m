function [dem,x,y,info] = sim_inpsrtm(srtm,latregion,lonregion)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Purpose:
%     input DEM data with rsc header info.
% Usage:
%     [dem,x,y,info] = sim_inpsrtm(srtm,latregion,lonregion);
% Input:
%     srtm, the dem file with rsc header info
%     latregion, the scale of lat
%     lonregion, the scale of lon
% Output:
%     dem, the dem data
%     x,   x coordinates to the each dem pixel along x-axis
%     y,   y coordinates to the each dem pixel along y-axis
%    info, the file's information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modification History:
%  Feng, Wanpeng, 2010-01, initial version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
 dem = [];
 x   = [];
 y   = [];
 info= [];
 rheader = [srtm,'.rsc'];
 if exist(rheader,'file')==0
    return
 end
 % read rsc file
 info  = sim_roirsc(rheader);
 %info
 %
 blat  = latregion(1);
 tlat  = latregion(2);
 wlon  = lonregion(1);
 elon  = lonregion(2);

 % Setup the parameters for reading Sandwell data
 db_res = info.x_step;		% 1 minute resolution
 db_loc = [info.y_first+info.file_length*info.y_step ...
           info.y_first ...
           info.x_first ...
           info.x_first+info.width*info.x_step];
 %db_loc
 % Data size, column and row
 %
 db_size        = [info.width info.file_length];
 nbytes_per_lat = db_size(2)*2;	% 2-byte integers
 %data           = [];
 %
 % Calculate number of "records" down to start (latitude)
%
%
fid = fopen(srtm, 'r');
% Calculate the longitude indices into the matrix (0 to db_size(1)-1)
iwlon = fix((wlon-db_loc(3))/db_res);
ielon = fix((elon-db_loc(3))/db_res);
iblat = info.file_length-fix((blat-db_loc(1))/db_res)-1;
itlat = fix((db_loc(2)-tlat)/db_res);
%disp([itlat,iblat,blat,tlat])
%

data  = zeros(iblat-itlat+1,ielon-iwlon+1);
% Skip into the appropriate spot in the file, and read in the data
for ilat = itlat:iblat
    offset = ilat*nbytes_per_lat + iwlon*2 ;
    fseek(fid, offset, 'bof');
    data(iblat-ilat+1,:)=fread(fid,[1,ielon-iwlon+1],'integer*2');
end

% close the file
fclose(fid);
dem = data;
if size(data,1)*size(data,2) > 251001
   dem = resizem(dem,fix(size(data)./2),'bilinear');
end
%
[n,m] = size(dem);
x     = linspace(latregion(1),latregion(2),n);
y     = linspace(lonregion(1),lonregion(2),m);
%
