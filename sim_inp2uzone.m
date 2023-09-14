function uzone = sim_inp2uzone(inname)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng,W.P., @ GU, 2012-09-26
%
uzone        = [];
[t_mp,bname] = fileparts(inname);
%
temp      = textscan(bname,'%s','delimiter','_');
temp      = temp{1};
%
for ni = 1:numel(temp)
    %
    if strcmpi(temp{ni},'utm') == 1
        if ni+1<=numel(temp)
            uzone = temp{ni+1};
        end
    end
end
