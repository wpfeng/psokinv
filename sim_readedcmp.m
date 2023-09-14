function data = sim_readedcmp(edfile)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
fid = fopen(edfile,'r');
%
% jump 3 rows
fgetl(fid);
fgetl(fid);
fgetl(fid);
%
data    = zeros(1,5);
counter = 0;
while ~feof(fid)
    
    temp = textscan(fid,'%f %f %f %f %f\n');
    if isempty(temp{1})==0
        counter = counter + 1;
        data(counter,:) = [temp{1},temp{2},temp{3},temp{4},temp{5}];
    end
end
fclose(fid);
