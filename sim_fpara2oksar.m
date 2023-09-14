function sim_fpara2oksar(fpara,outname,utmzone)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Purpose:
 %        output the faults' parameters in SIM formation into a file as oksar structure
 %
 % Input:
 %       fpara, n*10, the parameters of n faults
 %     outname, string variable, fullpath parameters
 % Writen by Feng W.P, 2009 July 27
 % convert FPARA model to OKSAR as the top and bot are along dip direction.
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Revised by Feng, W.P, 2010-10-14
 %       -> Redefine the OKSAR format, top and bottom just along dip direction
 %       -> (x,y) is the coordinate of top central point.
 %       -> positive value along left lateral
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Modified by Feng, W.P., 2011-04-15
 %  1) fix a bug, when fpara -> oksar, strike slip should be negtive...
 %  2) improve the precision to 10e-10
 % Update by Feng, W.P., 2012-08-10
 %  1) OUPUT a new parameter of UTMZONE if it's given.
 %     for example, "30 R", or "30R".
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if nargin < 1
     disp(' sim_fpara2oksar(fpara,outname,utmzone)')
     disp(' -> Modified by FWP, @ GU, 2013-03-24')
     return
 end
 %
 if nargin < 3
     utmzone = 3;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %
 fid = fopen(outname,'w');
 if (fid==-1)
     bdir = fileparts(outname);
     mkdir(bdir);
     % try again
     fid = fopen(outname,'w');
 end
 
 nf  = size(fpara,1);
 pi  = 3.14159265;
 counter = 0;
 for nl=1:nf
     counter = counter + 1;
     %dpe = wid*sind(fpara(p,4))+fpara(p,5);
     %wid = dpe/sind(fpara(p,4));
     rfpara = sim_fpara2rand_UP(fpara(nl,:),(fpara(nl,6)*sind(fpara(nl,4))+fpara(nl,5))/sind(fpara(nl,4)),fpara(nl,7));
     [x,y]  = sim_fpara2corners(rfpara,'uc','utm');
     % set small value to zero 
     if abs(fpara(nl,8)) < 10e-10
        fpara(nl,8) = 0;
     end
     if abs(fpara(nl,9)) < 10e-10
         fpara(nl,9) = 0;
     end
     toplen = rfpara(6)-fpara(nl,6);
     if toplen < 10e-10
         toplen = 0;
     end
     %
     % modified by Feng, W.P, 2011-04-15, @ BJ
     % there should be a bug for OKSAR format
     %
%      fpara(nl,8) = (fpara(nl,8) < 0) * fpara(nl,8) + ...
%                    (fpara(nl,8) >=0) * fpara(nl,8) * -1; 
     fpara(nl,8) = -1* fpara(nl,8);
     %
     fprintf(fid,'%s \n',[num2str(x*1000,'% 20.8f') ' ' num2str(y*1000,'% 20.8f') '    --- Fault ' ...
                          num2str(counter) ' ---']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,3),'% 15.8f') '   ' num2str(fpara(nl,4),'% 15.8f') '   ' ...
                          num2str(180) '    s d r']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,8),'% 15.8f') '   '...
                          num2str(fpara(nl,10),'% 15.8f') '                 Slip Opening']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,7),'% 15.8f') '    ' num2str(toplen,'% 15.8f') '    ' ...
                          num2str(rfpara(6),'% 15.8f') '    len top bot']);
     % working for diping slip
     counter = counter + 1; 
     fprintf(fid,'%s \n',[num2str(x*1000,'% 15.8f') ' ' num2str(y*1000,'% 15.8f') '    --- Fault ' ...
                          num2str(counter) ' ---']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,3),'% 15.8f') '   ' num2str(fpara(nl,4),'% 15.8f') '   ' ...
                          num2str(90) '    s d r']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,9),'% 15.8f')  '   '...
                          num2str(fpara(nl,10)) '                 Slip Opening']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,7),'% 15.8f') '    ' num2str(toplen,'% 15.8f') '    ' ...
                          num2str(rfpara(6),'% 15.8f') '    len top bot']);
 end
 if isempty(utmzone)==0
     fprintf(fid,'%s %s\n',utmzone,'--- UTM ZONE ---');
 end
 fclose(fid);
