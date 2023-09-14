%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% newlist=remove(list,entry);
%
function newlist=remove(list,entry)
newlist = list;
for ni=numel(entry)
 newlist=newlist(find(newlist-entry(ni)*ones(size(list))));
end
