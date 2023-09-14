function sim_fpara2oksar_SYN(fpara,outname,utmzone)
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
 % Modified by Feng, W.P, 2011-04-15
 %  1) fix a bug, when fpara -> oksar, strike slip should be negtive...
 %  2) improve the precision to 10e-10
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Modified by Feng, W.P, 2011-06-09, due to sim_fpara2oksar
 % 1) now version will ouput a oksar file from fpara. And the single fault
 % will appear just one time, which is different with sim_fpara2oksar.
 % 2) improve more precision...
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%
 % Updated by Feng,W.P.,@ GU, 2012-09-26
 % utmzone has been added into oksarfile...
 %
 %%
 if nargin < 3
     utmzone = [];
 end
 %
 fid = fopen(outname,'w');
 nf  = size(fpara,1);
 %
 counter = 0;
 for nl = 1:nf
     counter = counter + 1;
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
     % 
     %fpara(nl,8) = -1* fpara(nl,8);
     cslip  = sqrt(fpara(nl,8).^2 + fpara(nl,9).^2);
     %
     crake  = sim_calrake(fpara(nl,:));
     %
     fprintf(fid,'%s \n',[num2str(x*1000,'%20.10f') ' ' num2str(y*1000,'%20.10f') '    --- Fault ' ...
                          num2str(counter) ' ---']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,3),'%15.10f') '   ' num2str(fpara(nl,4),'%15.10f') '   ' ...
                          num2str(crake,'%15.10f') '    s d r']);
     fprintf(fid,'%s \n',[num2str(cslip,'%15.10f') '   '...
                          num2str(fpara(nl,10),'%15.10f') '                 Slip Opening']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,7),'%15.10f') '    ' num2str(toplen,'%15.10f') '    ' ...
                          num2str(rfpara(6),'%15.10f') '    len top bot']);
     % working for diping slip
     %counter = counter + 1; 
     
 end
 %fclose(fid);
 if isempty(utmzone)==0
     fprintf(fid,'%s %s\n',utmzone,'--- UTM ZONE ---');
 end
 fclose(fid);
