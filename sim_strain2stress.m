function sout = sim_strain2stress(UXX,UYY,UZZ,...
                                  UYX,UZX,UXZ,...
                                  UYZ,UXY,UZY,YOUNG,POIS)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
                                  
%  Convert the strain tensor to stress tensor
%
%  INPUT:  strain,YOUNG,POIS
%          YOUNG, young's constant in the crustal
%          POIS,  poisson's constant in the crustal
%          [XX,YY,ZZ,UXY,UYX,UXZ,UYZ,UYZ,UZY].
%          --> sxx,syy,szz,syz,sxz,sxy
%  OUTPUT: sout,(6*nn) matix: newly calculated stress tensor with
%          horizontal rotation (not plunge change)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified from tensor_trans (in coulomb3.0)
% Changed by Feng W.P, 2010-04-14
%
% 
sk  = YOUNG/(1.0+POIS);
gk  = POIS/(1.0-2.0*POIS);
vol = UXX + UYY + UZZ;
%
sxx = sk * (gk * vol + UXX) * 0.001;
syy = sk * (gk * vol + UYY) * 0.001;
szz = sk * (gk * vol + UZZ) * 0.001;
sxy = (YOUNG/(2.0*(1.0+POIS))) * (UXY + UYX) * 0.001;
sxz = (YOUNG/(2.0*(1.0+POIS))) * (UXZ + UZX) * 0.001;
syz = (YOUNG/(2.0*(1.0+POIS))) * (UYZ + UZY) * 0.001;
% 
sout= [sxx(:)';syy(:)';szz(:)';sxy(:)';sxz(:)';syz(:)'];
