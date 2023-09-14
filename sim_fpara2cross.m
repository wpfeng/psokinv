function rfpara = sim_fpara2cross(fpara,xytype,maxdepth)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Usage:
%    rfpara = sim_fpara2cross(fpara,xytype);
% Input:
%     fpara, the input fault model in FPARA format
%    xytype, the switch flag:1,working for x-coordinate;2,working for y-coordinate.
% Output:
%   rfpara, with same points between tow joint faults.
% Created by Feng, Wanpeng,2011-01-27
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 2 || isempty(xytype)
   xytype = 1;
end
if nargin < 3
    maxdepth = 20;
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bfpara = fpara;
if prod(fpara(:,7)) == 0
   fpara(:,7) = fpara(:,7) + 10;
end
fpara = sim_fpara2whole(fpara,0,maxdepth);%sim_fpara2rand_UP(fpara,fpara(:,6)+fpara(:,5)./sind(fpara(:,4)),fpara(:,7));
%figure();
%sim_fig3d(fpara);
%
[x,y] = sim_fpara2corners(fpara,'uc');
if xytype == 1
   if mean(fpara(:,3)) > 180
     [tmp_a,indx] = sort(x,'descend');
   else
     [tmp_b,indx] = sort(x);
   end
   %
else
   [tmp_a,indx] = sort(y);
end
fpara = fpara(indx,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cxy = [];
for ni = 2:size(fpara,1)
    %%%%%%%%%%%%%%%%%%%%%%
    [x1,y1] = sim_fpara2corners(fpara(ni-1,:),'ul');
    [x2,y2] = sim_fpara2corners(fpara(ni-1,:),'ur');
    A       = [ x1 y1;x2 y2];
    D       = [1;1];
    cofx1   = A\D;
    %%%%%%%%%%%%%%%%%%%%%%
    [x1,y1] = sim_fpara2corners(fpara(ni,:),'ul');
    [x2,y2] = sim_fpara2corners(fpara(ni,:),'ur');
    A       = [ x1 y1;x2 y2];
    D       = [1;1];
    cofx2   = A\D;
    %%%%%%%%%%%%%%%%%%%%%%
    A       = [cofx1';cofx2'];
    xy      = A\D;
    %%%%%%%%%%%%%%%%%%%%%%
    if ni==2
       [x00,y00] = sim_fpara2corners(fpara(ni-1,:),'ul');
       dist      = sqrt((x00-xy(1)).^2+(y00-xy(2)).^2);
       fpara(ni-1,1) = (x00+xy(1))/2;
       fpara(ni-1,2) = (y00+xy(2))/2;
       fpara(ni-1,7) = dist;
    else
       %[x01,y01] = sim_fpara2corners(fpara(ni-1,:),'ur');
       dist          = sqrt((cxy(1)-xy(1)).^2+(cxy(2)-xy(2)).^2);
       fpara(ni-1,1) = (cxy(1)+xy(1))/2;
       fpara(ni-1,2) = (cxy(2)+xy(2))/2;
       fpara(ni-1,7) = dist;
    end
    cxy     = xy;
end
%
[x01,y01]   = sim_fpara2corners(fpara(ni,:),'ur');
dist        = sqrt((x01-cxy(1)).^2+(y01-cxy(2)).^2);
fpara(ni,1) = (x01+xy(1))/2;
fpara(ni,2) = (y01+xy(2))/2;
fpara(ni,7) = dist;
rfpara      = fpara;
if prod(rfpara(:,7))==0
   bfpara(:,7)  = bfpara(:,7) + 10;
   rfpara       = sim_fpara2sort(bfpara,xytype);
end
