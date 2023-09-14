function green = sim_oksargreenRAKE(fpara,input,thd,alp,rake)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 %
 %format long
 x = input(:,1);
 y = input(:,2);
 %
 ndim   = size(fpara,1);
 nraw   = size(x,1);
 %
 sgreen = zeros(nraw,ndim);
 dgreen = sgreen;
 %
 for nd = 1:ndim
     fpara(nd,8) = 1;
     fpara(nd,9) = 0;
     fpara(nd,10)= 0;
     dis         = multiokadaALP(fpara(nd,:),x,y,0,alp,thd);
     sim         = dis.E.*input(:,4)+dis.N.*input(:,5)+dis.V.*input(:,6);
     sgreen(:,nd)= sim;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     fpara(nd,8) = 0;
     fpara(nd,9) = 1;
     dis         = multiokadaALP(fpara(nd,:),x,y,0,alp,thd);
     sim         = dis.E.*input(:,4)+dis.N.*input(:,5)+dis.V.*input(:,6);
     dgreen(:,nd)= sim;
 end
 green = [sgreen.*cosd(rake)+dgreen.*sind(rake)];
 
 
 
