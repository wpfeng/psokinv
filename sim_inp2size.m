function inpsize = sim_inp2size(xyf,inp,cproj,czone,crange,ctmap)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% 
% Show the Quadtree Region
% Created by Feng, Wanpeng, IGP/CEA,2009/06
%
if nargin < 3
    cproj = 'utm';
end
if nargin < 4
    czone = '46S';
end
if nargin < 5
   %inp
   data   = sim_inputdata(inp);
   crange = [min(data(:,3)),max(data(:,3))];
end
if nargin < 6
   ctmap = 'jet';
end
czone = MCM_rmspace(czone);
czone = [czone(end-2:end-1),' ',czone(end)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%colormap(ctmap);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen(xyf,'r');
outd= [];
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
if isempty(findstr(lower(cproj),'l'))==0
    [x,y] = utm2deg(outd(:,1).*1000,outd(:,2).*1000,czone);
    outd(:,2)    = x;
    outd(:,1)    = y;
    %
    [x,y] = utm2deg(inps(:,1).*1000,inps(:,2).*1000,czone);
    inps(:,1) = y;
    inps(:,2) = x;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inpsize = data(:,1);
for ni=1:nregion/5
    X = outd((ni-1)*5+1:(ni-1)*5+5,1);
    Y = outd((ni-1)*5+1:(ni-1)*5+5,2);
    %
    xmean = mean(X(:));
    ymean = mean(Y(:));
    dist  = sqrt((inps(:,1)-xmean).^2+(inps(:,2)-ymean).^2);
    index = find(dist==min(dist(:)));
    Z     = X.*0+inps(index(1),3);
    inpsize(index(1)) = polyarea(X,Y);
    %patch(X,Y,Z);
    
end
% axis equal
% xmin = min(outd(:,1));
% xmax = max(outd(:,1));
% ymin = min(outd(:,2));
% ymax = max(outd(:,2));
% set(gca,'XLim',[xmin,xmax]);
% set(gca,'YLim',[ymin,ymax]);
% set(gca,'TickDir','out');
% caxis(crange);
% box on
% 
% disp('Data Value range:');
% data   = sim_inputdata(inp);
% disp([min(data(:,3)),max(data(:,3))]);
