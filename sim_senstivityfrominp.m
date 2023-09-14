function [msensi,dirsensi] = sim_senstivityfrominp(oksar,inpfile,mrakecons)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
% Created by Feng,W.P., 2011/10/26, @ GU
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 1
    disp('msensi = sim_senstivityfrominp(oksar,inpfile,mrakecons)');
    msensi = [];
    return
end
%
if ischar(oksar)
    fpara       = sim_oksar2SIM(oksar);
else
    fpara   = oksar;
end
if ischar(inpfile)
    input       = sim_inputdata(inpfile);
else
    input  = inpfile;
end
%
tfpara      = fpara;
tfpara(:,8) = 0;
tfpara(:,9) = 0;
sfpara      = tfpara;
%
global rakecons
%
%
rakecons= mrakecons;
if numel(rakecons(:,1))~= numel(tfpara(:,1))
   rakecons = repmat(rakecons(1,:),numel(tfpara(:,1)),1);
end
lb = input(:,1).*0;
ub = input(:,1).*0 + 1000;
for ni = 1:numel(fpara(:,1))
    if rakecons(ni,1) ~=0
        [~,sgreen,dgreen]  = sim_oksargreenALP(fpara(ni,:),input);
        g1           = sgreen .* cosd(rakecons(ni,2)) + dgreen .* sind(rakecons(ni,2));
        sx           = sim_bvls(g1,input(:,3),lb,ub);%[sgreen\input(:,3)];
        
        sxcorr       = (sum(abs(input(:,3) - g1*sx)))/sum(abs(input(:,3)));%.*exp(1-corr(g1*sx,input(:,3)));%abs(std(input(:,3))-std(sgreen*sx-input(:,3)))*exp(corr(dgreen*sx,input(:,3)));%corr(green*cx,input(:,3));
        %sxcorr
        scorr        = corr(input(:,3),g1*sx);
        tfpara(ni,8) = sxcorr;
        sfpara(ni,8) = scorr;
        %
        g2           = sgreen .* cosd(rakecons(ni,3)) + dgreen .* sind(rakecons(ni,3));
        dx           = sim_bvls(g2,input(:,3),lb,ub);%dgreen\input(:,3);
        sxcorr       = sum(abs(input(:,3) - g2*dx))/sum(abs(input(:,3)));%.*exp(1-corr(g2*dx,input(:,3)));%abs(std(input(:,3))-std(sgreen*sx-input(:,3)))*exp(corr(dgreen*sx,input(:,3)));%corr(green*cx,input(:,3));
        scorr        = corr(input(:,3),g2*dx);
        tfpara(ni,9) = sxcorr;
        sfpara(ni,9) = scorr;
    end
end
msensi   = tfpara;
dirsensi = sfpara;
