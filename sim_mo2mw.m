function mw=sim_mo2mw(mo,unit)
%
%
% Developed by Wanpeng Feng, @NRCan, 2016-07-10
%
if nargin < 2
    unit = 'nm';
end
switch upper(unit)
    case 'NM'
        mw = 2/3*log10(mo)-6.033;
    case 'DCM'
        mw = 2/3*log10(mo)-10.7;
end
