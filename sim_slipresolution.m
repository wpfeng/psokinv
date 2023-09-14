function [fpara,rstrslip,rdipslip] = sim_slipresolution(matfile,alpha,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Usage:
%    [rstr,rdip]  = sim_slipresolution(matfile,apha,isplot)
%   
% Input:
%    matfile, the mat database created by ps_smest
%      alpha, the smooth coefficient
%     isplot, the switch of plotting, default value is 1
%
% Output:
%    rstrslip,
%    rdipslip,
%    cstrslip,
%    cdipslip,
% LOG:
%   Created by Feng, W.P, 2009-10-04
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Modified by Feng, W.P,2010-10-18
%   -> remove estimation of covariance of slip models
%   -> develop a function from a batch script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%resolution estimation...
%load psokinv_SM_2Interf_3Fault_PSOKINV_RBv5/psokinv_SM_2Interf_3Fault_PSOKINV_RBv5_No1Fault_Dip79.2006.mat
%load psokinv_SM_2Interf_1Fault_PSOKINV_RBv6\psokinv_SM_2Interf_1Fault_PSOKINV_RBv6_No1Fault_Dip79.mat
%
if nargin < 2
   alpha = 0.1;
end
if nargin < 3
    isplot = 0;
end
%
eval(['load ',matfile]);
%
slap        = lap{1};
dlap        = lap{1};
L           = [slap dlap.*0;slap.*0 dlap];
G_g         = (G'*G+alpha.*L)\G';
% begin to calculate the resolution of the model resolution
%
R               = G_g*G;
Rdiag           = diag(R);
Rdiag(Rdiag<0)  = 0;
res             = 1./sqrt(Rdiag);
res(isnan(res)) =  100;
res(isinf(res)) = -100;
%res(isreal(res)==0) = 0;
disf(:,8)   = 0;
disf(:,9)   = 0;
rstrslip    = disf;
rdipslip    = disf;
rstrslip(:,8)   = res(1:end/2);
rdipslip(:,9)   = res(end/2+1:end);
fpara        = disf;
fpara(:,8)   = res(1:end/2);
fpara(:,9)   = res(end/2+1:end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%% covariance of the model parameters
% covm        = G_g*G_g';
% res         = diag(covm);
% disf(:,8)   = res(1:end/2);
% disf(:,9)   = res(end/2+1:end);
% %
% cstrslip      = disf;
% cstrslip(:,9) = 0;
% 
% cdipslip      = disf;
% cdipslip(:,8) = 0;
% %
%disp(rstrslip(:,8:9));
if isplot==1
    % plot the resolution along strike and dip separately.
    figure('Name','Recolution along strike direction');
    sim_fig2d(rstrslip,'vector',0.5:5:rstrslip(:,8),'isquiver',0);
    figure('Name','Resolution along diping direction');
    sim_fig2d(rdipslip,'vector',0.5:5:rdipslip(:,9),'isquiver',0);
    %
%     figure('Name','the Variance of slip along the strike');
%     sim_fig2d(cstrslip,'vector',0.05:0.1:fix(cstrslip(:,8)),'isquiver',0);
%     figure('Name','the Variance of slip along the dip');
%     sim_fig2d(cdipslip,'vector',0.05:0.1:fix(cdipslip(:,9)),'isquiver',0);
end
