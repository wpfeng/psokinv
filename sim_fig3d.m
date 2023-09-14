function hid = sim_fig3d(fpara,quivertype,ncl,varargin)
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
%     written by Wanpeng Feng (wanpeng.feng@hotmail.com), at 2008-07-05
%     added the some documents by FWP, at 2008-07-19
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
%
if nargin<3 || isempty(ncl)==1
    outcpt = gmt_cptdb('slipm','matlab');
    ncl = flipud(outcpt);
end

lwid       = 0.5;
acl        ='k';
polygon    = [];
iscolorbar = 1;
qlen       = 0.5;
edgecolor  = [0,0,0];
edgewidth  = 0.5;
istrace    = 0;
linestyle  = '-';
sliptype   = 'syn';
%
for ni = 1:2:numel(varargin)
    %
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(fpara,1)==3
    tfpara = fpara(2:3,:);
    fpara  = fpara(1,:);
else
    tfpara = [];
end
%
[X,Y,Z,Cx,Cy,Cz,Aslip] = sim_plot3d(fpara);
%
switch sliptype
    case 'syn'
        slip = sqrt(Aslip(:,1).^2+Aslip(:,2).^2);
    case 'strike'
        slip = Aslip(:,1);
    case 'dip'
        slip = Aslip(:,2);
    case 'open'
        slip = Aslip(:,3);
    case 'nan'
        slip = nan;
end
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
    hid(nid) = plot3(X(:)+0.1,Y(:),Z(:),'Color','w','LineWidth',0.1,'LineStyle',pedge);
end
%get(hid(nid))
%
if iscolorbar ~= 0
    nid      = nid+1;
    hid(nid) = colorbar;
    title(hid(nid),'(m)');
end
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
        [polygon(4,3),polygon(1,3)],'Color','w','LineWidth',0.1,'LineStyle',pedge);
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
    %
    flag1 = abs(tx)>0.01;
    flag2 = abs(ty)>0.01;
    flag = flag1 + flag2;
    %
    %flag = Aslip > 0.01;
    tCx = Cx(flag>0);
    tCy = Cy(flag>0);
    tCz = Cz(flag>0);
    tdxv = dxv(flag>0);
    tdyv = dyv(flag>0);
    tdzv = dzv(flag>0);
    % tqlen= qlen(flag>0);
    %
    hid(nid) =quiver3(tCx(:),tCy(:),tCz(:),tdxv(:),tdyv(:),tdzv(:),qlen(:),...
        'filled','Linewidth',lwid,'Color',acl,'MarkerSize',9);
    %    hid(nid) =quiver3d(Cx(:),Cy(:),Cz(:),dxv(:),dyv(:),dzv(:),[0,0,0],0.08,100);
    %
end
grid on
%
set(gca,'FontWeight','bold');
set(gca,'FontSize',12);
%
%
if isempty(tfpara)~=1
    sim_fig3d(tfpara);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if istrace == 1
    %
    for ni = 1:size(fpara,1)
        %
        tfpara = sim_fpara2whole(fpara(ni,:),0);
        [x1,y1] = sim_fpara2corners(tfpara,'ul');
        [x2,y2] = sim_fpara2corners(tfpara,'ur');
        plot([x1,x2],[y1,y2],'-r','LineWidth',2.5);
    end
end
% painters may speed up the processess...
%
set(gcf,'renderer','painters');
% zticks = get(gca,'ZTick');
% zlabels= cell(numel(zticks),1);
% for ni = 1:numel(zticks)
%     zlabels{ni} = num2str(abs(zticks(ni)));
% end
% set(gca,'ZTickLabel',zlabels);
% %
% end