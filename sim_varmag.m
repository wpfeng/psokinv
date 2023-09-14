function v = sim_varmag(pairs)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%%%
% +Name: 
%      sim_varmag, varible manager
% +Purpose:
%      helper function allowing named generic name value parameter passing
% History:
%      Modified by Feng W.P from Googleearth toolsbox...
%

v = {}; 

for ii=1:2:length(pairs(:))
    %
    if isnumeric(pairs{ii+1})
        str = [ pairs{ii} ' = [' num2str(pairs{ii+1}),'];'  ];
    else
        str = [ pairs{ii} ' = ' 39 pairs{ii+1} 39,';'  ];
    end
    v{(ii+1)/2,1} = str;
    %
end
