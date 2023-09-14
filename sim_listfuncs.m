function sim_listfuncs(prefix,dbdir)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
if nargin<1
    prefix = '*';
end
if nargin<2
    dbdir = 'D:\mdbase\dbase_2';
end
files = dir(fullfile(dbdir,['*',prefix,'*.m']));
for ni=1:size(files,1)
    disp(files(ni).name);
end
