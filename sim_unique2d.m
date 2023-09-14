function outdata = sim_unique2d(indata)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 %
 %whos indata
 np    = size(indata,1);
 ind   = [];
 cdata = indata;
 while np~=0
     if size(cdata,1)>0
         tdata         = cdata(:,1:2);
         tdata(:,1)    = tdata(:,1)- cdata(1,1);
         tdata(:,2)    = tdata(:,2)- cdata(1,2);
         flag          = tdata*[1 1]';
         cind          = find(abs(flag)<=0.00001);
         ind           = [ind;cind(1)];
         cdata(cind,:) = [];
     end
     np = size(cdata,1);
 end
 %
 outdata = indata(ind,:); 
