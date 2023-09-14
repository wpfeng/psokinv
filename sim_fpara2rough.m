function [rough,maxr,lap] = sim_fpara2rough(fpara,depthd)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Created by FWP, @ UoG, 2013-04-22
 %
 if nargin < 2 || isempty(depthd)==1
     depthd = 50;
 end
 lap   = sim_fpara2lapv2(fpara);
 index = find(fpara(:,5)./sind(fpara(:,4)) <=depthd);
 slip  = [fpara(:,8);fpara(:,9)];
 roug  = abs([lap lap.*0;lap.*0 lap]*slip);
 rough = sum(roug(index)/4)/numel(roug(:));
 maxr  = max(roug(index));
