function [dfpara,uc] = sim_fpara2dist(fpara,al,aw,dl,dw,type,rdepth,dampingfactor,fixed_depth)
%
% Purpose:
%  To discretize a fault plane into regular-size sub-faults. 
% Input:
%  fpara, an input single-fault plane parameter
%**************************************************************************
%  al, the length to each fault patch.
%  aw, the width to each fault patch.
%  dl, the length of sub-patch
%  dw, the width  of sub-patch
%
% Modified by Feng Wanpeng, now dl and dw can be decimal.
% 2010-06-28
% type is working for indication of dw.
% "w" means dw shows values along dip directions...
%*************************************************************************
% Updated by FWP, @ UoG, 2014-02-03
% -> dampingfactor is available now...
% Updated by Feng, W.P., @ YJ, 2015-05-12
%
format long
if nargin < 8
    dampingfactor = 1;
end
if nargin < 9
    fixed_depth = 0;
end
%
if nargin<1
    disp('[dfpara,uc] = sim_fpara2dist(fpara,al,aw,dl,dw,type)');
    disp('       fpara, the fault model(s) in SIM format');
    disp('       al,    the length to each fault path');
    disp('       aw,    the width to each fault patch');
    disp('       dl,    the length of sub-patch');
    disp('       dw,    the width  of sub-patch');
    disp('     type,    switch of flag of direction along dip or width');
    
    return
end
if nargin < 6
    type = 'w';
end
if nargin < 7
    rdepth = 0;
end
%
% Updated by Feng, W.P., @ Yj, 2015-05-29
%
if isnan(rdepth)
    rdepth = fpara(5);
end
%
format long
%
if strcmpi(type,'foc')
   %
   disp(' sim_fpara2dist -> foc is being used for fault sampling!');
   focfpara      = fpara;
   focfpara      = sim_fparaconv(focfpara,0,3);
   focfpara(:,6) = aw;
   focfpara      = sim_fparaconv(focfpara,3,0);
   %
   if focfpara(5) > rdepth
     rdepth = focfpara(5);
   else
     focfpara = sim_fpara2whole(focfpara,rdepth);
   end
   fpara         = focfpara;
   type          = 'w';
else
   fpara   = sim_fpara2whole(fpara,rdepth);
end
%
%
pi         = 3.14159265358979323846264338328;
%fpara      = sim_fpara2whole(fpara,rdepth);
xcent      = fpara(1,1);  % the center of topline of fault plane
ycent      = fpara(1,2);  % the center of topline of fault plane
rlen       = fpara(1,7);
width      = fpara(1,6);
depth      = fpara(1,5);  % the center of the top line to the surface
strike     = fpara(1,3);
dip        = fpara(1,4);
sslip      = fpara(1,8);
dslip      = fpara(1,9);
i          = sqrt(-1);
strkr      = (90-strike)*pi/180;
uc         = (xcent+ycent*i);%+ uc*exp(i*strkr);  % up center corner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(aw)==1
    aw = width;
end
if isempty(al)==1
    al = rlen;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  if strcmpi(type,'d')
%     dw = dw ./ sind(dip);
%  end

if dampingfactor == 1
    raw    = round(al/dl);
    dl     = al/raw;
    col    = round(aw/dw);
    dfpara = zeros(raw*col,10);
    %
    if strcmpi(type,'w')
        ll     = -1*raw/2*dl- i*col*dw*cosd(dip);  %
    else
        ll     = -1*raw/2*dl- i*col*dw/sind(dip)*cosd(dip);  %
    end
    ll     = uc + ll*exp(i*strkr);  % coordinates at left bottom points
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nop    = 1;
    for nr = 1:raw
        for nc = 1:col
            %
            if strcmpi(type,'w')==1
                dfpara(nop,6) = dw;
            else
                dfpara(nop,6) = dw./sind(dip);
            end
            %
            dfpara(nop,7) = dl;
            dfpara(nop,3) = strike;
            dfpara(nop,4) = dip;
            i             = sqrt(-1);
            %
            if strcmpi(type,'w') == 1
                %
                tur            = (nr-1/2)*dl +i*dw*(nc)*cosd(dip);
                tur            = ll + tur * exp(i*strkr);
                dfpara(nop,1)  = real(tur);
                dfpara(nop,2)  = imag(tur);
                dfpara(nop,5)  = col*dw*sind(dip) - nc*dw*sind(dip)+depth;
                %
            else
                tur           = (nr-1/2)*dl +i*dw/sind(dip)*(nc)*cosd(dip);
                tur           = ll + tur*exp(i*strkr);
                dfpara(nop,1) = real(tur);
                dfpara(nop,2) = imag(tur);
                dfpara(nop,5) = col*dw - nc*dw+depth;
            end
            dfpara(nop,8) = sslip;
            dfpara(nop,9) = dslip;
            nop = nop+1;
        end
    end
else
    %
    dfpara = [];
    switch upper(type)
        case 'W'
            refdepth = aw*sind(dip);
        otherwise
            refdepth = aw;
    end
    refdepth = refdepth + rdepth;
    cdl    = dl;
    cdw    = dw;
    while rdepth < refdepth
        npatch = fix(al/cdl);
        if npatch == 0
            npatch = 1;
        end
        xsize      = al/npatch;
        %
        tempfpara  = sim_fpara2dist(fpara,al,xsize,xsize,cdw,type,rdepth,1);
        cdw        = cdw*dampingfactor;
        cdl        = cdl*dampingfactor;
        dfpara     = [dfpara;tempfpara];
        %
        if size(tempfpara)>0
           [t_mp,t_mp,iz]   = sim_fpara2corners(tempfpara(1,:),'dc');
        else
            iz = refdepth + 1;
        end
        rdepth     = iz;
    end
end
if fixed_depth == 1
    tmpfpara = [];
    maxdep = aw / sind(mean(dfpara(:,4)));
    %
    for i = 1:size(dfpara,1)
        if dfpara(i,5) < maxdep
          [x,y,z] = sim_fpara2corners(dfpara(i,:),'dc');
          if z > maxdep
             dfpara(i,6) = (maxdep - dfpara(i,5))/sind(dfpara(i,4));
             %
          end
          tmpfpara = [tmpfpara;dfpara(i,:)];
        end
         
    end
    dfpara = tmpfpara;
end
%
