function [X,rsq,qual] = cgls_bvls(A,b,l,u,crit,itern,std,x0)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:
%      solve min||Ax-b|| and l<= x <=u
% Input:
%      A, the matrix,m*n
%      b, observation vector,m*1
%      l, low bounds,n*1
%      u, up  bounds,n*1
%   crit, the criterion for 
%  itern, the threshold for termination
% Output:
%       X, n*1
%     rsq, the residual
%    qual, switch for showing which step over,1) the x convergence based on
%    the criteriation;3) there is no improvment when iteration;4)iteration
%    beyond the itern.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Wanpeng Feng, IGP/CEA,2010-July
% -> wanpeng.feng@hotmail.com;
% -> firstly involved for Geodetic data inversion
%
%**************************************************************************
% Modified by Feng, W.P, 2011-06-17, @ BJ
% -> add std of data for model constraints
%**************************************************************************
%function [X,rsq,qual]=cgls_xu_stf_ad(A,b,crit,itern)
%-----------------------------------------------------------------
% function [qual,X,rsq]=cgls_xu(A,X,b,Ac,g,h,crit2,bsq,...
%          rp,sdim,cont,velrupm,smthnss,itern);

% SPAR is a function used by SPARMAIN.
% For help see SPARMAIN.
% XL, SF 9-95

% Revised, Xu Lisheng, Paris, Aug., 1998
%-----------------------------------------------------------------    
%residu=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Feng, Wanpeng, 2010-July, from cgls_xu.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add std, data standard deviation, by Feng, W.P, 20110519
% 
sa = size(A);
Ac = sa(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin >= 7 && isempty(std) ~= 1
    ustd = unique(std);
    if numel(ustd) == 1
        std = std.*0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 3 || isempty(l)
   %
   l = zeros(Ac,1)-10^10;
end
if nargin < 4 || isempty(u)
    u = zeros(Ac,1)+1000;
end
if nargin < 7 || isempty(crit)
    crit = 10e-10;
end
if nargin < 6 || isempty(itern)
    [t_mp,n] = size(A);
    itern = n;
end
if nargin < 7 || isempty(std)
    std = b.*0;
end
if size(std,1) < size(b,1)
   cstd                  = zeros(size(b));
   cstd(1:size(std,1),:) = std;
   std                   = cstd;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
crit2 = Ac.*crit.^2;
if nargin < 8
   X = zeros(Ac,1);
else
   X = x0;
end
%
bsq   = sum(b.^2);
% Initial x0
xi    = (A*X)-b;
rp    = sum(xi.^2);
g     = -(A'*xi);
h     = g;
residu= zeros(itern,1);
%-------------------------------
for iter = 1:(100*Ac)
    xi   = A*h;
    anum = sum(g.*h);
    aden = sum(xi.^2);
    
    %%
    if aden == 0
        disp('very singular matrix')
    end
    anum = anum./aden;
    X    = X + anum.*h;
    %Constraits with bounds
    X(X<l) = l(X<l);%./1000000;
    X(X>u) = u(X>u);%./1000000;
    xj     = (A*X)-b;
    %
    %%%% modified by Feng,W.P 20110519, add STD constraint in LSQ...
    %
    xj(abs(xj) <= std) = 0;  
    %%
    rsq          = sum(xj.^2);
    residu(iter) = rsq;
    %%
    if (rsq==rp||rsq<=(bsq*crit2)||iter==itern)
        %
        % here ITERN is the iteration time
        %
        qual = 1;
        rsq  = residu(1:iter);
        return
    end
    %
    rp  = rsq;
    xi  = A'*xj;
    gg  = sum(g.^2);
    dgg = sum((xi+g).*xi);
    if gg == 0
        qual = 3;
        disp('gg=0')
        X(:) = inf;
        return
    end
    g = -xi;
    h = g+dgg./gg.*h;
    %disp(rsq);
end
qual = 4;

%rsq  = residu;
%disp('too many iterations')
%--------------------------End----------------------------------------
