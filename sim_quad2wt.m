function wt = sim_quad2wt(root,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% 
% Show the Quadtree Region
% Created by Feng, Wanpeng, IGP/CEA,2009/06
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
   disp('wt = sim_quad2wt(root,isplot)');
   wt = [];
   return
end
if nargin < 2
   isplot = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xyf = [root,'.quad.box.xy'];
inp = [root,'.inp'];
if exist(xyf,'file')==0
   xyf = [root,'.rb.box.xy'];
end
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
%disp(inps(:,3)); 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wt    = zeros(nregion/5,1);
for ni=1:nregion/5
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    X = outd((ni-1)*5+1:(ni-1)*5+5,1);
    Y = outd((ni-1)*5+1:(ni-1)*5+5,2);
    xmean = mean(X(:));
    ymean = mean(Y(:));
    dist  = sqrt((inps(:,1)-xmean).^2+(inps(:,2)-ymean).^2);
    index = dist==min(dist(:));
    parea  = sim_polyarea(X,Y);
    wt(index) = parea;
    if isplot == 1
       patch(X,Y,parea);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
if isplot == 1
    axis equal
end
matfile = [root,'.area.mat'];
vcm     = diag(sqrt(wt)./sum(sqrt(wt(:))));
eval(['save ' matfile ' vcm']);
