function sim_edgrn(edgrninp)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% edgrn inp 
% Modified by FWP, @ GU, 2013-05-14
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if nargin < 1
%     layermodel = [];
% end
% if nargin < 2
%    obsdepth = 0;
% end
if exist('edgrnfcts','dir')==0
    mkdir('edgrnfcts');
end
%sim_edgrninp('EDGRN06.inp',layermodel,obsdepth);
dos(['echo ' edgrninp,' | edgrn2']);
%
