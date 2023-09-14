function vobj = sim_obj_conrake(x)
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
 %        global variables
 %           input, the insar or other geodesy observation data (m*6)
 %                  x(km) y(km) insar(cm) k-e k-n k-v 
 %           fpara, the m*10 matrix, m is the fault number.
 %           Inv  , the m*10 matrix, which the variable will need to invert
 %                  will be set 1. Others are set to 0.
 % Output:
 %        vobj, object function value
 % Writed by Feng W.P(skyflow2008@126.com), 10/04/2009
 % Modified by Feng W.P,03/06/2009(skyflow2008@126.com), in University of Glasgow
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 global input fpara index symbols locals alpha ...
        am wVCM rake_isinv rake_value inv_VCM wmatrix rakeinfo rakecons mrakecons
 % try to use minimum moment scale constraint to the nonlinear inversion...
 %
 lamda2 = 0;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %
 f            = fpara;
 f(index(:))  = x;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 for ni = 1:numel(index)
     sym = symbols{index(ni)};
     f(index(ni)) = eval(sym{1});
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 nmodel = size(f,1);
 for ni = 1:nmodel
       f(ni,:) = sim_fparaconv(f(ni,:),locals(ni,1),0);
 end
 tfpara  = f;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % modified by Feng, W.P, add rake constraints
 % 2011-01-03
 green    = [];
 rakecons = [];        %zeros(size(f,1),3);
 for ni = 1:size(f,1)
    if rakeinfo(ni,4) == 1
       rakecons  = [1,rakeinfo(ni,2),rakeinfo(ni,3)];
       cgreen    = sim_oksargreenALP(tfpara(ni,:),input,0,alpha);
    else
       rakecons  = [1,rakeinfo(ni,1),rakeinfo(ni,1)];
       cgreen    = sim_oksargreenALP(tfpara(ni,:),input,0,alpha);
    end
    if rakecons(2)==rakecons(3)
       green = [green cgreen(:,1)];
    else
       green = [green cgreen];
    end
    mrakecons = [];
 end
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [n,m]   = size(green);
 [dn,dm] = size(am);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %save test.mat am
 if isempty(am)==0
   A                = zeros(n,m+dm);
   A(1:n,1:m)       = green;
   A(1:dn,m+1:m+dm) = am;
 else
   A                = green;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 D       = input(:,3);
 stds    = input(:,7);
 counter = isnan(A);
 cunter2 = isinf(A);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Fixed nan problem, by Feng W.P, 2011-01-3
 if sum(counter(:)) > 0 || sum(cunter2(:))>0
    input(:,1) = input(:,1)+0.0001;
    vobj       = sim_obj_conrake(x);
    return
 end
 %   
 grank   = rank(A);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if grank >= m
     ndim    = size(A,2);
     lb      = zeros(ndim,1);%-20;
     ub      = zeros(ndim,1)+100^10;
     % if abc is the parameters to estimate, the solution will not be right
     % found by Feng,W.P., 2011-08-23, @ BJ
     % fixed it yet
     if isempty(am)==0
        clb = zeros(dm,1)+max(abs(input(:,3)))*-1;
        cub = zeros(dm,1)+max(abs(input(:,3)));
        %
        lb(end-dm+1:end) = clb;
        ub(end-dm+1:end) = cub;
     end
     %options = optimset('display','off');
     AA      = A;
     DD      = D;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % add a new constraint, minimum moment scale
     if lamda2 ~=0
         MINSCALE  = AA(1,:).*0+lamda2;
         % change LS method to cgls_bvls, Feng, W.P, 2011-01-03
         % xslip     = lsqlin([AA;MINSCALE],[DD;0],[],[],[],[],lb,ub,[],options);
         xslip  = cgls_bvls([AA;MINSCALE],[DD;0],lb,ub,[],[],stds);
     else
         % change LS method to cgls_bvls, Feng, W.P, 2011-01-03,change back
         % xslip   = lsqlin(AA,DD,[],[],[],[],lb,ub,[],options);
         xslip  = cgls_bvls(AA,DD,lb,ub,[],[],stds);
     end
     % Modification, now the rake angle can not flee out of the given
     % values. Feng W.P, 2011-01-03
     %
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % add following 6 lines for magnititude constraints
     %
     if sum(isinf(xslip)) > 0
        xslip(isinf(xslip)) = 100;
     end
     strslip = xslip(1)*cosd(rakecons(1)) + xslip(2)*cosd(rakecons(2));
     dipslip = xslip(1)*sind(rakecons(1)) + xslip(2)*sind(rakecons(2));
     tfpara(:,8) = strslip;
     tfpara(:,9) = dipslip;
     [~,~,mw]    = sim_fpara2moment(tfpara);
     cof         = exp(abs(mw-5.1)*100);
     %
     %vobj    = norm((wVCM*(D-A*xslip));
     vobj    = norm((wVCM*(D-A*xslip)).*wmatrix).*cof;%.^(1-dcor);%
    
     if isinf(vobj)
        vobj = 10^200;
     end
 else
    vobj    = 10^200;
 end    
 % vobj

