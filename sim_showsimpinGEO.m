function sim_showsimpinGEO(simp,newfig,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Developed by FWP, @SYSU, long long ago
 % 
 if nargin < 1
    disp('sim_showsimpinGEO(simp,newfig,varargin)');
    return
 end
 %
 if nargin < 2
    newfig = 1;
 end
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
 [fpara,zone] = sim_openfault(simp);
 [X,Y,Z,cx,cy,cz,aslip] = sim_plot3d(fpara);
 [n,m]                  = size(X);
 for ni = 1:n
     for nj = 1:m
         [Y(ni,nj),X(ni,nj)] = utm2deg(X(ni,nj)*1000,Y(ni,nj)*1000,zone);
     end
 end
 xmin = min(X(:));
 xmax = max(X(:));
 ymin = min(Y(:));
 ymax = max(Y(:));
 if newfig == 1
    sim_topfig('lonscale',[xmin-offset,xmax+offset],...
            'latscale',[ymin-offset,ymax+offset],...
            'demfile',demfile,...
            'dempath',dempath,...
            'faultpath',faultpath,...
            'faultname',faultname);
 else
     hold on
     dX = [X;X(1)];
     dY = [Y;Y(1)];
     plot(dX,dY,'-r','Linewidth',4.5);
     hold on
     % top edge
     %
     plot(X(2:3,:),Y(2:3,:),'-b','LineWidth',5);
 end
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
 
        
