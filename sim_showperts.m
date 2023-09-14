function sim_showperts(prefix)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 if nargin<1
    prefix = '*.okinv';
 end
 files = dir(prefix);
 nfile = size(files,1);
 for ni=1:nfile
     data = sim_inputdata(files(ni).name);
     plot(data(:,3),'color',rand(1,3));
     hold on
 end
