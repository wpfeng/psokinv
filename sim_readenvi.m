function [data,gridinfo,dims,hdrfile] = sim_readenvi(imgf)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Input ENVI-format data file
 % gridinfo, including 4 parts:
 %                   1- xstart
 %                   2- ystart
 %                   3- xpixel
 %                   4- ypixel
 %
 [impath,imname] = fileparts(imgf);
 hdrfile         = fullfile(impath,[imname,'.hdr']);
 %
 fid = fopen(hdrfile);
 while feof(fid)~=1
     tlines = fgetl(fid);
     index  = findstr(tlines,'samples =');
     if isempty(index)~=1
        tmp   = textscan(tlines,'%s %s %s');
        sample= str2double(tmp{3});
     end
     index  = findstr(tlines,'lines   =');
     if isempty(index)~=1
        tmp   = textscan(tlines,'%s %s %s');
        lines = str2double(tmp{3});
     end
     index  = findstr(tlines,'map info =');
     if isempty(index)~=1
        tmp = textscan(tlines,'%s %s %s %s %s %s %s %s %s %s');
        xstart = str2double(tmp{7})/1000.;
        ystart = str2double(tmp{8})/1000.;
        xpixel = str2double(tmp{9})/1000.;
        ypixel = str2double(tmp{10})/1000;
        %
     end
        
 end
 fclose(fid);
 %
 %data = zeros(lines,sample);
 fid  = fopen(imgf);
 data = fread(fid,[sample,lines],'float32');
 fclose(fid);
 %
 gridinfo = [xstart,ystart,xpixel,ypixel];
 dims     = [sample,lines];
 %
 %imagesc(atan2(sin(data'),cos(data')));
 
