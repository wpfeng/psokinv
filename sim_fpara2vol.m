function vol = sim_fpara2vol(fpara,factor)
%
%
%
% Calculated volumb changes due a vertical closing or opening action
%
%
% Developed by Wanpeng Feng, @NRCan, 2016-09-20
%
if nargin < 2
    factor = 1;
end
%
vol = sum(fpara(:,6).*fpara(:,7).*fpara(:,10).*factor.*10^6);