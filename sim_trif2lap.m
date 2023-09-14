function [Lapm,lbs,lbd,ubs,ubd] = sim_trif2lap(trif,topdepth)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Created by Feng, Wanpeng, IGP/CEA, working for lalacian matrix
 % 2009-11-01
 % Modified by Feng,Wanpeng
 % Add a new keywords,fpara
 % 
 if nargin < 2
    topdepth = 0.5;
 end
 ntri  = numel(trif);
 Lapm  = zeros(ntri,ntri);
 lbs   = zeros(ntri,1);
 lbd   = lbs;
 ubs   = lbs;
 ubd   = lbd;
 for ni= 1:ntri
     numneig  = trif(ni).numneig;
     legs     = zeros(numneig,1);
     neighbor = trif(ni).neighbor;
     if trif(ni).numneig <=2
        lbs(ni) = -0.00000001;
        ubs(ni) =  0.00000001;
        lbd(ni) = -0.00000001;
        ubd(ni) =  0.00000001;
     else
        lbs(ni) = -1;
        ubs(ni) =  1;
        lbd(ni) = -1;
        ubd(ni) =  1;
     end
     for nk=1:numneig
         legs(nk) = sqrt((trif(ni).cx-trif(neighbor(nk)).cx).^2 + ...
                         (trif(ni).cy-trif(neighbor(nk)).cy).^2 + ...
                         (trif(ni).cz-trif(neighbor(nk)).cz).^2);
     end
     L     = sum(legs(:));
     meanl = mean(legs(:)); 
     %
     Lapm(ni,ni) = numneig*L/meanl;
     for nk=1:numneig
         Lapm(ni,neighbor(nk)) = -L/legs(nk);
     end
 end
 zdepth = zeros(ntri,1);
 for ni=1:ntri
     %[d,ind]= sort(abs(trif(ni).z(:)));
     zdepth(ni) = abs(trif(ni).cz); %d(ind(2));
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % set the top patch with nonzero slip value...
 %
 %
 lbs( zdepth<=topdepth ) = -1;
 lbd( zdepth<=topdepth ) = -1;
 ubs( zdepth<=topdepth ) =  1;
 ubd( zdepth<=topdepth ) =  1;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Find a bug for building up-boundary and low-boundary
 % working for strike!
 flag = lbs > ubs;
 tmpl = lbs(flag==1);
 lbs(flag==1) = ubs(flag==1);
 ubs(flag==1) = tmpl;
 % working for dip!
 flag = lbd > ubd;
 tmpl = lbd(flag==1);
 lbd(flag==1) = ubd(flag==1);
 ubd(flag==1) = tmpl;
 % 
