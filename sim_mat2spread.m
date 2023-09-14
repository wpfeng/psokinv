function v = sim_mat2spread(mtr)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
I = eye(size(mtr));
v = mtr-I;
v = sum(v(:).^2);
