%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
file = dir('*.m');
for ni = 1:numel(file)
    disp(file(ni).name);
    pcode(file(ni).name);
end
