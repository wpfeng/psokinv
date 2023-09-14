function sim_simp2xyz(insimp,outxyz)
%
%
%
[fpara,zone] = sim_openfault(insimp);
%
fid = fopen(outxyz,'w');
%
for i = 1:size(fpara,1)
    %
    cfpara = fpara(i,:);
    %[x,y,z] = sim_fpara2corners(cfpara);
    %disp([x,y,z]);
    disp(cfpara);
    polys = sim_fpara2allcors(cfpara);
    %
    polys = [polys(1:4,:);polys(1,:)];
    % plot3(polys(:,1),polys(:,2),polys(:,3));
    [lats,lons] = utm2deg(polys(:,1).*1000,polys(:,2).*1000,zone);
    %
    slip = sqrt(cfpara(8)^2+cfpara(9)^2);
    %
    fprintf(fid,'> -Z%f\n', slip);
    for j = 1:5
       fprintf(fid,'%15.8f %15.8f %15.8f\n',lons(j),lats(j),polys(j,3));
    end
end
fclose(fid);