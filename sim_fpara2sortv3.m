function [fpara,sortindex,fparadata] = sim_fpara2sortv3(fpara,xytype)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************

%
% Created by Feng, W.P
%
if nargin < 2
    xytype = 1;
end

%
oksarfpara = fpara;
for ni = 1:size(fpara,1)
    cfpara = sim_fpara2rand_UP(fpara(ni,:));
    oksarfpara(ni,1:2) = cfpara(1,1:2);
    
end
searchdata = oksarfpara(:,3).*0.153 + ...
             oksarfpara(:,4).*0.153 + ...   
             oksarfpara(:,1).*0.153 + ...
             oksarfpara(:,2).*0.153;    
searchdata = fix(searchdata.*1000)./1000;
%
index      = unique(searchdata);
%
fparadata   = cell(numel(index),2);
startpoints = zeros(numel(index),2); 

for ni = 1:numel(index)
    
    %cfpara  = fpara(searchdata==index(ni),:);
    [cindex,cfpara]  = sim_fpara2sort(fpara(searchdata==index(ni),:));
    pointsearch = cindex(:,1) + cindex(:,2).*100;
    %cfpara(:,8) = cindex(:,1);
    %cfpara(:,9) = cindex(:,2);
    %figure();
    %sim_fig3d(cfpara);
    getpoints         = cfpara(pointsearch==min(pointsearch(:)),1:2);
    %[size(cindex,1),size(cfpara)]
    
    %max(cindex(:,1))*max(cindex(:,2))
    startpoints(ni,:) = getpoints(1,:);
    fparadata{ni,1}   = cfpara;
    fparadata{ni,2}   = cindex;
    %
end
if xytype == 1
    [~,outindex] = sort(startpoints(:,1));
else
    [~,outindex] = sort(startpoints(:,2));
end
%
fpara = [];
for ni = 1 : numel(outindex)
    tmpfpara = fparadata{outindex(ni),1};
    fpara    = [fpara;tmpfpara];
    if ni == 1
        sortindex = fparadata{outindex(ni),2};
        %max(sortindex(:,1));
    else
        tmpindex  = fparadata{outindex(ni),2};
        %max(tmpindex(:,1))
        tmpindex(:,1) = max(sortindex(:,1)) + tmpindex(:,1);
        sortindex = [sortindex;tmpindex];
    end
    %max(sortindex(:,1))
end
