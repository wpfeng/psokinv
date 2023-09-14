function points = sim_fpara2profile(fpara,lens,np)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 %
 %
 % Created by Feng, Wanpeng, 2011-03-15
 if nargin < 3
    np = 200;
 end
 if nargin < 2
    lens = 50;
 end
 rfpara = sim_fpara2whole(fpara);
 rfpara(3) = fpara(3) + 90;
 rfpara(7) = lens;
 [x1,y1]   = sim_fpara2corners(rfpara,'ul');
 [x2,y2]   = sim_fpara2corners(rfpara,'ur');
 x         = linspace(x1,x2,np);
 y         = linspace(y1,y2,np);
 points    = [x(:),y(:)];
 
