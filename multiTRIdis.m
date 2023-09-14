function U = multiTRIdis(trif,x,y,z,pr)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % +Usage: 
 %        U = multiTRIdis(trif,x,y,z[,pr]);
 % +Input:
 %       trif, the model in triangular model
 %          x, the x coordinates of observation points in km
 %          y, the y coordinates of observation points in km
 %          z, the z coordinates of observation points in km
 %         pr, the possion ration
 % +Output:
 %          U, a structure saving the deformation at the points of (x,y,z)
 % Created by Feng, W.P, fengwp@cea-igp.ac.cn
 % Version 0.1, 2010-08-10, in Beijing
 %
 if nargin < 5
     pr = 0.25;
 end
 %
 U.x  = zeros(size(x));
 U.y  = zeros(size(x));
 U.z  = zeros(size(x));
 E    = U.x;
 N    = E;
 Z    = E;
 %
 parfor ni=1:numel(trif)
     temp = CalcTriDisps( x, y, z, trif(ni).x, trif(ni).y, abs(trif(ni).z),pr,...
             trif(ni).ss,trif(ni).ts, trif(ni).ds);
     E = E + temp.x.*-1;
     N = N + temp.y.*-1;
     Z = Z + temp.z;
     disp(['Now the ' num2str(ni) ' TRIF model has been calculated..']);
 end
 U.x  = E;
 U.y  = N;
 U.z  = Z;
