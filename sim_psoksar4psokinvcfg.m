function sim_psoksar4psokinvcfg(psoksar,outcfg,rake)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% +Usage:
%    sim_psoksar4psokinvcfg(psoksar,outcfg)
% +Input:
% 
% Modification:
%  Feng, W.P, 2011-02-27
%
if nargin < 1
   disp('sim_psoksar4psokinvcfg(psoksar,outcfg)');
   return
end
if nargin < 2
    outcfg = 'PSOKINV.cfg';
end
if nargin < 3
    rake = [-135,-45];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fpara   = sim_psoksar2SIM(psoksar);
nfaults = size(fpara,1);
isinv   = zeros(nfaults,10);
inpara  = zeros(nfaults,10,3);
inpara(:,:,1)  = fpara(:,:);
inpara(:,:,2)  = fpara(:,:);
inpara(:,:,3)  = fpara(:,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim_invconfig(outcfg,nfaults,[],isinv,...
                       [],[],[],[],[],...
                       [],[],[],[],...
                       [],[],[],[],[],inpara,[],[],rake);
