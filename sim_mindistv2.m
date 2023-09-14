function mindist = sim_mindistv2(p)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % return the min distance from a set of points.
 % Created by Feng Wanpeng based on www.mathwork.com.
 tri        = delaunay(p(:,1),p(:,2));
 d2fun      = @(k,l) sum((p(k,:)-p(l,:)).^2,2);
 d2tri      = @(k) [d2fun(tri(k,1),tri(k,2)) ...
              d2fun(tri(k,2),tri(k,3)) ...
              d2fun(tri(k,3),tri(k,1))];
 dtri       = cell2mat(arrayfun(@(k) d2tri(k),...
              (1:size(tri,1))','UniformOutput',0));
 mindist    = sqrt(min(dtri(:))); 
