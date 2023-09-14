function [ox,oy] = geo2okada3d(x,y,faultp)
%
% Managing coordiates for observations corresponding to a reference fault
% Developed by Wanpeng Feng, @BJ, 2008
%
xfaultp = sim_fparaconv(faultp,0,3);
xstart  = xfaultp(1);
ystart  = xfaultp(2);
dip     = xfaultp(4);
strike  = xfaultp(3);
%
i       = sqrt(-1);
cc      = -1*0 -i*0*cosd(dip);
strkr   = (90-strike)*pi/180;
cc      = (xstart+ystart*i)+cc.*exp(i*strkr);
pokada  = ((x+y.*i)-cc).*exp(-i*strkr);
ox      = real(pokada);
oy      = imag(pokada);