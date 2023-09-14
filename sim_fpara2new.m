function rfpara = sim_fpara2new(fpara,depth)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 %
 x0    = fpara(1);
 y0    = fpara(2);
 dip   = fpara(4);
 strike= fpara(3);
 wid   = depth/sind(dip);
 i     = sqrt(-1);
 %rlen  = 0;
 new   = 0 - i*wid*cosd(dip);    % low-left ,ul
 strkr = (90-strike)*pi/180;
 rnew  = (x0+y0*i) + new*exp(i*strkr); 
 rx    = real(rnew);
 ry    = imag(rnew);
 %rdep  = fpara(5)+depth;
 rfpara= fpara;
 rfpara(1) = rx;
 rfpara(2) = ry;
