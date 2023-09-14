function [sigma,mu,A]=sim_gaussianfit(x,y,h)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************

%
% [sigma,mu,A] = sim_gaussfit(x,y)
% [sigma,mu,A] = sim_gaussfit(x,y,h)
%
% this function is doing fit to the function
% y=A * exp( -(x-mu)^2 / (2*sigma^2) )
%
% the fitting is been done by a polyfit
% the lan of the data.
%
% h is the threshold which is the fraction
% from the maximum y height that the data
% is been taken from.
% h should be a number between 0-1.
% if h have not been taken it is set to be 0.2
% as default.
%


%% threshold
if nargin <= 2 || isempty(h)==1
   h=0.2;
end

%% cutting
ymax = max(y(:));
xnew = [];
ynew = [];
for n=1:length(x)
    if y(n)>ymax*h;
        xnew=[xnew,x(n)];
        ynew=[ynew,y(n)];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fitting
ylog = log10(ynew);
xlog = xnew;
p    = polyfit(xlog(:),ylog(:),2);
A2   = p(1);
A1   = p(2);
A0   = p(3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigma = sqrt(-1/(2*pi*A2));
mu    = A1*sigma^2;
A     = exp(A0+mu^2/(2*sigma^2));

