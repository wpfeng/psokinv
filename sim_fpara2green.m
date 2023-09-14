function [G,rakes] = sim_fpara2green(fpara,input,rakecons)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
% Created by Feng, Wanpeng, 2011-03-30
% Modified by Feng,W.P., @ Glasgow, 2012-09-08
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 3
    rakecons = [0,0,90];
end
%
if numel(rakecons(:,1))==1
    rakecons = repmat(rakecons,numel(fpara(:,1)),1);
end
%%
ncol  = numel(fpara(:,1));
G     = zeros(size(input,1),ncol);
%%
for ni = 1:ncol
    cfpara      = fpara(ni,:);
    cfpara(1,8) = cosd(rakecons(ni,2));
    cfpara(1,9) = sind(rakecons(ni,2));
    dis         = multiokadaALP(cfpara,input(:,1),input(:,2),0);
    Dip1_G      = dis.E.*input(:,4) + dis.N .*input(:,5) + dis.V.*input(:,6);
    G(:,ni)     = Dip1_G(:)';
    if rakecons(ni,3) ~= rakecons(ni,2)
        cfpara(1,8) = cosd(rakecons(ni,3));
        cfpara(1,9) = sind(rakecons(ni,3));
        dis        = multiokadaALP(cfpara,input(:,1),input(:,2),0);
        Dip2_G     = dis.E.* input(:,4) + dis.N .* input(:,5) + dis.V.* input(:,6);
        G(:,ncol + ni) = Dip2_G;
    end
end
%whos G
rakes = rakecons(:,2:3);
%
