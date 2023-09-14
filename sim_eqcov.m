function out = sim_eqcov(inp,type)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% inp, a input value
% type, two choices: moment, the size of earthquake in terms of energy
%                    released; 
%                    magnitude scale, like mw, another type for earthquake
%                    size;
%       there is following formulation for the relation between moment and mw.
%       mw = (2/3)*log10(moment)-6.033;
%       the type will tell that fuction should return which value.
% & & % % $ $ & & 
% Created by Feng Wanpeng, 2010-03-18
%
if nargin<2
   type = 'mw';
end
switch type 
    case 'moment'
        out = 10^((inp+6.033)*3/2);
    case 'mw'
        out = (2/3)*log10(inp)-6.033;
    otherwise
        out = [];
        disp('You must give a proper "type": mw or moment');
        return
end
