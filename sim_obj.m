function vobj = sim_obj(x)
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
        am wVCM rake_isinv rake_value inv_VCM wmatrix rakeinfo
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
 tfpara                 = f;
 [~,sgreen,dgreen]  = sim_oksargreenALP(tfpara,input,0,alpha);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fixind = find(rake_isinv==0);
 noind  = find(rake_isinv==1);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %whos fixind
 green  = [];
 if numel(fixind)~=0
    for nrake = 1:numel(fixind)
        green = [green cosd(rake_value(fixind(nrake))).*sgreen(:,fixind(nrake))+...
                       sind(rake_value(fixind(nrake))).*dgreen(:,fixind(nrake))];
    end
 end
 %whos green
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if numel(noind)~=0
    green = [green sgreen(:,noind) dgreen(:,noind)];
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [n,m]   = size(green);
 [dn,dm] = size(am);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if dn*dm~=0
   A                = zeros(n,m+dm);
   A(1:n,1:m)       = green;
   A(1:dn,m+1:m+dm) = am;
 else
   A                = green;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 D       = input(:,3);
 counter = isnan(A);
 cunter2 = isinf(A);
 if sum(counter(:)) > 0 || sum(cunter2(:))>0
    vobj = 10^200;
    return
 end
 %   
 grank   = rank(A);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if grank >= m
     ndim    = size(A,2);
     lb      = zeros(ndim,1)-2;
     ub      = zeros(ndim,1)+2;
     options = optimset('display','off');
     AA      = wVCM*A;
     DD      = wVCM*D;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % add a new constraint, minimum moment scale
     noslip     = rake_isinv == 0;
     numslip    = sum(noslip==0)*2+sum(noslip==1);
     if lamda2 ~=0
         MINSCALE  = AA(1,:).*0+lamda2;
         %xslip                 = lsqlin([AA;MINSCALE],[DD;0],[],[],[],[],lb,ub,[],options);
         xslip  = cgls_bvls([AA;MINSCALE],[DD;0],lb,ub);
     else
         %xslip   = lsqlin(AA,DD,[],[],[],[],lb,ub,[],options);
         xslip  = cgls_bvls(AA,DD,lb,ub);
     end
     %Add rake constraints
     type       = 1;
     % return the slip value, including slips along strike and dip
     cslip      = xslip(1:numslip);
     if sum(noslip==0) > 0
         cslip    = cslip(sum(noslip==1)+1:end);
         dslip    = cslip(end/2+1:end);
         sslip    = cslip(1:end/2);
         norake   = atan2(dslip,sslip).*180./3.14159265;
         %disp(norake)
         itype    = (norake-rakeinfo(noslip==0,2)).*(norake-rakeinfo(noslip==0,3));
         isittype = itype > 0;
         if sum(isittype(rakeinfo(:,4)~=0)) > 0
             % changed by Feng W.P, it's better that the rake is closer to
             % the boundary when the rake is out of the range.
             type = sum(isittype(rakeinfo(:,4)~=0).*itype(rakeinfo(:,4)~=0)) ...
                    + 10^10;
         end
     end
     %
     vobj    = (norm((wVCM*(D-A*xslip)).*wmatrix)+type);%.^(1-dcor);%
     %
 else
    vobj    = 10^200;
    
 end    


