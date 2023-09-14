function [shear_s,normal_s,coulomb_s] = sim_stress2coulomb(strike,dip,rake,friction,ss)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Usage:
 %      It should be faster than calc_coulomb.m in coulomb3.1 pacakge...
 %      And I have checked the result with coulomb3.1 which are consistent....
 %      [shear_s,normal_s,coulomb_s] = sim_stress2coulomb(strike,dip,rake,friction,ss)
 % Input:
 %      strike, in degree, clockwise rotation, zero with North
 %         dip, in degree, anti-clockwise rotation
 %        rake, in degree, anti-clockwise rotation, zero with x direction
 %    friction, the force that opposes the movement of two bodies in contact as they move relative to each other
 %          ss, the stress tensor with 6*n, n is of number of the observation points. 6 are following lists: sxx,syy,szz,sxy,sxz,syz
 % Output:
 %     shear_s, the shear stress in the rake direction...
 %    normal_s, the normal stress with the perpendicular direction with the fault plane.
 %    columb_s, the statics value with coulomb = shear + friction *normal.(Compressive normal stress is defined with negtive value)
 % Log:
 % Created by Feng, W.P, IGP-CEA, 2010-09-17
 %    -> use cosine rotation matrix to realize quick rotation...
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 dstrike   = deg2rad(90-strike);
 ddip      = deg2rad(dip);
 drake     = deg2rad(rake);
 npoints   = size(ss,2);
 shear_s   = zeros(npoints,1);
 normal_s  = zeros(npoints,1);
 coulomb_s = zeros(npoints,1);
 %
 % remove dependencies on the latest matlab
 % an external version of angle2dcm has been ready in the current version...
 % 
 rotax_1   = psokinvangle2dcm(dstrike,0,ddip);
 rotax_3   = psokinvangle2dcm(drake,0,0);
 %
 for ni = 1:size(ss,2)
     cs      = ss(:,ni);
     stensor = [cs(1),cs(4),cs(5);...
                cs(4),cs(2),cs(6);...
                cs(5),cs(6),cs(3)];
     % gtensor = tensor * rotm * tensor';
     rcs     = rotax_1*stensor*rotax_1';
     ecs          = rotax_3*rcs*rotax_3';
     shear_s(ni)  = ecs(3,1); %+ecs(1,1); deta(xz)
     normal_s(ni) = ecs(3,3); %           deta(zz)
     coulomb_s(ni)= shear_s(ni) + normal_s(ni)*friction;
 end
