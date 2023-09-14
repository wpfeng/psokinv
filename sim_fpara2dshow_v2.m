function [outx,outy,outs] = sim_fpara2dshow_v2(fpara,slipmode,refx,isquiver,isgrid)
%
% by FWP,@GU, 2014-07-28
%
meanstrike = mean(fpara(:,3));
%
if nargin < 2 || isempty(slipmode)
    slipmode = 'SYN';
end
%
bflg = 1;
if nargin < 3 
   bflg = 0;
   refx = 0;
end
if nargin < 4
    isquiver = 0;
end
if nargin < 5
    isgrid = 1;
end
%
%
%

load mycolor.mat
%mycolor = colormap('hot');
ncl = mycolor;
%
%x  = sim_rotaxs(x0,y0,meanstrike,90);
% fpara(:,1) = fpara(:,1) - refx;
%
polyz = [];
polyx = [];
c     = [];
%
if isempty(refx)
    for ni = 1:numel(fpara(:,1))
        [cx,cy,cz1] = sim_fpara2corners(fpara(ni,:),'ul');
        x1          = sim_rotaxs(cx,cy,meanstrike,90);
        [cx,cy,cz2] = sim_fpara2corners(fpara(ni,:),'lr');
        x2          = sim_rotaxs(cx,cy,meanstrike,90);
        polyx       = [polyx,[x1,x2,x2,x1,x1]'];
    end
    refx = min(polyx(:));
    %whos polyx
    %whos refx
    refx = refx(1);
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get boundary
outx = [];
for ni = 1:numel(fpara(:,1))
    [cx,cy,cz1] = sim_fpara2corners(fpara(ni,:),'ul');
    x1          = sim_rotaxs(cx,cy,meanstrike,90);
    [cx,cy,cz2] = sim_fpara2corners(fpara(ni,:),'lr');
    x2          = sim_rotaxs(cx,cy,meanstrike,90);
    polyx       = [x1,x2,x2,x1,x1];
    polyz       = [cz1,cz1,cz2,cz2,cz1];
    outx = [outx;polyx(:)];
end
%
xshift = min(outx(:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outx = [];
outy = [];
outs = [];
%
for ni = 1:numel(fpara(:,1))
    [cx,cy,cz1] = sim_fpara2corners(fpara(ni,:),'ul');
    x1          = sim_rotaxs(cx,cy,meanstrike,90);
    [cx,cy,cz2] = sim_fpara2corners(fpara(ni,:),'lr');
    x2          = sim_rotaxs(cx,cy,meanstrike,90);
    polyx       = [x1,x2,x2,x1,x1];
    polyz       = [cz1,cz1,cz2,cz2,cz1];
    %
    switch upper(slipmode)
        case 'SYN'
            cc = sqrt(fpara(ni,8).^2+fpara(ni,9).^2);
            c = [c cc];
        case 'STRIKE'
            cc = fpara(ni,8);
            cc = [c cc];
        otherwise
            cc = fpara(ni,9);
            c = [c cc];
    end
    outx = [outx;polyx];
    outy = [outy;polyz];
    outs = [outs;cc];
    
end
%
fillid = patch(outx'-xshift,outy',outs');%polyx-xshift,polyz,cc);
%get(fillid)
if isgrid==0
    set(fillid,'LineStyle','none');
else
    set(fillid,'LineWidth',0.01,'EdgeColor',[0.8,0.8,0.8]);
end
%
hold on
qx = mean(outx'-xshift);
qy = mean(outy');
%
if isquiver == 1
    quiver(qx(:),qy(:),fpara(:,8),fpara(:,9).*-1,...
        'Linewidth',1.5,'Color','k');
end
%
%set(fillid,'LineStyle','none')
%hold on
set(gca,'YDir','reverse');
set(gca,'FontWeight','bold');
set(gca,'FontSize',12);
%set(gca,'XLim',[0,61]);
ylabel('Depth(km)');
% xlabel('Length(km)');
%
colormap(ncl);
