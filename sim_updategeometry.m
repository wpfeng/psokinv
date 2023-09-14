function sim_updategeometry(inoksar,outoksar,varargin)
%
%
% Developed by Feng, W.P., @ EOS of NTU in Singapore, 2015-06-20
% Updated by Feng, W.P., @NRCan, 2015-10-09
% -> make it more general for any case
% -> now we can change any parameters through giving a keyward...
% 


dip           = [];
strike        = [];
cdepth        = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ni = 1:2:numel(varargin)
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
end
%
if nargin < 1
    %
    disp('sim_updategeometry(inoksar,outoksar,varargin)');
    disp(' Varargin inluding:');
    disp('    dip, 0-90');
    disp(' strike, 0-360');
    disp(' cdepth, 0-100'); 
    return
end
%
[fpara,zone]  = sim_oksar2SIM(inoksar);
cfpara        = sim_fparaconv(fpara,0,3);
%
if isempty(cdepth)
    cdepth = cfpara(5);
end
if isempty(dip)
    dip = cfpara(4);
end
%
if isempty(strike)
    strike = cfpara(3);
end
%
cfpara(3)     = strike;
cfpara(4)     = dip;
cfpara(5)     = cdepth;

%
%
fpara         = sim_fparaconv(cfpara,3,0);
sim_fpara2oksar(fpara,outoksar,zone);
%