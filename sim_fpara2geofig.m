function sim_fpara2geofig(fpara,geopoints,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Developed by FWP, @ GU, long long ago
 % 
 if nargin < 2
    disp('sim_fpara2geofig(fpara,geopoints,varargin)');
    return
 end
 %
 demfile   = 'etop1.img';
 dempath   = 'E:\work\data\imag\global_topo_1min';
 offset    =  0.5;
 faultname = '';
 faultpath = '';
 edgecolor = 'none';
 facealpha = 1.0;
 %%%%%%%%%
 v = sim_varmag(varargin);
 for j = 1:length(v)
    eval(v{j});
 end
 %%%%%%%%%
 [X,Y,Z,cx,cy,cz,aslip] = sim_plot3d(fpara);
 [x0,y0,zone]           = deg2utm(geopoints(2),geopoints(1));
 [n,m]                  = size(X);
 for ni = 1:n
     for nj = 1:m
         [Y(ni,nj) X(ni,nj)] = utm2deg(X(ni,nj)*1000,Y(ni,nj)*1000,zone);
     end
 end
 xmin = min(X(:));
 xmax = max(X(:));
 ymin = min(Y(:));
 ymax = max(Y(:));
 sim_topfig('lonscale',[xmin-offset,xmax+offset],...
            'latscale',[ymin-offset,ymax+offset],...
            'demfile',demfile,...
            'dempath',dempath,...
            'faultpath',faultpath,...
            'faultname',faultname);
 %
 for ni = 1:n
     [X(ni,:),Y(ni,:)] = m_ll2xy(X(ni,:),Y(ni,:));
 end
 %
 slip = sqrt(aslip(:,1).^2+aslip(:,2).^2);
 hold on
 pid  = patch(X,Y,slip');
 %
 set(pid,'Edgecolor',edgecolor);
 set(pid,'FaceAlpha',facealpha);
 
        
