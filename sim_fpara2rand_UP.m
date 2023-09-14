function rfpara = sim_fpara2rand_UP(fpara,wid,len)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Goals:
 %    Calculate the fault planet from uniform model to distributed model fault
 %    That is to say the new fault model with the zeros depth to surface.
 %    fpara is the uniform model.
 %    UP to the surface
 % Modified by Feng W.P, @ BJ, 2009-10-27
 %    
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % np is the number of patches of fault.
 
 if nargin < 1
     disp('rfpara = sim_fpara2rand_UP(fpara,wid,len)');
     return
 end
 %
 np     = size(fpara,1);
 rfpara = fpara;
 for p  = 1:np
     %
     if nargin<2
        wid = fpara(p,6);
        %dpe = wid*sind(fpara(p,4))+fpara(p,5);
        %wid = dpe/sind(fpara(p,4));
        len = fpara(p,7);
     end
     if nargin<3
        len = fpara(p,7);
     end   
     xcent  = fpara(p,1);  % the center of center of fault plane
     ycent  = fpara(p,2);  % the center of center of fault plane
     rlen   = fpara(p,7);  % 
     depth  = fpara(p,5);  % the center of the top line to the surface
     strike = fpara(p,3);
     dip    = fpara(p,4);
     %
     i      = sqrt(-1);
     %ll    = -0.5*rlen - i*width*cosd(dip);  % low left corner
     %lr    =  0.5*rlen - i*width*cosd(dip);  % low right corner
     ul     = -0.5*rlen + i*0*cosd(dip);      % up left corner
     strkr  = (90-strike)*pi/180;             % ll = (xcent+ycent*i) + ll*exp(i*strkr);  
     ul     = (xcent+ycent*i) + ul*exp(i*strkr);   
     top    = depth;                          % width*sind(dip);
     rwidth = top/sind(dip);
     rul    = 0*rlen + i*rwidth*cosd(dip);    % up right corner
     rur    = 1*rlen + i*rwidth*cosd(dip);    % up right corner
     rul    = ul+rul*exp(i*strkr);
     rur    = ul+rur*exp(i*strkr);
     rfpara(p,5) = 0;
     rfpara(p,1) = (real(rul)+real(rur))/2;   % (real(rul)+real(rur)+real(ll)+real(lr))/4;
     rfpara(p,2) = (imag(rul)+imag(rur))/2;   % (imag(rul)+imag(rur)+imag(ll)+imag(lr))/4;
     rfpara(p,6) = wid(p);
     rfpara(p,7) = len(p);
 end
