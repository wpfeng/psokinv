function sim_trifshow(trif,channel)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Usage: sim_trifshow(trif,[channel]);
 %
 % Created by Feng,Wanpeng, IGP/CEA,2009
 % 
 if nargin <1
    disp('sim_trifshow(trif,channel)')
    disp(' Usage: ');
    disp('     trif, keywords, the structure for triangular model');
    disp('  channel, optional, the flag switcher of "strike","dip" and "syn" for display component');
    disp(' Author: Feng, W.P, fengwp@cea-igp.ac.cn');
    return
 end
 if nargin < 2
     channel = 'syn';
 end
 ntri = numel(trif);
 triX = zeros(3,ntri);
 triY = zeros(3,ntri);
 triZ = zeros(3,ntri);
 ss   = zeros(ntri,1);
 ds   = ss;
 ts   = ss;
 cs   = ss;
 ns   = ss;
 for ni = 1:ntri
     triX(:,ni) = trif(ni).x(:);
     triY(:,ni) = trif(ni).y(:);
     triZ(:,ni) = trif(ni).z(:);
     ss(ni)     = trif(ni).ss;
     ds(ni)     = trif(ni).ds;
     ts(ni)     = trif(ni).ts;
     cs(ni)     = sqrt(ss(ni)^2+ds(ni)^2);
     %
     % updated by Feng, W.P., @ YJ, 2015-07-12
     if isfield(trif,'numneig');
     ns(ni)     = trif(ni).numneig;
     else
         ns(ni) = ni;
     end
     %
 end
 switch channel
     case 'strike'
         slip = ss;
     case 'dip'
         slip = ds;
     case 'tensil'
         slip = ts;
     case 'syn'
         slip = cs;
     case 'neighbor'
         slip = ns;
 end
 %
 patch(triX,triY,triZ,slip');
 grid on
 axis equal
 %set(gca,'ZLim',[min(triZ(:)),max(triZ(:))]);
