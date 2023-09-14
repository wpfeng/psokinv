function sim_simerror(inprefix,ouprefix,rzone)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % +Name:
 %       sim_simerror(inprefix,ouprefix,rzone)
 % Purpose: to simualtion ramp phase and offset in the INSAR
 % Created by Feng Wanpeng, IGP-CEA
 % 2009/07/01
 % Modified by Feng W.P
 %             added a new keywords,"rzone", to force to convert 2 UTM.
 %&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
 if nargin < 1
    disp('sim_simerror(inprefix,ouprefix,rzone)');
    disp('>>>> inprefix, the prefix of inp');
    disp('>>>> ouprefix, the refix of output');
    disp('>>>>    rzone, the UTM zone ');
    return
 end
 if nargin<3
    rzone = [];
 end
 fileX = [inprefix '_X.los'];
 %
 %disp(fileX);
 [cdata,ux,uy,sarinfo]= sim_readroi(fileX);
 if isempty(findstr(lower(sarinfo.projection),'utm'))==1
    [ux,uy] = ll2utm(uy,ux,rzone);
    ux      = ux./1000;
    uy      = uy./1000;
    
 end
 %
 abc   = sarinfo.abc;
 error = (ux.*abc(1)+uy.*abc(2)+abc(3)).*(-4*3.14159265/sarinfo.wavelength);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 file_ERROR    = [ouprefix '_ABC.SIM'];
 file_ERRORrsc = [file_ERROR '.rsc'];
 file_ERRORhdr = [ouprefix '_ABC.hdr'];
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fid = fopen(file_ERROR,'w');
 fwrite(fid,error','float32');
 fclose(fid);
 copyfile([fileX '.rsc'],file_ERRORrsc);
 sim_rsc2envihdr(file_ERRORhdr,sarinfo,'ERROR',sarinfo.projection,sarinfo.utmzone);
 
