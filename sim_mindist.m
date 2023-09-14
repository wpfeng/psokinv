function dmin = sim_mindist(x,y,preset)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Developed by FWP,@BJ, 2010-01-01
 %
 if nargin<3 || isempty(preset)==1
    preset = 0.1; 
 end
 if numel(x(:))>4
     p   = [x(:) y(:)];
     TRI = delaunay(x,y);
     %
     tri = TRI(:,[1:end 1]);
     dx  = diff(reshape(p(tri,1),size(tri)),1,2);
     dy  = diff(reshape(p(tri,2),size(tri)),1,2);
     dmin = sqrt(min(dx(:).^2+dy(:).^2));
 else
     dmin = preset;
 end
