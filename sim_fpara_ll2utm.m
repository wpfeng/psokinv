function fpara = sim_fpara_ll2utm(infault)
%
%
%
[cfpara,zone] = sim_openfault(infault);
%
[x,y] = deg2utm(cfpara(:,2),cfpara(:,1),zone);
%
fpara = cfpara;
fpara(:,1) = x./1000;
fpara(:,2) = y./1000;
%