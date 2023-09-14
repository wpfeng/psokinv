function index = sim_fpara2index_dep(fpara)
%
%
% Developed by Wanpeng Feng, @NRCan
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deps = unique(fpara(:,5));
index = fpara(:,1:2);
%

for ni = 1:numel(fpara(:,1))
    cdep = fpara(ni,5);
    inddepth = find(deps == cdep);
    cfpara = fpara(fpara(:,5)==cdep,:);
    y = cfpara(:,2);
    [cy,ind] = sort(y);
    indy = ind(cy==fpara(ni,2));
    index(ni,:) = [inddepth,indy];
end