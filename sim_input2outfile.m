function sim_input2outfile(input,outname)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Developed by FWP, @ IGP, BJ, 2010-10-01
%
if nargin < 1
    disp('sim_input2outfile(input,outname)');
    return
end
%
fid = fopen(outname,'w');
fprintf(fid,'%15.8f %15.8f %11.8f %11.8f %11.8f %11.8f %11.8f\n',input');
fclose(fid);
