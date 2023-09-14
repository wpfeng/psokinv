function [rfpara,hid,chid] = sim_fixmodelview2D(fpara,azi,vector,scale,mycolor)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
if nargin < 2 || isempty(azi)
    azi = mean(fpara(:,3));
end
if nargin < 3 || isempty(vector)
    vector = 0.1:0.2:20;
end
if nargin < 4 || isempty(scale);
    scale = 10;
end
%
rfpara  = fpara;
rx      = eqs_rotaxs(fpara(:,1),fpara(:,2),azi);

rx      = rx-min(rx);

ry      = fpara(:,5).*-1;
ry      = ry - max(ry);
slip    = sqrt(fpara(:,8).^2+fpara(:,9).^2);
if nargin < 5
   load mycolor.mat
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xstep = sim_mindist(rx,ry,0.0001);
ystep = xstep;
%
[X,Y]   = meshgrid(min(rx):xstep:max(rx),min(ry):ystep:max(ry));
Z       = griddata(rx,ry,slip,X,Y);
X       = resizem(X,scale);
X       = X - min(X(:));
Y       = resizem(Y,scale);
Y       = Y - max(Y(:));
Z       = resizem(Z,scale);
%whos X
%whos Y
%whos Z
%
%figid = findobj('tag','fixmodelview2d');
%if isempty(figid)
%figure('Color',[1,1,1]);

%
%clf(figid);
%
%hold on
%axis equal
set(gca,'XLim',[min(X(:)),max(X(:))]);
set(gca,'YLim',[min(Y(:)),max(Y(:))+1]);
%
chid = colorbar();
colormap(mycolor);
%
[C,h] = contour(X,Y,Z,vector,'LineWidth',1.2,'Color','b');
set(h,'Fill','on')
text_handle = clabel(C,h);
set(text_handle,'FontName','Arial','FontSize',10,'BackgroundColor',[1 1 .9]) 
%
hold on
plot(rx,ry,'.k','MarkerSize',0.5);
hid = quiver(rx,ry,fpara(:,8),fpara(:,9),0.5,'Color','k');
%get(hid)
box on
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
