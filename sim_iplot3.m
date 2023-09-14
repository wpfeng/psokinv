function sim_iplot3(x,y,z,msize)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
for ni=1:size(x,1)
    plot3(x(ni),y(ni),z(ni),'or',...
         'MarkerFaceColor','y','MarkerSize',msize(ni));
    hold on
end
