function sim_mcest2slipmodel(inmat)
%
%
%
% Developed by Feng, W.P., @ EOS of NTU, Singapore, 2015-06-24
%
cmat = load(inmat);
fpara   = cmat.fpara;
mabicre = cmat.mabicre;
mcslip  = mabicre{1}.mcslip;
zone    = cmat.utmzone;
%
for ni = 1:numel(mcslip(1,:))
    cslip = mcslip(:,ni);
    fpara(:,8) = cslip(1:end/2);
    fpara(:,9) = cslip(end/2+1:end);
    sim_fpara2simp(fpara,[num2str(ni),'.simp'],zone);
end
%
