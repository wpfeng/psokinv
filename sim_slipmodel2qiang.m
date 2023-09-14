function sim_slipmodel2qiang(insimp,outnewsimp,outmode)
%
% Developed Wanpeng Feng, @NRCan, 2015-11-26
%
%
[fpara,zone] = sim_simp2fpara(insimp);
%
rakes = sim_calrake(fpara,0);
%
if outmode == 3
   fpara = sim_fparaconv(fpara,0,3);
end
if outmode == 1
    fpara = sim_fparaconv(fpara,0,1);
end
[lat,lon] = utm2deg(fpara(:,1).*1000,fpara(:,2).*1000,zone);
%
sfpara      = fpara(:,2).*0;
sfpara(:,1) = lon;
sfpara(:,2) = lat;
sfpara(:,3) = fpara(:,7);
sfpara(:,4) = fpara(:,6);
sfpara(:,5) = fpara(:,5);
sfpara(:,6) = fpara(:,3);
sfpara(:,7) = fpara(:,4);
sfpara(:,8) = rakes;
sfpara(:,9) = sqrt(fpara(:,8).^2+fpara(:,9).^2);
fid = fopen(outnewsimp,'w');
fprintf(fid,'%s\n','#Lon    Lat   Length(Km)  Width(Km)   Depth(Km)   Strike  Dip  Rake  Slip(m) ');
fprintf(fid,'%f %f %f %f %f %f %f %f %f\n',sfpara');
fclose(fid);
%