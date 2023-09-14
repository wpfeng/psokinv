function [tfpara abc stdv1 stdv2] = sim_obj_psoksar_SLIPALP(x)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Purpose:
%        the function to estimate objective values of the object functions
% Input:
%        x, n*1
%        global paramters
%           input, the insar or other geodesy observation data (m*6)
%                  x(km) y(km) insar(cm) k-e k-n k-v
%           fpara, the m*10 matrix, m is the fault number.
%           Inv  , the m*10 matrix, which the variable will need to invert
%                  will be set 1. Others are set to 0.
% Output:
%        tfpara, the best uniform models
% Writed by Feng W.P, 10/04/2009
% Modified by Feng W.P,2009-09-24
% Updated by FWP, @ BJ, 2011/03/03
%   ->Support a given rake inversion
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global input fpara index symbols locals alpha am wVCM rake_isinv rake_value inv_VCM ...
    rakeinfo rakecons mrakecons 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
f           = fpara;
f(index(:)) = x;
for ni = 1:numel(index)
    sym          = symbols{index(ni)};
    f(index(ni)) = eval(sym{1});
end
%
nmodel = size(f,1);
for ni = 1:nmodel
    f(ni,:) = sim_fparaconv(f(ni,:),locals(ni,1),0);
end
tfpara = f;
% modified by Feng, W.P, add rake constraints
% 2011-01-03
green    = [];
%
rakecons = zeros(size(f,1),2);
for ni = 1:size(f,1)
    %
    % updated by Wanpeng Feng, @CCRS/NRCan, 2017-09-20
    %
    if rakeinfo(ni,4) == 0
        rakecons(ni,:) = [rakeinfo(ni,1),rakeinfo(ni,1)];
    else
        rakecons(ni,:) = [rakeinfo(ni,2),rakeinfo(ni,3)];
    end
    %
end
%
% updated by FWP, @ GU, 20130321
counter = sum((rakecons(:,1) == rakecons(:,2)) + 1);
%
[t_mp,r1green,r2green]  = sim_oksargreenALP(tfpara,input,0,alpha,rakecons);
green                = [r1green r2green(:,rakecons(:,1)~=rakecons(:,2))];
%rakecons             = crakecons;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[n,m]    = size(green);
[dn,dm]  = size(am);
if dn*dm ~= 0
    A                = zeros(n,m+dm);
    A(1:n,1:m)       = green;
    A(1:dn,m+1:m+dm) = am;
else
    A = green;
end
%
D       = input(:,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ndim    = size(A,2);
%  lb      = zeros(ndim,1);
%  ub      = zeros(ndim,1)+1000;
% updated by FWP, @ GU, 20130321
lbm     = zeros(m,1);%-20;
ubm     = zeros(m,1) + 5000;%

% Boundaries for ABC
% by fWP, @GU, 2014-02-01
lbn      = zeros(dm,1) - 5000;
ubn      = zeros(dm,1) + 5000;
lb      = [lbm;lbn];
ub      = [ubm;ubn];
AA      = inv_VCM*A;
DD      = inv_VCM*D;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if rake_isinv(1,1)>1
    xslip = AA\DD;
else
    xslip = cgls_bvls(AA,DD,lb,ub);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%counter      = 0;
tfpara(:,8)  = 0;
tfpara(:,9)  = 0;
tfpara(:,10) = 0;
%
cslip       = xslip(1:size(tfpara,1));
tfpara(:,8) = cslip(:).*cosd(rakecons(:,1)); %  + cslip(2)*cosd(crakecons(ni,3));
tfpara(:,9) = cslip(:).*sind(rakecons(:,1)); %  + cslip(2)*sind(crakecons(ni,3));
%
valindex = rakecons(:,1) ~= rakecons(:,2);
validind = find(valindex ~= 0);
%
for ni = 1:numel(validind)
    cslip                  = xslip(size(tfpara,1)+ni);
    tfpara(validind(ni),8) =  tfpara(validind(ni),8)  + cslip *  cosd(rakecons(validind(ni),2));
    tfpara(validind(ni),9) =  tfpara(validind(ni),9)  + cslip*sind(rakecons(validind(ni),2));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(xslip(:),1)== counter
    abc = [];
else
    abc = xslip(counter+1:end);
end
%
% Remove the orbit error and offset, abc will be used in the RES.
osim        = A*xslip;
stdv1       = sqrt(sum((input(:,3)-osim).^2)/numel(input(:,1)));
% Do't care the abc.
dis         = multiokadaALP(tfpara,input(:,1),input(:,2));
osim        = dis.E.*input(:,4) + dis.N.*input(:,5)+dis.V.*input(:,6);
stdv2       = sqrt(sum((input(:,3)-osim).^2)/numel(input(:,1)));
