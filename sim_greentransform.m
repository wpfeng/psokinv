function [soG,doG] = sim_greentransform(sG,dG,r1,r2)
%
%
%
%
% 
% transform GREEN function with given rakes...
% by Wanpeng Feng, @RNCan, 2016-09-27
%
soG = sG;
doG = dG;
%
for nrg = 1:numel(sG(:,1))
    %
    soG(nrg,:)  = sG(nrg,:) .* cosd(r1(:))' + ...
                  dG(nrg,:) .* sind(r1(:))';
    doG(nrg,:)  = sG(nrg,:) .* cosd(r2(:))' + ...
                  dG(nrg,:) .* sind(r2(:))';
    %
end