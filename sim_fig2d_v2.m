function [X,Y,slip,offx,offy] = sim_fig2d_v2(fpara,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
   %
   % ncl is colormap, like 'jet'
   % lwid is the width of the quiver, arrow
   % acl  is the color of the quiver, arrow
   % polygon is another region on the planet.
   % isquiver, a signal, 1 is true, to plot; 0 is no, don't plot.
   % 
   % Revised history:
   %     Writen by Feng W.P, at 2008-07-05
   %     added the some documents by Feng W.P, at 2008-07-19
  if nargin<1
     disp('sim_fig2d(fpara,ncl,lwid,acl,polygon,isquiver,qlen,conWid,conCol,crange,vector)');
     disp('new version: sim_fig2d(fpara,varargin);');
     return
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  load mycolor.mat
  ncl      = mycolor;
  lwid     = 0.8;
  acl      = 'k';
  polygon  = [];
  isquiver = 1;
  qlen     = 0.8;
  conWid   = 0.7;
  conCol   = 'r';
  crange   = [];
  vector   = 0.2:0.2:10;
  istitile = 0;
  iscolor  = 1;
  sliptype = 'syn';
  isnoline = 0;
  xytype   = 1;
  colorbarloc = 1;
  modeltype   = 'fpara';
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for ni = 1:2:numel(varargin)
      para = varargin{ni};
      val  = varargin{ni+1};
      eval([para,'=',val,';']);
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %