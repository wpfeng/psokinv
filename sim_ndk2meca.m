function gmtmeca = sim_ndk2meca(file)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Purpose:
 %   Input GCMT ndk format into GMT as psmeca format
 %   The NDK format is ASCII and uses five 80-character lines per earthquake.
 %   Some details info comes from WEB site as follow:
 %   http://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/allorder.ndk_exp
 %   lained
 % Usage:
 %   gmtmeca = sim_ndk2meca(file);
 % Input:
 %   file, the NDK format for moment tenors of earthquake.
 % Created by W.P Feng, IGP/CEA,2009
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %
 gmtmeca = struct();
 nevent  = 0;
 fid     = fopen(file,'r');
 %
 while feof(fid)~=1
     tlines   = fgetl(fid);
     type_1   = findstr(tlines,'PDE');
     type_2   = findstr(tlines,'ISC');
     type_3   = findstr(tlines,'SWE');
     type_4   = findstr(tlines,'ITALY');
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     if isempty(type_1)~=1 || isempty(type_2)~=1 || isempty(type_3)~=1 || ...
        isempty(type_4)~=1
        nevent = nevent+1;
        outs   = textscan(tlines,'%s%s%s%f%f%f%f%f ');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        gmtmeca(nevent).local = outs{1}{1};
        gmtmeca(nevent).date  = outs{2}{1};
        gmtmeca(nevent).time  = outs{3}{1};
        gmtmeca(nevent).ll    = [outs{4},outs{5}];
        gmtmeca(nevent).depth = outs{6};
        gmtmeca(nevent).mag   = outs{7};
        gmtmeca(nevent).el    = outs{8};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fgetl(fid);
        fgetl(fid);
        tlines              = fgetl(fid);
        outs                = textscan(tlines,'%f');
        gmtmeca(nevent).exp = outs{1}(1);
        tlines              = fgetl(fid);
        outs                = textscan(tlines,'%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f');
        %
        gmtmeca(nevent).scmo = outs{11};
        gmtmeca(nevent).meca = [outs{12:17}];
        %
     end
 end
 fclose(fid);
