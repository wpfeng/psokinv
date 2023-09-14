function [shear,normals,col] = sim_fpara4col3d(fpara,x,y,z,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% + Purpose:
%    calculate the stress change from fpara directly due to the coordinates
%    you give
% + Input:
%    fpara, the fault parameters 
%        x, the coordinates of x, in km
%        y, the coordinates of y, in km
%        z, the coordinates of z, in km
%    varargin, the many other parameters
%    strike, the optimal strike angle
%       dip, the optimal dip angle
%      rake, the optimal rupture rake angle
%...
% + Modified History:
%   Created by Feng,W.P., 2011/10/14, @UoG
%   wanpeng.feng@hotmail.com; w.feng.1@research.gla.ac.uk
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
strike   = 180;
dip      = 89.9;
rake     = 0;
friction = 0.5;
display  = 0;
alpha    = 2/3;
young    = double(800000);
pois     = 0.25;
thd      = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ni=1:2:numel(varargin)
    %
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
    %
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[cm,cn] = size(x);
x       = x(:);
y       = y(:);
z       = z(:);
dis = multiokada3Dstress(fpara,x,y,z,strike,dip,rake,friction,...
                                   display,alpha,young,pois,thd);
%
%
%
%
shear   = reshape(dis.shear,  cm,cn);
normals = reshape(dis.normal, cm,cn);
col     = reshape(dis.coulomb,cm,cn);
