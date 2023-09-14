function rfpara = sim_fpara2whole(fpara,rdepth,maxdepth)
 %
 % Purpose:
 %    Calculate the fault planet from uniform model to distributed model fault
 %    That is to say the new fault model with the zeros depth to surface.
 %    fpara is the uniform model.
 % Input:
 %     fpara, 1*10, SIM fault model
 %    rdepth, the depth from top bounday to the surface
 % Modified by Feng W.P, IGP/CEA,2009/11/24
 %    to add a new variable, rdepth
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % np is the number of patches of fault.
 if nargin<2
    rdepth = 0;
 end
 
 if nargin < 3
     maxdepth = sind(fpara(:,4)).*fpara(:,6) + rdepth;
 end
 if numel(maxdepth)<numel(fpara(:,1))
     cdepth = maxdepth(1);
     maxdepth = fpara(:,1).*0 + cdepth;
 end
 %
 np = size(fpara,1);
 rfpara = fpara;
 for p = 1:np
     %
     xcent      = fpara(p,1);  % the center of center of UP line
     ycent      = fpara(p,2);  % the center of center of UP line
     rlen       = fpara(p,7);
     %width      = fpara(p,6);
     depth      = fpara(p,5);  % the center of the top line to the surface
     strike     = fpara(p,3);
     dip        = fpara(p,4);
     %
     i      = sqrt(-1);
     ul     = -0.5*rlen + i*0*cosd(dip);  
     strkr  = (90-strike)*pi/180; 
     ul     = (xcent+ycent*i) + ul*exp(i*strkr);  
     top    = depth; 
     rwidth = top/sind(dip);
     rul = 0*rlen + i*rwidth*cosd(dip);  % up right corner
     rur = 1*rlen + i*rwidth*cosd(dip);  % up right corner
     rul = ul+rul*exp(i*strkr);
     rur = ul+rur*exp(i*strkr);
     rfpara(p,5) = 0;
     rfpara(p,1) = (real(rul)+real(rur))/2;%(real(rul)+real(rur)+real(ll)+real(lr))/4;
     rfpara(p,2) = (imag(rul)+imag(rur))/2;%(imag(rul)+imag(rur)+imag(ll)+imag(lr))/4;
     rfpara(p,6) = (maxdepth(p)-rdepth)/sind(rfpara(p,4));%rwidth +width;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     top         = rdepth;
     %width       = top/sind(dip)+rfpara(p,6);
     topc        =    0*rlen - i*top/sind(dip)*cosd(dip); 
     topc        = (rfpara(p,1)+rfpara(p,2)*i) + topc*exp(i*strkr);
     rfpara(p,1) = real(topc);
     rfpara(p,2) = imag(topc);
     rfpara(p,5) = rdepth;
 end
