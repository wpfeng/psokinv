function sim_ouputinp(inp,outname)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% created by FWP, @ 2012-10-10
fid      = fopen(outname,'w');
fprintf(fid,'%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f\n',inp');
fclose(fid);
