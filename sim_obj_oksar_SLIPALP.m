function [tfpara abc stdv1 stdv2] = sim_obj_oksar_SLIPALP(x)
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
 % Support fixed rake inversion!
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 global input fpara index symbols locals alpha am wVCM rake_isinv rake_value inv_VCM
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
 %disp([fpara(:,1)';tfpara(:,1)']);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [green,sgreen,dgreen]  = sim_oksargreenALP(tfpara,input,0,alpha);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fixind = find(rake_isinv==0);
 noind  = find(rake_isinv==1);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 green  = [];
 if numel(fixind)~=0
    for nrake = 1:numel(fixind)
        green = [green cosd(rake_value(fixind(nrake))).*sgreen(:,fixind(nrake))+...
                       sind(rake_value(fixind(nrake))).*dgreen(:,fixind(nrake))];
    end
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if numel(noind)~=0
    green = [green sgreen(:,noind) dgreen(:,noind)];
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [n,m]   = size(green);
 [dn,dm] = size(am);
 if dn*dm~=0
   A          = zeros(n,m+dm);
   A(1:n,1:m) = green;
   A(1:dn,m+1:m+dm) = am;
 else
   A          = green;
 end
 %
 D       = input(:,3);
 % 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 xslip   = (A'*inv_VCM*A)\A'*inv_VCM*D;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 nf      = numel(rake_value);
 yesind  = 0;
 if numel(fixind)~=0
    for yesind = 1:numel(fixind)
        islip = xslip(yesind);
        tfpara(fixind(yesind),8) = islip*cosd(rake_value(fixind(yesind)));
        tfpara(fixind(yesind),9) = islip*sind(rake_value(fixind(yesind)));
    end
 end
 endslip = numel(fixind)+numel(noind)*2;
 fslip   = xslip((yesind+1):endslip);
 if numel(noind)~=0
   s_slip = fslip(1:end/2);
   d_slip = fslip(end/2+1:end);
   tfpara(noind,8) = s_slip;
   tfpara(noind,9) = d_slip;
 end
 %tfpara(:,8)  = xslip(1:nf);
 %tfpara(:,9)  = xslip((nf+1):(nf*2));
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if size(xslip(:),1)==endslip
    abc = zeros(nf*3,1);
 else
    abc = xslip(endslip+1:end);
 end
 %
 osim         = A*xslip;
 stdv1        = sqrt(sum((input(:,3)-osim).^2)/numel(input(:,1)));
 osim         = green*xslip(1:m);
 stdv2        = sqrt(sum((input(:,3)-osim).^2)/numel(input(:,1)));
