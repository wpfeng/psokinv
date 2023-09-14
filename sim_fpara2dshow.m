function hid = sim_fpara2dshow(fpara,quivertype,ncl,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:
%     hid = sim_fig3d(fpara,ncl,lwid,acl,polygon,quivertype,qlen)
% Input:
%       fpara, fault model
%         ncl, colormap for slip value
%        lwin, the width of arrow
%         acl, the color of arrow
%     polygon, the polygon will be covered on the fault plane
%  quivertype, switch flag,(1) plot;(0) don't plot
%        qlen, the length of quiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ncl is colormap                         , default value is 'jet'
% lwid is the width of the quiver-arrow   , default value is 0.5
% acl  is the color of the quiver-arrow   , default value is 'r'
% polygon is another region on the planet , default is NONE.
% quivertype, 1 is true, to plot; 0 is no , don't plot.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Revised history:
%     wrote by Feng W.P, at 2008-07-05
%     added the some documents by Feng W.P, at 2008-07-19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure('tag','Fault_3d_QuickView','Color',[1,1,1]);
nid = 0;
if nargin<1
    disp('hid = sim_fig3d(fpara,quivertype,ncl,lwid,acl,polygon,qlen)');
    return
end
%
if nargin < 2 || isempty(quivertype)==1
    quivertype = 0;
end
if nargin<3 || isempty(ncl)==1
    load mycolor.mat
    %mycolor = colormap('hot');
    ncl = mycolor;
end

lwid      = 0.5;
acl       = 'k';
polygon   = [];
qlen      = 0.5;
edgecolor = [0,0,0];
edgewidth = 0.5;
istrace   = 0;
linestyle = '-';
sliptype  = 'syn';
%
v = sim_varmag(varargin);
for j = 1:length(v)
    eval(v{j});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(fpara,1)==3
    tfpara = fpara(2:3,:);
    fpara  = fpara(1,:);
else
    tfpara = [];
end
%
%[X,Y,Z,Cx,Cy,Cz,Aslip] = sim_plot3d(fpara);
udepth = unique(fpara(:,5));
Cx = [];
Cy = [];
X  = [];
Y  = [];
Aslip = [];
for ni = 1:numel(udepth)
    %
    cde       = udepth(ni);
    cfpara    = fpara(fpara(:,5)==cde,:);
    cx        = cfpara(:,1)-min(cfpara(:,1));
    [~,index] = sort(cx);
    %X = index.*cfpara(index,7);
    ml = mean(cfpara(:,7));
    md = mean(cfpara(:,7)).*sind(mean(cfpara(:,4)));
    %
    for nj = 1:numel(index)
        Xnj = [0,ml,ml,0,0]+(index(nj)-1)*ml;
        Ynj = [0,0,-1*md,-1*md,0]-cfpara(1,5);
        X   = [X;Xnj];
        Y   = [Y;Ynj];
        Cx  = [Cx;mean(Xnj)];
        Cy  = [Cy;mean(Ynj)];
        Aslip = [Aslip;cfpara(index(nj),8),cfpara(index(nj),9)];
    end
end


%
switch sliptype
    case 'syn'
        slip = sqrt(Aslip(:,1).^2+Aslip(:,2).^2);
    case 'strike'
        slip = Aslip(:,1);
    case 'dip'
        slip = Aslip(:,2);
    case 'nan'
        slip = nan;
end
%
cslip = X;
for ni = 1:numel(slip)
    cslip(ni,:) = slip(ni);
end
%
hid = patch(X',Y',slip');
set(hid,'EdgeColor',edgecolor);
set(hid,'LineWidth',edgewidth);
set(hid,'LineStyle',linestyle);
hold on
xmin = min(X(:));
xmax = max(X(:));
ymin = min(Y(:));
ymax = max(Y(:));
set(gca,'XLim',[xmin,xmax]);
set(gca,'YLim',[ymin,ymax]);
colormap(ncl);
%
%
%
if quivertype == 1
    hold on
    
    dxv   = Aslip(:,1);
    dyv   = Aslip(:,2);
    quiver(Cx(:),Cy(:),dxv(:),dyv(:),qlen(:),...
        'filled','Linewidth',lwid,'Color',acl,'MarkerSize',9);
end
%
set(gca,'FontWeight','bold');
set(gca,'FontSize',11);
%
idx = xlabel('Length along the fault (km)');
set(idx,'FontWeight','bold');
set(idx,'FontSize',12);
idy = ylabel('Depth in km');
set(idy,'FontWeight','bold');
set(idy,'FontSize',12);
%
return
%
nid  = nid+1;
%
if ~isnan(slip)
    %
    slip(slip == 0) = 0.00001;
    hid(nid) = patch(X,Y,Z,slip');
    
    set(hid(nid),'EdgeColor',edgecolor);
    set(hid(nid),'LineWidth',edgewidth);
    set(hid(nid),'LineStyle',linestyle);
    
    colormap(ncl);
else
    hid(nid) = plot3(X(:)+0.1,Y(:),Z(:),'Color','w','LineWidth',2.0);
end
%get(hid(nid))
%
nid      = nid+1;
hid(nid) = colorbar;
hold on
if isempty(polygon)~=1
    nid  = nid+1;
    hid(nid) = plot3(polygon(1:2,1),polygon(1:2,2),polygon(1:2,3),'Color','w','LineWidth',2.0);
    nid      = nid+1;
    hid(nid) = plot3(polygon(2:3,1),polygon(2:3,2),polygon(2:3,3),'Color','w','LineWidth',2.0);
    nid      = nid+1;
    hid(nid) = plot3(polygon(3:4,1),polygon(3:4,2),polygon(3:4,3),'Color','w','LineWidth',2.0);
    nid      = nid+1;
    hid(nid) = plot3([polygon(4,1),polygon(1,1)],...
        [polygon(4,2),polygon(1,2)],...
        [polygon(4,3),polygon(1,3)],'Color','w','LineWidth',2.0);
end
%
if quivertype == 1
    dzv = Aslip(:,2).*sind(fpara(:,4))+0.1;
    ty = Aslip(:,2).*cosd(fpara(:,4));%.*cosd(fpara(:,3)-180)-Aslip(:,1).*sind(180-fpara(:,3));
    tx = Aslip(:,1);%-1.*Aslip(:,2).*cosd(fpara(:,4)).*sind(fpara(:,3)-180)-Aslip(:,1).*cosd(180-fpara(:,3));
    pi = 3.14159265;
    strkr = (90-fpara(:,3))*pi/180;
    %
    i     = sqrt(-1);
    stemp = (tx+ty.*i).*exp(i.*strkr(:));
    dxv   = real(stemp);
    dyv   = imag(stemp);
    nid  = nid+1;
    hid(nid) =quiver(Cx(:),Cy(:),Cz(:),dxv(:),dyv(:),dzv(:),qlen(:),...
        'filled','Linewidth',lwid,'Color',acl,'MarkerSize',9);
    %    hid(nid) =quiver3d(Cx(:),Cy(:),Cz(:),dxv(:),dyv(:),dzv(:),[0,0,0],0.08,100);
    %
end
grid on
%
set(gca,'FontWeight','bold');
set(gca,'FontSize',14);
%
%
if isempty(tfpara)~=1
    sim_fig3d(tfpara);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if istrace == 1
    for ni = 1:size(fpara,1)
        tfpara = sim_fpara2whole(fpara(ni,:),0);
        [x1,y1] = sim_fpara2corners(tfpara,'ul');
        [x2,y2] = sim_fpara2corners(tfpara,'ur');
        plot([x1,x2],[y1,y2],'-r','LineWidth',2.5);
    end
end
