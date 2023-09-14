function [fpara,zone] = sim_openfault(inoksar)
%
%
% Developed by Wanpeng Feng, @NRCan, 2016-06-07
%
if nargin < 1
    disp('[fpara,zone] = sim_openfault(inoksar)')
    return
end
[tmp,tname,text] = fileparts(inoksar);
%
switch upper(text)
    case '.SIMP'
        [fpara,zone] = sim_simp2fpara(inoksar);
    case '.OKSAR'
        [fpara,zone] = sim_oksar2SIM(inoksar);
end
