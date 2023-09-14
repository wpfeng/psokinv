function sim_fpara2topcenter(insimp)
%
% return top-center of fault trace based on a SIMP fault format
% created by FWP, @SYSU, Guangzhou, 2021/09/11
% 
[fpara,zone] = sim_openfault(insimp);
%
topfpara = sim_fpara2dist(fpara,fpara(7),fpara(6),fpara(7),fpara(6),'d',0);
topfpara(8) = fpara(8)*2;
%
[x,y,z] = sim_fpara2corners(topfpara,'uc');
%
%
[lat,lon] = utm2deg(x*1000,y*1000,zone);
%
disp([lon,lat])
%
sim_fig3d([fpara;topfpara]);
hold on
plot3(x,y,z*-1,'oc','MarkerSize',15);