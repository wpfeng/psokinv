function rms = sim_rms(d1,d2)
%
%
% Created by Feng,W.P.,@ UoG, 2012-11-18
% Updated by FWP, @ UoG, 2013-04-18
%
if nargin > 1
    rms = sqrt(sum((d1-d2).^2)/numel(d1));
else
    rms = sqrt(sum(d1.^2)/numel(d1));
end
