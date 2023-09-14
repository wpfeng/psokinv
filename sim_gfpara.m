function fpara = sim_gfpara(varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
% + Input:
%
% + Ouput:
%
% + Log:
%   Created by Feng, W.P.,@ GU, 2013-02-12
%
%
xyloc  = [0,0];
strike = 45;
dip    = 45;
rake   = 45;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v = sim_varmag(varargin);
for j = 1:length(v)
    eval(v{j});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
