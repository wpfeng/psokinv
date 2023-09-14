function [lens,wids] = sim_mw2length(mw,slip)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************

% log10Lsr ¼ 3:55 þ 0:74  Mw
% Created by Feng, W.P., 2011/10/23
%
%
mu   = 3.23e10;
%
if nargin < 2
    slip = 2.0;
end
%
lens = 10^(0.75*mw-3.55);
%
wids = 10^(mw+6.033)*3/2/mu/lens/slip;
