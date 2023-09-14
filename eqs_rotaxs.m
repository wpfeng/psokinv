function [cx,cy] = eqs_rotaxs(cx0,cy0,azimuth,p0)
%
%************** FWP Work ************************
%Developed by FWP, @UoG/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com for more details
%************** Good Luck ***********************
 %
 %
 % LOG:
 % Feng Wanpeng, IGP/CEA, 2009/11/23/
 %               added some log info 
     
 if nargin < 3
    disp('[cx,cy] = eqs_rotaxs(cx0,cy0,azimuth,p0)');
    disp(' Input:');
    disp('      cx0, the x-coordinates of points');
    disp('      cy0, the y-coordinates of points');
    disp('  azimuth, the azimuth angle, counterclockwise is positive and east is zero ');
    disp('       p0, the referenced points, e.g, [x0,y0]');
    disp('           if you do not give it, the center point will be used');
    disp('  Output:');
    disp('       cx, the roted x-coordinates along the azimuth');
    disp('       cy, the roted y-coordinates along the azimuth');
    %
    cx = [];
    cy = [];
    return
 end
 %
 i       = sqrt(-1);
 pi      = 3.14159265;
 strkr   = (90-azimuth)*pi/180; 
 %
 if nargin < 4
    x0 = 0;%min(cx0(:));
    y0 = 0;%min(cy0(:));
 else
    x0 = p0(1);
    y0 = p0(2);
 end
 %
 start   = (x0+y0*i);
 outdata = ((cx0+cy0.*i)-start).*exp(-i*strkr);
 cx      = real(outdata);
 cy      = imag(outdata);%
 
