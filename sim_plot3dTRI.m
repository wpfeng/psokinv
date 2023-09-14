function [X,Y,Z,Cx,Cy,Cz,Aslip] = sim_plot3dTRI(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%************** FWP's work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%
%
if nargin<1
   disp('[X,Y,Z,Cx,Cy,Cz,Aslip] = sim_plot3d(fpara)');
   return
end
%
np  = size(fpara,1);
%
X   = eye(4,np);
Y   = eye(4,np);
Z   = eye(4,np);
Cx  = eye(1,np);
Cy  = Cx;
Cz  = Cx;
Aslip= zeros(np,2);
for p = 1:np
  %
  xcent      = fpara(p,1);  % the center of center of UP line
  ycent      = fpara(p,2);  % the center of center of UP line
  rlen       = fpara(p,7);
  width      = fpara(p,6);
  depth      = fpara(p,5);  % the center of the top line to the surface
  strike     = fpara(p,3);
  Aslip(p,1) = fpara(p,8);
  Aslip(p,2) = fpara(p,9);
  dip        = fpara(p,4);
  %
  i  = sqrt(-1);
  ll = -0.5*rlen + i*0*cosd(dip);  
  lr =  0.5*rlen + i*0*cosd(dip); 
  ul = -0.5*rlen - i*width*cosd(dip); 
  ur =  0.5*rlen - i*width*cosd(dip);
 %
 top = depth;%- width*sind(dip);
 bot = depth+ width*sind(dip);
 %
 strkr = (90-strike)*pi/180;
 ll    = (xcent+ycent*i) + ll*exp(i*strkr);  % up-edge left coordinates
 lr    = (xcent+ycent*i) + lr*exp(i*strkr);  % up-edge right coordinates
 ul    = (xcent+ycent*i) + ul*exp(i*strkr);  % low-edge left corrdinates
 ur    = (xcent+ycent*i) + ur*exp(i*strkr);  % low-edge right coordinates
 %
 X(1:4,p) = [real(ll) real(lr) real(ur) real(ul)];
 Y(1:4,p) = [imag(ll) imag(lr) imag(ur) imag(ul)];
 Z(1:4,p) = [-top  -top  -bot  -bot];
 %
 % get the central coordinates on the each patche
 %
 Cx(p) = mean(X(:,p));%+0.01;
 Cy(p) = mean(Y(:,p));%+0.01;
 Cz(p) = mean(Z(:,p));%+0.01;
end
