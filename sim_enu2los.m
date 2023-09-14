function sim_enu2los(infile,outfile,azi,inc)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Name:
%      sim_enu2los(infile,outfile,model,sat)
% Purpose:
%      to convert 3D deformation(E/N/U) to the LOS deformation based on the
%      SAR and MDOEL
% Input:
%     infile,  observation data,      [Easting Northing  Defo_E  Defo_N Defo_Up]
%                                  or [Easting Northing  Defo_E  Defo_N Defo_Up azi inc]
%     outfile, output file full name, [Easting Northing  LOS  E_unit  N_unit Up_unit]
%     azi,     azimuth angle, satelite heading direction, default, 
% Ouput:
%     outfile, output data file including LOS and ENU_UNIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modification History:
%
data = load(infile);
if nargin < 2
   [~,bname] = fileparts(infile);
   outfile      = [bname,'_LOS.okinv'];
end
if nargin < 3
   azi = -166;
end
if nargin < 4
   inc = 23;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(data,2) == 7 
    azi = data(:,6);
    inc = data(:,7);
end
% Convert E/N/U to LOS
tinput      = zeros(size(data,1),4);
tinput(:,2) =  -1.*cosd(azi).*sind(inc);
tinput(:,3) =      sind(azi).*sind(inc);
tinput(:,4) =                 cosd(inc);
tinput(:,1) = data(:,3).*tinput(:,2) + ...
              data(:,4).*tinput(:,3) + ...
              data(:,5).*tinput(:,4);
 outdata = [data(:,1:2) tinput];
 % output the data into the outfile
 fid     = fopen(outfile,'w');
 fprintf(fid,'%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f\n',outdata');
 fclose(fid);
