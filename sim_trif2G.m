function [Gs,Gd,Gt,G] = sim_trif2G(trif,input,pr)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % +Name:
 %      [Gs,Gd,Gt,G] = sim_tri2G(trif,input,pr);
 % +Input:
 %      trif, the fault model with triangle dislocation
 %      input,N*7,n observation points
 %      pr,   possion's ratio, default value, 0.25
 % +Output:
 %      Gs,   the Green matrix by 1m strile-slip.
 %      Gd,   the Green matrix by 1m dip-slip.
 %      Gt,   the Green matrix by 1m tensil-slip.
 %      G,    [Gs Gd]
 % Created by Feng W.P, IGP/CEA, 2009/11/04
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % FWP, 2010/11/15, adding rake constraints
 %
 global rakecons
 %
 if size(rakecons,1) == 0
     rakecons = [0,0,90];
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if nargin < 3
    pr = 0.25;
 end
 %%%%%%%%%%%%%%%%%%%
 ntri = numel(trif);
 Gs   = zeros(numel(input(:,1)),ntri);
 Gd   = Gs;
 Gt   = Gs;
 x    = input(:,1);
 y    = input(:,2);
 z    = input(:,1).*0;
 %
 if rakecons(1) ~= 0
    rake1 = rakecons(1,2);
    rake2 = rakecons(1,3);
 else
    rake1 = 0;
    rake2 = 90;
 end
 s_slips1 = 1*cosd(rake1);
 d_slips1 = 1*sind(rake1);
 s_slips2 = 1*cosd(rake2);
 d_slips2 = 1*sind(rake2);
 %
 E_rot    = input(:,4);
 N_rot    = input(:,5);
 V_rot    = input(:,6);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 parfor ni=1:ntri
     % Green matrix by 1m strike slip displacement
     %
     U = CalcTriDisps(x,y,z,trif(ni).x,trif(ni).y,trif(ni).z.*-1,pr,...
                      s_slips1,0,d_slips1);
     Gs(:,ni) = U.x.*E_rot.*-1+U.y.*N_rot.*-1+U.z.*V_rot;
    
     % Green matrix by 1m tensil slip displacement
     U = CalcTriDisps(x,y,z,trif(ni).x,trif(ni).y,trif(ni).z.*-1,pr,...
                      0,1,0);
     Gt(:,ni) = U.x.*E_rot.*-1+U.y.*N_rot.*-1+U.z.*V_rot;
     % Green matrix by 1m dip slip displacement
     U = CalcTriDisps(x,y,z,trif(ni).x,trif(ni).y,trif(ni).z.*-1,pr,...
                      s_slips2,0,d_slips2);
     Gd(:,ni) = U.x.*E_rot.*-1+U.y.*N_rot.*-1+U.z.*V_rot;
 end
 G = [Gs Gd];
