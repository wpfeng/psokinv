function lap = sim_fpara2lap_bydist(fpara,smoothingmodel)
%
% To calculate the Laplacian matrix due to the absolute distance per two
% patches...
%
% Created by Feng, Wanpeng, in Beijing, 2011-03-30
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updated by Wanpeng Feng, @CCRS/NRCan, 2017-04-24
%
% Updated by Wanpeng Feng, @CCRS/NRCan, 2017-09-25
% to find nearest patches within the same plate. 
%
if nargin < 2
    %
    smoothingmodel = 'XYZ';
    %
end
%
np   = size(fpara,1);
lap  = zeros(np,np);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [t_mp,~,t_mp,Cx,Cy,Cz] = sim_plot3d(fpara);
[Cx,Cy,Cz] = sim_fpara2corners(fpara,'cc');
Cx = Cx-0.01;
Cy = Cy-0.01;
Cz = Cz-0.01;
%
for ni = 1:np
    switch upper(smoothingmodel)
        case 'XYZ'
            dist = sqrt((Cx-Cx(ni)).^2 + ...
                (Cy-Cy(ni)).^2 + ...
                (Cz-Cz(ni)).^2);
        case 'XY'
            dist = sqrt((Cx-Cx(ni)).^2 + ...
                (Cy-Cy(ni)).^2);
        case 'XZ'
            dist = sqrt((Cx-Cx(ni)).^2 + ...
                (Cy-Cy(ni)).^2);
        case 'YZ'
            dist = sqrt((Cz-Cz(ni)).^2 + ...
                (Cy-Cy(ni)).^2);
    end
    [sordist,sorind] = sort(dist);
    negd             = 1./sordist(2:9);
     posd            = sum(negd(:));
     lap(ni,ni)      = posd;
     for nk = 2:9
         lap(ni,sorind(2:9)) = -1.*negd;
     end
end
