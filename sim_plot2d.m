function [X,Y,Cx,Cy,Aslip,offx,offy,ind] = sim_plot2d(fpara,xytype,modeltype)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 % Created by Feng Wanpeng!
 % 04/12/2008!
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % xytep,1 for x-direction; 2 for y-direction.
 %
 if nargin < 2 
    xytype = 1;
 end
 if nargin < 3
     modeltype = 'fpara';
 end
np   = size(fpara,1);
X    = eye(4,np);
Y    = eye(4,np);
%offx = min(fpara(:,1));
%offy = fpara(fpara(:,1)==min(fpara(:,1)),2);
Cx   = eye(1,np);
Cy   = Cx;
%
rlen  = fpara(1,7);
width = fpara(1,6);
%
Aslip      = zeros(np,3);
if strcmpi(modeltype,'fpara')
    [~,ind]  = sim_fpara2sortv3(fpara,xytype);
else
    [~,ind]  = sim_fpara2sort_fixmodel(fpara,xytype);
end
fpara(:,1) = ind(:,1).*rlen-rlen/2;
fpara(:,2) = ind(:,2).*width;
fpara(:,3) = 90;
fpara(:,4) = 0;
fpara(:,5) = 0;
%
for p = 1:np
  xcent      = fpara(p,1);  % the center of center of UP line
  ycent      = fpara(p,2);  % the center of center of UP line
  rlen       = fpara(p,7);
  width      = fpara(p,6);
  %depth      = fpara(p,5);  % the center of the top line to the surface
  strike     = fpara(p,3);
  Aslip(p,1) = fpara(p,8);
  Aslip(p,2) = fpara(p,9);
  Aslip(p,3) = fpara(p,10);
  dip        = fpara(p,4);
  %
  i  = sqrt(-1);
  ll = -0.5*rlen + i*0*cosd(dip);  
  lr =  0.5*rlen + i*0*cosd(dip); 
  ul = -0.5*rlen - i*width*cosd(dip); 
  ur =  0.5*rlen - i*width*cosd(dip);
 %
 %top = depth;%- width*sind(dip);
 %bot = depth+ width*sind(dip);
 %
 strkr = (90-strike)*pi/180;
 ll = (xcent+ycent*i) + ll*exp(i*strkr);  % up-edge left coordinates
 lr = (xcent+ycent*i) + lr*exp(i*strkr);  % up-edge right coordinates
 ul = (xcent+ycent*i) + ul*exp(i*strkr);  % low-edge left corrdinates
 ur = (xcent+ycent*i) + ur*exp(i*strkr);  % low-edge right coordinates
 %
 X(1:4,p) = [real(ll) real(lr) real(ur) real(ul)]';
 Y(1:4,p) = [imag(ll) imag(lr) imag(ur) imag(ul)]';
 Cx(p) = mean(X(:,p));%+0.0001;
 Cy(p) = mean(Y(:,p));%-width/2;%+0.0001;
 

end
Y= Y-min(Y(:));
X= X-min(X(:));
Cx = Cx-min(X(:));
Cy = Cy-min(Y(:));
offx = min(X(:));
offy = min(Y(:));
