function [fpara,zone] = sim_infpara(inoksar)
%
%
%
% Developed by Feng, W.P., @ EOS of NTU, Singapore, 2015-06-27
%
[tmp,tmp,bext] = fileparts(inoksar);
%
switch upper(bext)
    case '.OKSAR'
        [fpara,zone] = sim_oksar2SIM(inoksar);
    case '.SIMP'
        [fpara,zone] = sim_simp2fpara(inoksar);
    otherwise 
        disp('No identified format was found!!');
        return
        %
end
%