function sim_simresi(inunw,outsim,outerr,outdif)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Developed by FWP, @GU, 2009-07-01
 % Fixed by fWP, @IGPP of SIO, UCSD, 2013-10-22
 %
 file_ERR    = [outerr '_ABC.SIM'];
 file_ERRrsc = [file_ERR '.rsc'];
 file_UNW    = inunw;
 file_SIM    = [outsim '_LOS.phs'];
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if exist(file_UNW,'file')~=0
    [UNW,ux,uy,sarinfo]= sim_readroi(file_UNW);
 else
    disp('Warning!!!!! UNW file is not found.');
    return
 end
 if exist(file_SIM,'file')~=0
    [SIM              ]= sim_readroi(file_SIM);
 else
    disp('Warning!!!!! SIM file is not found.');
    return
 end
 if exist(file_ERR,'file')~=0
    [ERR              ]= sim_readroi(file_ERR);
 else
    ERR = 0;
 end
 %whos SIM
 RES = (UNW == 0).*0+(UNW ~= 0).*(UNW-ERR-SIM);
 %
 file_RES      = [outdif '_ABCSIM.phs'];
 file_RESrsc   = [file_RES '.rsc'];
 file_REShdr   = [outdif '_ABCSIM.hdr'];
 fid = fopen(file_RES,'w');
 fwrite(fid,RES','float32');
 fclose(fid);
 %
 if ~exist(file_ERRrsc,'file')
     file_ERRrsc = [file_UNW,'.rsc'];
 end
 copyfile(file_ERRrsc,file_RESrsc);
 sim_rsc2envihdr(file_REShdr,sarinfo,'RES',sarinfo.projection,sarinfo.utmzone);
