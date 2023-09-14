function [xlim,ylim,lamd,vect,cxy,focal,slip,fgeo,k]=sim_input2liv2(infile)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Input the fault's parameters
 % Input:
 %       infile: the full name of fault'paramter
 % Output:
 %           k,      the segments' number of fault
 %         cxy, k*2, the coordinates of center points for each segment
 %       focal, k*3, strike & dip & rake, degree
 %        slip, k*2, synthetic slip in the strike and dip % slip in the open
 %        fgeo, k*3, len, top depth & bottom depth
 % By Wanpeng Feng, 2008/07/06
 % 
 k = 0;
 cxy  = zeros(1,2);
 focal= zeros(1,3);
 slip = zeros(1,2);
 fgeo = zeros(1,3);
 xlim = cell(1,3);
 ylim = cell(1,3);
 lamd = cell(1,2);
 vect = cell(1,3);
 fid = fopen(infile);
 if fid ==-1
    disp('Please choose a corrected OKSARFILE (sim_input2li)!');
    return;
 end
  %
 while ~feof(fid)
     tline = fgetl(fid);
     tinxlim   = strfind(tline,'|<- x_min x_max x_increment (km/degrees/m)');
     tinylim   = strfind(tline,'|<- y_min y_max y_increment');
     tinlamd   = strfind(tline,'|<- elastic constants:');
     tinvect   = strfind(tline,'|<-      {sat_azimuth sat_inc sat_height');
     if isempty(tinxlim)~=1
        xlim(:) =textscan(tline,'%f %f %f');
     end
     if isempty(tinylim)~=1
        ylim(:) =textscan(tline,'%f %f %f');
     end
     if isempty(tinlamd)~=1
        lamd(:) =textscan(tline,'%f %f');
     end
     if isempty(tinvect)~=1
        vect(:) =textscan(tline,'%f %f %f');
     end
     %
     tin   = strfind(tline,'--- Fault');
     if isempty(tin)~=1
         k  = k+1;
        out = textscan(tline,'%f %f %s %s %s %s');
        cx  = out(1);
        cy  = out(2);
        cxy(k,:) = [cx{:},cy{:}];   % the center coordiantes of fault geometry
        %
        % Read the focal
        out   = fgetl(fid);
        out   = textscan(out,'%f %f %f');
        focal(k,:) = [out{1},out{2},out{3}];
        % Read the slip 
        out   = fgetl(fid);
        out   = textscan(out,'%f %f');
        slip(k,:)  = [out{1},out{2}];       % 
        %Read the parameter of 
        out   = fgetl(fid);
        out   = textscan(out,'%f %f %f');
        fgeo(k,:)  = [out{1},out{2}*sind(focal(k,2)),out{3}*sind(focal(k,2))];       % 
        
     end
 end
 fclose(fid);
 
 
