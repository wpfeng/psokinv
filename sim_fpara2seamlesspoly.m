function [distfpara,polys] = sim_fpara2seamlesspoly(rfpara,maxdepth,subv,dampingfactor,isplot)
%
% 
% Developed by Wanpeng Feng, @Ottawa, 2017-04-12
%
outpolym = fixmodel_fpara2patch(rfpara,maxdepth);
polys = [];
for ni = 1:numel(outpolym)
    %
    if isplot == 1
        plot3(outpolym{ni}(:,1),outpolym{ni}(:,2),outpolym{ni}(:,3).*-1,'-b','LineWidth',5);
        hold on
    end
    %
    outpoly = sim_distpoly(outpolym{ni},subv,dampingfactor,isplot);
    if ni == 1
        polys = outpoly;
    else
        polys = [polys outpoly];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
distfpara = zeros(numel(polys),10);
meanazi = mean(rfpara(:,3));
%
for ni = 1:numel(polys)
    cpoly = polys{1,ni};
    distfpara(ni,:) = sim_4points4fpara(cpoly);
end
%
