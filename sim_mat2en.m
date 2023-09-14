function sim_mat2en(nrow,nlin,xmin,ymax,xstep,ystep,...
                     zone,hdrname,numband)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
                   
%
%
% to write a header file for ENVI image
% Feng W.P, 2009 Agu 16, added some info
%
fid = fopen(hdrname,'w');
fprintf(fid,'%s\n','ENVI');
fprintf(fid,'%s\n','description = {');
fprintf(fid,'%s\n','  Matlab2ENVI,');
outt = clock();
fprintf(fid,'%s\n',['  ',date(),num2str(outt(4)),':',num2str(outt(5)),':',num2str(outt(5)),'}']);
fprintf(fid,'%s\n',['samples = ',num2str(nrow)]);
fprintf(fid,'%s\n',['lines   = ',num2str(nlin)]);
fprintf(fid,'%s\n',['bands   = ',num2str(numband)]);
fprintf(fid,'%s\n','header offset = 0');
fprintf(fid,'%s\n','file type = ENVI Standard');
fprintf(fid,'%s\n','data type = 4');
fprintf(fid,'%s\n','interleave = bsq');
fprintf(fid,'%s\n','sensor type = Unknown');
fprintf(fid,'%s\n','byte order = 0');
fprintf(fid,'%s\n','x start = 0');
fprintf(fid,'%s\n','y start = 0');
fprintf(fid,'%s\n',zone);% ['map info = {UTM, 1.000, 1.000, ',num2str(xmin),',',...
                         % num2str(ymax),',',num2str(xstep),',',num2str(ystep),',',...
                         % num2str(zone),',',' North, WGS-84, units=Meters}']);
fprintf(fid,'%s\n','wavelength units = Unknown');
fprintf(fid,'%s\n','band names = {');
fprintf(fid,'%s\n','InSAR, Rewrapped}');
fclose(fid);
