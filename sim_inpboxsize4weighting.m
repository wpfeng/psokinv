function sim_inpboxsize4weighting(xyf,inp,outweight,czone,type)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% 
% Show the Quadtree Region
% Created by Feng, Wanpeng, IGP/CEA,2009/06
% Rewrite showquad into sim_inpboxsize4weighting:
%  to weihgt the obs using box size...
%  by FWP, @ GU, 2013-03-28
%
% if nargin < 3
%     cproj = 'utm';
% end
% if nargin < 4
%     czone = '46S';
% end
% if nargin < 5
%    %inp
%    data   = sim_inputdata(inp);
%    crange = [min(data(:,3)),max(data(:,3))];
% end
% if nargin < 6
%    ctmap = 'jet';
% end
if nargin < 4
    czone = '38S';
end
if nargin < 5
    type = 1;
end
%
czone = MCM_rmspace(czone);
czone = [czone(end-2:end-1),' ',czone(end)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%colormap(ctmap);
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
% if isempty(strfind(lower(cproj),'l'))==0
%     [x,y] = utm2deg(outd(:,1).*1000,outd(:,2).*1000,czone);
%     outd(:,2)    = x;
%     outd(:,1)    = y;
%     %
%     [x,y] = utm2deg(inps(:,1).*1000,inps(:,2).*1000,czone);
%     inps(:,1) = y;
%     inps(:,2) = x;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
weigs = zeros(nregion/5,1);
for ni=1:nregion/5
    X = outd((ni-1)*5+1:(ni-1)*5+5,1);
    Y = outd((ni-1)*5+1:(ni-1)*5+5,2);
    %
    xmean = mean(X(:));
    ymean = mean(Y(:));
    dist  = sqrt((inps(:,1)-xmean).^2+(inps(:,2)-ymean).^2);
    index = find(dist==min(dist(:)));
    %
    polyxy = [X(:),Y(:)];
    %
    if nargin == 4
       %
       [xm,ym] = deg2utm(polyxy(:,2),polyxy(:,2),czone);
       %polyxy = [xm(:)./1000,ym(:)./1000];
    else
        xm = X(:);
        ym = Y(:);
    end
    %
    weigs(index(1)) = (max(xm./1000) - min(xm./1000)) .* ...
                       (max(ym./1000) - min(ym./1000));
        
end
weigs = weigs ./ sum(weigs) .* (nregion/5);
weigs = diag(weigs);
%
if type == 1
   cov = weigs;
end
save(outweight,'cov');
%
% 
