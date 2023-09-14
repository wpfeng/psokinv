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
 [green,sgreen,dgreen]  = sim_oksargreenALP(tfpara,input,0,alpha);
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
    vobj = 10^10;
    return
 end
 %   
 grank   = rank(A);
 %disp(grank)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if grank >= m
     xslip   = lsqlin(wVCM*A,wVCM*D,[],[],[],[]);
     %Add rake constraints
     type    = 1;
     counters = 0;
     for nkk=1:size(rakeinfo,1)
         if rakeinfo(nkk,4)==0
             counters = counters+1;
         else
             norake     = atan2(xslip(counters+2),xslip(counters+1))*180/pi;
             itype       = (norake-rakeinfo(nkk,2))*(norake-rakeinfo(nkk,3));
             if itype > 0
                type = type+10^10;
             end
             counters   = counters+2;
         end
         
     end
    
    vobj    = norm((wVCM*(D-A*xslip)).*wmatrix)*type;%
    %disp(std2(D-A*xslip))
 else
    vobj    = 10^10;
 end    


