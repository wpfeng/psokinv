function fpara = sim_fparaconv(fpara,slocal,elocal)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%Input:
%    fpara, a set of parameters for a fault model
%    slocal, the type of initial model.
%         -> 0, the up-center
%         -> 1, left-top-point
%         -> 2, right-top-point
%         -> 3, central point in the fault plane
%         -> 4, left-bot-point
%         -> 5, right-bot-point
%         -> 6, center boundary with surface, but depth is the depth of top-line.
%         -> 7, center on topline, but depth is zero.
%         -> 11,left-top points of topline
%         -> 12,right-top point of topline
%         -> 13,centre of bottom line...
%    elocal, the type of output model
%
% Modified by Feng W.P, Institute of Geophysics, Chinese Earthquake Administrator
% 7 Oct 2009
% Modified by Feng W.P, Institute of Geophysics, CEA
% 2010-04-10,the depth with changing with change of type.
% -> add new choice for slocal, 4
% Modified by Feng W.P, IGP-CEA
% 2010-05-10,add new type, 7
%
% 2010-05-19,add new type,11 and 12
% 11, the x and y coordinates on the upboundary lr
% 12, the x and y coordinates on the right of upboundary...
%
% 2011-01-14, fixed some bugs when type
% 2011-08-21, fixed some bugs when type is 11 or 12
%    by Feng, W.P., @ BJ, 2011/08/21
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin<1
   disp('fpara = sim_fparaconv(fpara,slocal,elocal)');
   return
end
 
