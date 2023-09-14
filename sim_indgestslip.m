function pfpara = sim_indgestslip(pfpara,refpara,distthresh)
%
%
% by Wanpeng Feng, @Ottawa, 2017-04-16
%
%
pfpara(:,8) = 0;
pfpara(:,9) = 0;
pfpara(:,10)= 0;
for ni = 1:numel(pfpara(:,1))
    %
    dist = sqrt((pfpara(ni,1)-refpara(:,1)).^2 + ...
                (pfpara(ni,2)-refpara(:,2)).^2 + ...
                (pfpara(ni,5)-refpara(:,5)).^2);
    midist = min(dist);
    if midist<=distthresh
        pfpara(ni,8) = refpara(dist==midist,8);
        pfpara(ni,9) = refpara(dist==midist,9);
        pfpara(ni,10) = refpara(dist==midist,10);
    end
end