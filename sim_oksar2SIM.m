 function [cfpara,utmzone] = sim_oksar2SIM(inpf)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % inpf, top and bot should represent the depth along the vertical direction.
 %       in PSOKSAR format.
 % Wrote by Feng W.P, 27 July 2009
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Revised by Feng, W.P, 2010-10-14
 % -> working for new definition of OKSAR
 % -> positive along left lateral 
 % Updated by Feng, W.P., @ GU, 2012-08-10
 % -> update the oksar structure and add a new parameter of UTMzone.
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %
 if ~exist(inpf,'file')
     disp(['OksarFILE: ',inpf,' doesnot exist...']);
     %cfpara,utmzone
     cfpara = [];
     utmzone = [];
     return
 end
 %
 [xlim,ylim,lamd,vect,cxy,focal,slip,fgeo,k] = sim_input2li(inpf);
 %
 fpara = zeros(k,10);
 %
 for ni=1:k
     delLEN      = fgeo(ni,2).*cosd(focal(ni,2));
     delx        = delLEN * sind(focal(ni,1) + 90 ) ;
     dely        = delLEN * cosd(focal(ni,1) + 90 ) ;
     fpara(ni,1) = cxy(ni,1)/1000 + delx;
     fpara(ni,2) = cxy(ni,2)/1000 + dely;
     fpara(ni,3) = focal(ni,1);
     fpara(ni,4) = focal(ni,2);
     fpara(ni,5) = fgeo(ni,2).*sind(focal(ni,2));
     fpara(ni,6) = (fgeo(ni,3)-fgeo(ni,2));%/sind(focal(ni,2));
     fpara(ni,7) = fgeo(ni,1);
     % positive along left lateral 
     % disp(focal(ni,3))
     fpara(ni,8) = slip(ni,1)* cosd(focal(ni,3));
     fpara(ni,9) = slip(ni,1)* sind(focal(ni,3));
     fpara(ni,10)= slip(ni,2);
     %fpara(ni,:) = sim_cc2uc(fpara(ni,:));
 end
 % if the two patch is one, join them.
 fpara(isnan(fpara(:,1)),:) = [];
 %
 %
 number = size(fpara,1);
 cfpara = zeros(1,10);
 counter = 0;
 % updated by fWP, @ IGPP of SIO, 2013-10-16
 %
 while number > 0
     counter = counter + 1;
     %thed = fpara(1,6);
     dist = sqrt((fpara(1,1) - fpara(:,1)).^2 + (fpara(1,2)-fpara(:,2)).^2 + ...;
                 (fpara(1,5) - fpara(:,5)).^2 + ...
                 (fpara(1,3) - fpara(:,3)).^2 + ...);
                 (fpara(1,4) - fpara(:,4)).^2);
     %       
     index= find(dist <= 10e-8);
     %disp(dist(index(:))');
     %whos index
     cfpara(counter,:)     = fpara(index(1),:);
     cfpara(counter, 8:10) = 0;
     for ni=1:numel(index)
         cfpara(counter, 8  ) = fpara(index(ni),8)  + cfpara(counter, 8);
         cfpara(counter, 9  ) = fpara(index(ni),9)  + cfpara(counter, 9);
         cfpara(counter, 10 ) = fpara(index(ni),10) + cfpara(counter, 10);
     end
     fpara(index,:) = [];
     number = size(fpara,1);
 end
 %
 utmzone = sim_oksar2utm(inpf);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %
 
 
 
