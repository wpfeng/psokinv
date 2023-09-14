function [fpara,sortindex] = sim_fpara2sort_fixmodel(fpara,xytype,prec)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
if nargin < 2
    xytype = 1;
end
if nargin < 3
    prec = 10;
end
%
deps    = fix((fpara(:,5)));%.*prec);
udepth  = unique(deps);
%
[~,dindex] = sort(udepth);
sortindex_y= zeros(size(deps(:),1),1);
%
for ni = 1:numel(deps)
   % [~,sortindex_y] = sort(deps);
   sortindex_y(ni) = dindex(udepth==deps(ni));
end
%
sortindex_x = [];
for ni = 1:numel(dindex)
    %index_x = find(fpara(:,5)==sortindex_y(ni));
    if xytype==1
        cpx = fpara(sortindex_y==dindex(ni),1);
        cpx = fix(cpx.*prec);%./prec;
        ttxdepth     = unique(cpx);
        [~,ttxindex] = sort(ttxdepth);
        tempx      = zeros(size(cpx(:),1),1);
        for nj = 1:numel(cpx)
            tempx(nj) = ttxindex(ttxdepth==cpx(nj));
        end
        sortindex_x = [sortindex_x;tempx];
    else
        cpx = fpara(sortindex_y==dindex(ni),2);
        cpx = fix(cpx.*prec);%./prec;
        ttxdepth     = unique(cpx);
        [~,ttxindex] = sort(ttxdepth);
        tempx      = zeros(size(cpx(:),1),1);
        for nj = 1:numel(cpx)
            tempx(nj) = ttxindex(ttxdepth==cpx(nj));
        end
        sortindex_x = [sortindex_x;tempx];
    end
end
sortindex = [sortindex_x(:) sortindex_y(:)];

