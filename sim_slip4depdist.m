function [outdata,maxdepv] = sim_slip4depdist(fpara,precision)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
% created by Feng, W.P., 2012-01-16, @ GU
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 2
    precision = 0.01;
end
depth  = fpara(:,5);
pdepth = fix(depth./precision);
udept  = unique(pdepth);
%
outdata = zeros(numel(udept),2);
maxdepv = outdata;
for ni = 1:numel(udept)
    cfpara = fpara(pdepth==udept(ni),:);
    cslip  = sqrt(cfpara(:,8).^2+cfpara(:,9).^2);
    [~,m0] = sim_fpara2moment(cfpara);
    outdata(ni,1) = cfpara(1,5);
    outdata(ni,2) = m0;
    maxdepv(ni,1) = cfpara(1,5);
    vmax          = mean(cslip);
    maxdepv(ni,2) = max(vmax(1));
end
