function [rfpara,cfpara] = sim_rcest(matfile,alpha,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% +Fucntion: [rfpara,cfpara] = sim_rcest(matfile,alpha,isplot);
%             rfpara, the fault model, n*10, with the data resolution info...
%             cfpara, the fault model, n*10, with the variance of the model...
% Input:
%          matfile, the mat file, created by sim_smest
%            alpha, the smooth coefficent...
%           isplot, when the result is returned, two figures will be
%          plotted, if isplot equal 1.
% Examples: 
%         alpha  = 0.25;
%        isplot  = 1;
%          [r,c] = sim_rcest(matfile,alpha,isplot);
% Created by Feng W.P
% 2010-05-25
%
% Resolution estimation ...
%
eval(['load ' matfile]);
if nargin < 2
   alpha = 0.025;
end
if nargin < 3
   isplot = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[slap,dlap] = sim_fpara2lapv2(disf);
%
% Structure the Laplacian matrix 
%
L           = [slap dlap.*0;slap.*0 dlap];
%
% Geophyciscal Data Analysis: Discrete Inverse Theory
% William Menke
%
G_g         = (G'*G+alpha.*L)\G';
%
% begin to calculate the resolution of the model resolution
%
R           = G_g*G;
res         = mean(disf(:,6).*disf(:,7))./sqrt(diag(R));
disf(:,8)   = res(1:end/2);
disf(:,9)   = res(end/2+1:end);
rfpara      = disf;
%
% Covariance of the model parameters
covm        = G_g*G_g';
res         = diag(covm);
disf(:,8)   = res(1:end/2);
disf(:,9)   = res(end/2+1:end);
cfpara      = disf;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isplot==1
    figure('Name','the Variance of the Model Parameter Estimates');
    sim_fig2d(disf);
    figure('Name','the resolution of the data');
    sim_fig2d(rfpara,'vector',0:5:25);
end
