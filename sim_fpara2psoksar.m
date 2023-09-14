function sim_fpara2psoksar(fpara,outname)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 % Purpose:
 %        output the faults' parameters in SIM formation into a file as psoksar structure
 %
 % Input:
 %       fpara, n*10, the parameters of n faults
 %     outname, string variable, fullpath parameters
 % Writen by Feng W.P, 10/04/2009
 %
 if nargin <1 || isempty(fpara)==1 
    disp('sim_fpara2oksar(fpara,outname)');
    disp('>>>>fpara, the faultmodel in SIM format');
    disp('>>>>outname, output file for the psoksar format');
    return
 end
 fid = fopen(outname,'w');
 nf  = size(fpara,1);
 pi  = 3.14159265;
 for nl=1:nf
     [x,y] = sim_fpara2corners(fpara(nl,:),'cc','utm');
     fprintf(fid,'%s \n',[num2str(x*1000,'% 20.8f') ' ' num2str(y*1000,'% 20.8f') '    --- Fault ' ...
                          num2str(nl) ' ---']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,3),'% 15.8f') '   ' num2str(fpara(nl,4),'% 15.8f') '   ' ...
                          num2str(atan2(fpara(nl,9),fpara(nl,8))*180./pi,'% 15.8f') '    s d r']);
     fprintf(fid,'%s \n',[num2str(sqrt(fpara(nl,8)^2+fpara(nl,9)^2),'% 15.8f') '   '...
                          num2str(fpara(nl,10),'% 15.8f') '                 Slip Opening']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,7),'% 15.8f') '    ' num2str(fpara(nl,5),'% 15.8f') '    ' ...
                          num2str(fpara(nl,6)*sind(fpara(nl,4))+fpara(nl,5),'% 15.8f') '    len top bot']);
                          
 end
 fclose(fid);
