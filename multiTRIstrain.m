function [U,stress] = multiTRIstrain(trif,x,y,z,pr,lambda,mu)
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
 if nargin < 6
    lambda = 3.2e2;
 end
 if nargin < 7
    mu = lambda;
 end
 %
 XX = zeros(size(x(:),1),1);
 YY = XX;
 ZZ = XX;
 XY = XX;
 XZ = XX;
 YZ = XX;
 %
 parfor ni=1:numel(trif)
     temp = CalcTriStrains( x, y, z, trif(ni).x, trif(ni).y, abs(trif(ni).z),pr,...
             trif(ni).ss,trif(ni).ts, trif(ni).ds);
     XX = XX + temp.xx;
     YY = YY + temp.yy;
     ZZ = ZZ + temp.zz;
     XY = XY + temp.xy;
     XZ = XZ + temp.xz;
     YZ = YZ + temp.yz;
 end
 U.xx  = XX;
 U.yy  = YY;
 U.zz  = ZZ;
 U.xy  = XY;
 U.xz  = XZ;
 U.yz  = YZ;
 stress = StrainToStress(U, lambda, mu);
 stress.sxx = stress.sxx.*-1;
 stress.syy = stress.syy.*-1;
 stress.sxy = stress.sxy.*-1;
 stress.szz = stress.szz.*-1;
 %stress.yz = stress.yz;
 %stress.xx = stress.xx.*-1;
 
