function outfpara = sim_fpara2boundary(fpara)
%
%
%
%
% developed by Wanpeng Feng, @CCMEO, NRCan, 2016-10-26
%
strs = unique(fpara(:,3));
%
outfpara = [];
for ni = 1:numel(strs)
    cfpara = fpara(fpara(:,3) == strs(ni),:);
    depths = unique(cfpara(:,5));
    for nj = 1:numel(depths)
        tmpfpara = cfpara(cfpara(:,5)==depths(nj),:);
        tmpfpara(:,8) = 0;
        tmpfpara(:,9) = 0;
        if nj == 1
            tmpfpara(:,8) = 1;
        end
        %
        if nj == numel(depths)
            tmpfpara(:,8) = 4;
        end
        [x,y] = eqs_rotaxs(tmpfpara(:,1),tmpfpara(:,2),mean(tmpfpara(:,3)));
        tmpfpara(x==min(x),8) = 2;
        tmpfpara(x==max(x),8) = 3;
        outfpara = [outfpara;tmpfpara];
    end
end