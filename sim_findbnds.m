function bndindex = sim_findbnds(cx,cy)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 ind1 = find(cx==min(cx(:)));
 ind2 = find(cx==max(cy(:)));
 ind3 = find(cy==max(cy(:)));
 ind4 = find(cy==min(cy(:)));
 bndindex = [ind1;ind2;ind3;ind4];
 bndindex = unique(bndindex);
 
