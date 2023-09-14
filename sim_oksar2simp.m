function fpara = sim_oksar2simp(inoksar,simp)
%
%
%
% Developed by Feng, W.P., @NRCan, 2015-10-12
%
[fpara,zone] = sim_oksar2SIM(inoksar);
sim_fpara2simp(fpara,simp,zone);
%