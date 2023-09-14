function sim_plot3d2oksar(file3d,outoksar,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng, W.P, 2011-05-03
%   convert a new fault parameters to oksar format
%   the new format including following columns:
%        x, y, strike, dip, rake, slip, length, top depth, bottom depth 
% latest modification @ 20110503
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified by Feng, W.P, @ BJ, 20110704
% change structure of Oksar format.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 2
    outoksar = 'Fault.oksar';
end
if nargin < 3
    isplot = 0;
end
fpara = load(file3d);
counter = 0;
fid = fopen(outoksar,'w');
%
 for nl=1:size(fpara,1)
     counter = counter + 1;
     %
     %fpara(nl,8) = -1* fpara(nl,8);
     %
     strikeslip = (fpara(nl,6)*cosd(fpara(nl,5)))*-1;
     dipslip    = fpara(nl,6)*sind(fpara(nl,5));
     %
     fprintf(fid,'%s \n',[num2str(fpara(nl,1),'% 20.8f') ' ' num2str(fpara(nl,2),'% 20.8f') '    --- Fault ' ...
                          num2str(counter) ' ---']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,3),'% 15.8f') '   ' num2str(fpara(nl,4),'% 15.8f') '   ' ...
                          num2str(180) '    s d r']);
     fprintf(fid,'%s \n',[num2str(strikeslip,'% 15.8f') '   '...
                          num2str(0,'% 15.8f') '                 Slip Opening']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,7),'% 15.8f') '    ' num2str(fpara(nl,8),'% 15.8f') '    ' ...
                          num2str(fpara(nl,9),'% 15.8f') '    len top bot']);
     % working for diping slip
     counter = counter + 1; 
     fprintf(fid,'%s \n',[num2str(fpara(nl,1),'% 15.8f') ' ' num2str(fpara(nl,2),'% 15.8f') '    --- Fault ' ...
                          num2str(counter) ' ---']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,3),'% 15.8f') '   ' num2str(fpara(nl,4),'% 15.8f') '   ' ...
                          num2str(90) '    s d r']);
     fprintf(fid,'%s \n',[num2str(dipslip,'% 15.8f')  '   '...
                          num2str(0) '                 Slip Opening']);
     fprintf(fid,'%s \n',[num2str(fpara(nl,7),'% 15.8f') '    ' num2str(fpara(nl,8),'% 15.8f') '    ' ...
                          num2str(fpara(nl,9),'% 15.8f') '    len top bot']);
 end
 fclose(fid);
%
% Modified by Feng, W.P, @ BJ, 20110704
%
fpara = sim_oksar2SIM(outoksar);
sim_fpara2oksar_SYN(fpara,outoksar);
%
if isplot==1
    fpara = sim_oksar2SIM(outoksar);
    sim_fig3d(fpara,[],[],[],[],1,1.5,[0,0,0],0.001);
end
