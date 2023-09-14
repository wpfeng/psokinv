 function fpara = sim_psoksar2SIM(inpf)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % inpf, top and bot should represent the depth along the vertical direction.
 %       in PSOKSAR format.
 % Wrote by Feng W.P, 27 July 2009
 %
 %
 [xlim,ylim,lamd,vect,cxy,focal,slip,fgeo,k] = sim_input2li(inpf);
 %
 fpara = zeros(k,10);
 for ni = 1:k
     fpara(ni,1) = cxy(ni,1)/1000;
     fpara(ni,2) = cxy(ni,2)/1000;
     fpara(ni,3) = focal(ni,1);
     fpara(ni,4) = focal(ni,2);
     fpara(ni,5) = fgeo(ni,2);
     fpara(ni,6) = (fgeo(ni,3)-fgeo(ni,2))/sind(focal(ni,2));
     fpara(ni,7) = fgeo(ni,1);
     fpara(ni,8) = slip(ni,1)*cosd(focal(ni,3));
     fpara(ni,9) = slip(ni,1)*sind(focal(ni,3));
     fpara(ni,10)= slip(ni,2);
     fpara(ni,:) = sim_cc2uc(fpara(ni,:));
 end
 
 
