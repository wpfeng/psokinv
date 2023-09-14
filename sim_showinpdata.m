function sim_showinpdata(inpdata)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
input = sim_inputdata(inpdata);
x   =  input(:,1);
y   =  input(:,2);
mindist = sim_mindistv2([x(:) y(:)]);
np      = size(x(:),1);
XI      = zeros(np,5);
YI      = zeros(np,5);
XI(:,1) = x-mindist/2;
XI(:,2) = x+mindist/2;
XI(:,3) = x+mindist/2;
XI(:,4) = x-mindist/2;
XI(:,5) = x-mindist/2;
%
YI(:,1) = y-mindist/2;
YI(:,2) = y-mindist/2;
YI(:,3) = y+mindist/2;
YI(:,4) = y+mindist/2;
YI(:,5) = y-mindist/2;
whos XI
whos YI
patch(XI',YI',input(:,3)');
