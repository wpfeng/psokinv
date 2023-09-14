function [tfpara abc stdv1 stdv2] = sim_obj_oksar_SLIPRAKE(x)
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
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 global input fpara index symbols locals alpha am
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
 rake   = -90;
 green  = sim_oksargreenRAKE(tfpara,input,0,alpha,rake);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [n,m]   = size(green);
 [dn,dm] = size(am);
 A       = zeros(n,m+dm);
 A(1:n,1:m)       = green;
 A(1:dn,m+1:m+dm) = am;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 xslip        = lsqlin(A,input(:,3),[],[],[],[]);
 nf           = size(tfpara,1);
 tfpara(:,8)  = xslip(1:nf).*cosd(rake);
 tfpara(:,9)  = xslip(1:nf).*sind(rake);
 abc          = xslip(nf+1:end);
 osim         = A*xslip;
 stdv1        = sqrt(sum((input(:,3)-osim).^2)/numel(input(:,1)));
 osim         = green*xslip(1:m);
 stdv2        = sqrt(sum((input(:,3)-osim).^2)/numel(input(:,1)));
