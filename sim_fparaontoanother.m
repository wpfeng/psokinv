function outfpara = sim_fparaontoanother(fpara,refpara,scale)
%
%
%
% developed by Wanpeng Feng, @Ottawa, 2016-10-28
%
outfpara = fpara;
outfpara(:,8) = 0;
outfpara(:,9) = 0;
%
if nargin < 3
   scale = 0.25;
end
%
[x0,y0] = eqs_rotaxs(fpara(:,1),fpara(:,2),mean(refpara(:,3)));
[x1,y1] = eqs_rotaxs(refpara(:,1),refpara(:,2),mean(refpara(:,3)));
for ni = 1: numel(fpara(:,1))
    %
    dist = sqrt((x0(ni)-x1(:)).^2 + ...
                (fpara(ni,5)-refpara(:,5)).^2);
    %        
    cfpara = refpara(dist <= scale * (max(dist)-min(dist)) + min(dist),:);
    %
    cdist = dist(dist <= scale * (max(dist)-min(dist)) + min(dist));
    cdist = 1./cdist;
    outfpara(ni,8) = sum(cfpara(:,8) .* cdist./sum(cdist));
    outfpara(ni,9) = sum(cfpara(:,8) .* cdist./sum(cdist));
       
end