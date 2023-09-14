function sim_trif2d(trif,azi,type)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 if nargin < 3
     type = 'syn';
 end
 ntrif = size(trif,2);
 x     = [];
 y     = [];
 z     = [];
 slip  = [];
 for ni=1:ntrif
     x = [x ;trif(ni).x];
     y = [y ;trif(ni).y];
     z = [z ;trif(ni).z];
     slip = [slip;trif(ni).ss trif(ni).ds sqrt(trif(ni).ss^2+trif(ni).ds^2)];
 end
 [m,n]   = size(x);
 [rx,ry] = eqs_rotaxs(x(:),y(:),azi);
 rx      = reshape(rx,[m,n]);
 ry      = reshape(ry,[m,n]);
 rx      = rx-min(rx(:));
 %%%%%%%%%%%%%%%%%%%%%%%
 switch lower(type)
     case 'syn'
        cslip = slip(:,3)';
     case 'dip'
        cslip = slip(:,2)';
     case 'strike'
        cslip = slip(:,1)';
 end
 patch(rx',z',cslip);
 %
 xlim = get(gca,'XLim');
 ylim = get(gca,'YLim');
 axis equal;
 set(gca,'XLim',xlim);
 set(gca,'YLim',ylim);
 xlabel('Along Strike (km)');
 ylabel('ALong Depth (km)');
 load mycolor.mat
 if mean(cslip(:)) < 0
     mycolor = flipud(mycolor);
 end
 colormap(mycolor);
 colorbar;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
