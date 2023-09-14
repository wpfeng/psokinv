function outdata = sim_smestoutdata(inmat)
%
%
% Developed by Feng, W.P., @ EOS of NTU, in Singapore, 2015-06-18
%
inm          = load(inmat);
osim         = inm.osim;
nsample      = numel(osim);
fpara        = inm.disf;
%
outdata      = zeros(nsample,3);
outdata(:,1) = inm.lamda;
slips        = inm.dismodel;
input        = inm.input;
zone         = inm.utmzone;
abicre       = inm.mabicre;
abicre       = abicre{1};
smest        = abicre.smest;
%
for ni = 1:nsample
    %
    outdata(ni,2) = sim_rms(input(:,3)-osim{ni});
    cslip      = slips{ni};
    fpara(:,8) = cslip(1:end/2);
    fpara(:,9) = cslip(end/2+1:end);
    %
    %outdata(ni,3) = sim_fpara2roughness(fpara);
    outdata(ni,3) = smest(ni,3);
    sim_fpara2simp(fpara,['Fault_slip_',num2str(ni),'.simp'],zone);
end