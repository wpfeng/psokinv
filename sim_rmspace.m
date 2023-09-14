function stringout=sim_rmspace(stringin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Purpose:
 %        To remove all blank in a string.
 % The Author, Shi Yuzhen && Feng Wanpeng, IAP & IGP
 % Release time: 2007/05/08
 
 indspace=strfind(stringin,' ');
 if isempty(indspace)==1
     stringout=stringin;
 elseif isempty(indspace)==0
     num=size(indspace,2);
     if num==1 
        stringout=[stringin(1:indspace-1),stringin(indspace+1:length(stringin))];
     elseif num >1
        temp=stringin(1:indspace(1)-1);
        for i=2:num
            temp=[temp,stringin(indspace(i-1)+1:indspace(i)-1)];
        end
        stringout=[temp,stringin(indspace(num)+1:length(stringin))];
     end
 end
