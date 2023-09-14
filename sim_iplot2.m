function sim_iplot2(x,y,msize,color)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
if nargin < 4
    color = [1,0,0];
end
for ni=1:size(x,1)
    hold on
    plot(x(ni),y(ni),'o','Color',color,...
         'MarkerFaceColor','k','MarkerSize',msize(ni));
    hold on
end
