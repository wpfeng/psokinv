function sar_checkstdfrominpxy(xyf,inp,infile,cproj,czone,crange,ctmap)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% 
% Show the Quadtree Region
% Created by Feng, Wanpeng, IGP/CEA, 2009/06
% Improved by FWP, @UoG, 2013-06-13
%
if nargin < 1
    disp('showquad(xyf,inp,cproj,czone,crange,ctmap)');
    return
end
%
if nargin < 4
    cproj = 'utm';
end
if nargin < 5
    czone = '46S';
end
if nargin < 6
   data   = sim_inputdata(inp);
   crange = [min(data(:,3)),max(data(:,3))];
end
if nargin < 7
   ctmap = 'jet';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
czone = MCM_rmspace(czone);
czone = [czone(end-2:end-1),' ',czone(end)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colormap(ctmap);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid  = fopen(xyf,'r');
outd = [];
%
while feof(fid)==0 
    tfline = fgetl(fid);
    index  = findstr(tfline,'>');
    if isempty(index)==1
       tmp  = textscan(tfline,'%f%f');
       outd = [outd;tmp{1},tmp{2}];
    end
end
fclose(fid);
nregion = size(outd,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['There are total ' num2str(nregion/5) ' boxes!']);
%
fid = fopen(inp);
minp= textscan(fid,'%f %f %f %f %f %f %f\n',nregion/5);
fclose(fid);
inps= zeros(nregion/5,7);
for ni=1:nregion/5
    inps(ni,1) =minp{1}(ni);
    inps(ni,2) =minp{2}(ni);
    inps(ni,3) =minp{3}(ni);
    inps(ni,4) =minp{4}(ni);
    inps(ni,5) =minp{5}(ni);
    inps(ni,6) =minp{6}(ni);
end
if isempty(strfind(lower(cproj),'l'))==0
    [x,y] = utm2deg(outd(:,1).*1000,outd(:,2).*1000,czone);
    outd(:,2)    = x;
    outd(:,1)    = y;
    %
    [x,y] = utm2deg(inps(:,1).*1000,inps(:,2).*1000,czone);
    inps(:,1) = y;
    inps(:,2) = x;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mvstd = [];
mnonz = [];
%
s1 = subplot(1,2,1);%  or subplot(mnp)
s2 = subplot(1,2,2);%  or subplot(mnp)
%
for ni=1:nregion/5
    X = outd((ni-1)*5+1:(ni-1)*5+5,1);
    Y = outd((ni-1)*5+1:(ni-1)*5+5,2);
    %
    xmean = mean(X(:));
    ymean = mean(Y(:));
    dist  = sqrt((inps(:,1)-xmean).^2+(inps(:,2)-ymean).^2);
    index = find(dist==min(dist(:)));
    %Z 
    [vstd,vvar,nonz] = sar_roistd(infile,[min(X(:)),max(X(:)),min(Y(:)),max(Y(:))]);
    %hold on
    mvstd = [mvstd;vstd];
    mnonz = [mnonz;nonz];
    axes(s1);
    patch(X,Y,X.*0+vstd);
    axes(s2);
    patch(X,Y,X.*0+nonz);
end

%
axes(s1);
axis equal
xmin = min(outd(:,1));
xmax = max(outd(:,1));
ymin = min(outd(:,2));
ymax = max(outd(:,2));
set(gca,'XLim',[xmin,xmax]);
set(gca,'YLim',[ymin,ymax]);
set(gca,'TickDir','out');
caxis([min(mvstd),max(mvstd)]);
box on
axes(s2);
axis equal
xmin = min(outd(:,1));
xmax = max(outd(:,1));
ymin = min(outd(:,2));
ymax = max(outd(:,2));
set(gca,'XLim',[xmin,xmax]);
set(gca,'YLim',[ymin,ymax]);
set(gca,'TickDir','out');
caxis([min(mnonz),max(mnonz)]);
box on

disp('Data Value range:');
%data   = sim_inputdata(inp);
disp([min(mvstd),max(mvstd)]);
