function outre = sim_smbestpara(matfile)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created By Feng, W.P., @ GU, 2012/01/24
% 
%
if nargin < 1
    matfile = 'ps_sm_rb_2track/SMEST_unif_2track.mat';
end
%
mats   = load(matfile);
coutre = mats.mabicre;
lamda  = mats.lamda;
%
outre  = zeros(numel(coutre),7);
numpts = 0;
for ni = 1:numel(coutre)
    tre = coutre{ni};
    %
    model = tre.disf;
    cdip  = model(1,4);
    %%%%
    smest = tre.smest;
    for nj = 1:numel(smest(:,1))
        numpts = numpts + 1;
        vnorm = smest(nj,2);
        vroug = smest(nj,3);
        %%%%
        fpara = tre.disf;
        slips = tre.dismodel{nj};
        %whos slips
        fpara(:,8) = slips(1:end/2);
        fpara(:,9) = slips(end/2+1:end);
        %
        [~,~,mw] = sim_fpara2moment(fpara);
        %
        [rough,maxr] = sim_fpara2rough(fpara);
        outre(numpts,1) = cdip;
        outre(numpts,2) = lamda(nj);
        outre(numpts,3) = vnorm;
        outre(numpts,4) = vroug;
        outre(numpts,5) = mw;
        outre(numpts,6) = rough;
        outre(numpts,7) = maxr;
    end
end
%
%
%
%
