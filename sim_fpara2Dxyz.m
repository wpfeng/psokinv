function [cx,cy,cz] = sim_fpara2Dxyz(fpara,x0,y0,mode)
%
%
for i = 1:size(fpara,1)
    p = sim_fpara2allcors(fpara(i,:));
    cx = p(:,1);
    cy = p(:,2);
    cz = p(:,3);
    %
    cz = [cz(1:4)',cz(1)];
    [cx,cy] = sim_rotaxs(cx,cy,mean(fpara(:,3)),90,x0,y0);
    cx = [cx(1:4)',cx(1)];
    cy = [cy(1:4)',cy(1)];
    cx = cx - x0;
    cy = cy - y0;
    switch lower(mode)
        case {'xz'}
            px = cx;
            py = cz;
        case {'xy'}
            px = cx;
            py = cy;
        case {'yz'}
            px = cy;
            py = cz;
    end
    plot(px,py,'-');
    hold on
end
end