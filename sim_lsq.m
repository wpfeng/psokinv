function [slips,rsq] = sim_lsq(G,D,L,alpha,COV,algor,minmoment,LB,UB,std)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
% Created by Feng, Wanpeng,2011-03-30
% Modified by Feng, W.P, 2011-05-19
% -> add std, standard deviation of obs as model new cosntraint
%
global slipscale 

if nargin < 6
   algor = 'cgls';
end
if nargin < 10
    std = D.*0;
end
%
A  = [COV*G;L.*alpha];
D  = COV*D;
if size(A,1)>size(D)
    D = [D;zeros(size(A,1)-size(D,1),1)];
end
%
if minmoment ~= 0
    if isempty(slipscale)
        slipscale = 1;
    end
    Aslip = (A(1,:).*0+1).*slipscale(:)';
    %
    %
    A     = [A;minmoment.*Aslip];
    D     = [D;0];
end
%
switch lower(algor)
    case 'bvsl'
       slips  = bvls(A,D,LB,UB);
    case 'lsqlin'
        options = optimset('LargeScale','on','display','off');
       [slips,~,rsq] = lsqlin(A,D,[],[],[],[],LB,UB,[],options);
    otherwise
       [slips,  rsq] = cgls_bvls(A,D,LB,UB,[],[],std);
       rsq           = rsq(end);
end