for nk = 1:size(fpara,1)
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if slocal==7
        %
        tfpara      = fpara(nk,:);
        tfpara(1,5) = 0;
        fpara(nk,:) = sim_fpara2whole(tfpara,fpara(nk,5));
        slocal      = 0;
    end
    %  
    strike = fpara(nk,3);
    dip    = fpara(nk,4);
    dep    = fpara(nk,5);
    wid    = fpara(nk,6);
    rlen   = fpara(nk,7);
    x0     = fpara(nk,1);
    y0     = fpara(nk,2);
    %
    i      = sqrt(-1);
    strkr  = (90-strike)*pi/180;
    
    %
    switch slocal
        case 0
            ll = -0.5*rlen - i*wid*cosd(dip);    % low-left ,ul
            lr =  0.5*rlen - i*wid*cosd(dip);    % low-right,ur
            ul = -0.5*rlen + i*  0*cosd(dip);    % up-left  ,ll
            ur =  0.5*rlen + i*  0*cosd(dip);    % up-right ,lr
            sdep = wid*sind(dip)+dep;
        case 1
            ll = 0    - i*wid*cosd(dip);    % low-left ,ul
            lr = rlen - i*wid*cosd(dip);    % low-right,ur
            ul = 0    + i*  0*cosd(dip);    % up-left  ,ll
            ur = rlen + i*  0*cosd(dip);    % up-right ,lr
            sdep= wid*sind(dip)+dep;
        case 2
            ll = -rlen- i*wid*cosd(dip);    % low-left ,ul
            lr = 0    - i*wid*cosd(dip);    % low-right,ur
            ul = -rlen+ i*  0*cosd(dip);    % up-left  ,ll
            ur = 0    + i*  0*cosd(dip);    % up-right ,lr
            sdep= wid*sind(dip)+dep;
        case 3
            ll = -0.5*rlen - i*(wid/2)*cosd(dip);    % low-left ,ul
            lr =  0.5*rlen - i*(wid/2)*cosd(dip);    % low-right,ur
            ul = -0.5*rlen + i*(wid/2)*cosd(dip);    % up-left  ,ll
            ur =  0.5*rlen + i*(wid/2)*cosd(dip);    % up-right ,lr
            sdep = wid/2*sind(dip)+dep;
        case 4
            ll =  0     - i*  0*cosd(dip);      % low-left ,ul
            lr =  rlen  - i*  0*cosd(dip);      % low-right,ur
            ul =  0     + i*wid*cosd(dip);    % up-left  ,ll
            ur =  rlen  + i*wid*cosd(dip);    % up-right ,lr
            sdep = dep;
        case 5
            ll = -rlen  - i*0/2*cosd(dip);    % low-left ,ul
            lr =  0     - i*0/2*cosd(dip);    % low-right,ur
            ul =  -rlen + i*wid*cosd(dip);    % up-left  ,ll
            ur =  0     + i*wid*cosd(dip);    % up-right ,lr
            sdep = dep;
            % add 6 to the center of up-boundary
        case 6
            ll = -0.5*rlen  - i*(wid+dep/sind(dip))*cosd(dip);    % low-left ,ul
            lr =  0.5*rlen  - i*(wid+dep/sind(dip))*cosd(dip);    % low-right,ur
            ul = -0.5*rlen  - i*(dep/sind(dip))*cosd(dip);    % up-left  ,ll
            ur =  0.5*rlen  - i*(dep/sind(dip))*cosd(dip);    % up-right ,lr
            sdep= wid*sind(dip)+dep;
        case 11
            %%%%% Fixed a bug by Feng, W.P., 2011/08/21, @ BJ
            %
            %             dep      = fpara(nk,5);
            %             strkr    = (90-strike)*pi/180;
            %             dcx      = 0+dep/sind(fpara(nk,4)).*i;
            %             dcx      = (x0+y0*i) + dcx*exp(i*strkr);
            %             x0       = real(dcx);
            %             y0       = imag(dcx);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ll = 0    - i*wid*cosd(dip);    % low-left ,ul
            lr = rlen - i*wid*cosd(dip);    % low-right,ur
            ul = 0    + i*  0*cosd(dip);    % up-left  ,ll
            ur = rlen + i*  0*cosd(dip);    % up-right ,lr
            sdep= wid*sind(dip)+dep;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 12
            %%%%% Fixed a bug by Feng, W.P., 2011/08/21, @ BJ
            %             dep      = fpara(nk,5);
            %             strkr    = (90-strike)*pi/180;
            %             dcx      = 0+dep/sind(fpara(nk,4)).*i;
            %             dcx      = (x0+y0*i) + dcx*exp(i*strkr);
            %             x0       = real(dcx);
            %             y0       = imag(dcx);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ll = -rlen- i*wid*cosd(dip);    % low-left ,ul
            lr = 0    - i*wid*cosd(dip);    % low-right,ur
            ul = -rlen+ i*  0*cosd(dip);    % up-left  ,ll
            ur = 0    + i*  0*cosd(dip);    % up-right ,lr
            sdep= wid*sind(dip)+dep;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 13
            % centre of bottom line of the fault 
            ll = -0.5*rlen - i*0*cosd(dip);    % low-left ,ul
            lr =  0.5*rlen - i*0*cosd(dip);    % low-right,ur
            ul = -0.5*rlen + i*wid*cosd(dip);    % up-left  ,ll
            ur =  0.5*rlen + i*wid*cosd(dip);    % up-right ,lr
            sdep = dep;
    end
    ul = (x0+y0*i) + ul*exp(i*strkr);
    ur = (x0+y0*i) + ur*exp(i*strkr);
    ll = (x0+y0*i) + ll*exp(i*strkr);
    lr = (x0+y0*i) + lr*exp(i*strkr);
    %
    switch elocal
        case 0
            x = (real(ur)+real(ul))/2;
            y = (imag(ur)+imag(ul))/2;
            sdep = sdep-wid*sind(dip);
        case 1
            x = real(ul);
            y = imag(ul);
            sdep = sdep-wid*sind(dip);
        case 2
            x = real(ur);
            y = imag(ur);
            sdep = sdep-wid*sind(dip);
        case 3
            x = (real(ur)+real(ul)+real(lr)+real(ll))/4;
            y = (imag(ll) +imag(lr) +imag(ur) +imag(ul) )/4;
            sdep = sdep-wid/2*sind(dip);
        case 4
            x = real(ll);
            y = imag(ll);
            sdep   = sdep-wid*sind(dip);
        case 5
            x = real(lr);
            y = imag(lr);
            sdep = sdep-wid*sind(dip);
        case 6
            rfpara = sim_fpara2rand_UP(fpara(nk,:));
            x      = rfpara(1);
            y      = rfpara(2);
            sdep   = sdep-wid*sind(dip);
        case 7
            rfpara2 = sim_fpara2rand_UP(fpara(nk,:));
            [x,y]   = sim_fpara2corners(rfpara2,'uc');
            %x = (real(lr)+real(ll))/2;
            %y = (imag(lr)+imag(ll))/2;
            sdep = fpara(nk,5);
        case 11
            x = real(ul);
            y = imag(ul);  
            sdep   = sdep-wid*sind(dip);
        case 12
             x = real(ur);
             y = imag(ur);  
            sdep   = sdep-wid*sind(dip);
        case 13
             x = (real(lr)+real(ll))/2;
             y = (imag(lr)+imag(ll))/2;
             sdep = sdep-wid*sind(dip);
    end
%
   fpara(nk,1) = x;
   fpara(nk,2) = y;
   fpara(nk,5) = sdep;
end
        
 
