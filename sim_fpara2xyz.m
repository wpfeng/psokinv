function sim_fpara2xyz(fpara,zone,outxyz,factor)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng, W.P., @ BJ, 2009/11/01
%
% [fpara,zone] = sim_openfault(insimp);
%
%
fid = fopen(outxyz,'w');
%
for i = 1:size(fpara,1)
    %
    cfpara = fpara(i,:);
    %[x,y,z] = sim_fpara2corners(cfpara);
    %disp([x,y,z]);
    polys = sim_fpara2allcors(cfpara);
    %
    polys = [polys(1:4,:);polys(1,:)];
    % plot3(polys(:,1),polys(:,2),polys(:,3));
    [lats,lons] = utm2deg(polys(:,1).*1000,polys(:,2).*1000,zone);
    %
    slip = sqrt(cfpara(8)^2+cfpara(9)^2);
    %
    % factor can be 1 or -1.
    %
    polys(:,3) = polys(:,3) * factor;
    %
    %
    fprintf(fid,'> -Z%f\n', slip);
    for j = 1:5
       fprintf(fid,'%15.8f %15.8f %15.8f\n',lons(j),lats(j),polys(j,3));
    end
end
fclose(fid);