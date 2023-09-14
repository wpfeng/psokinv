function [x00,y00] = sim_fpara2coulomb(fpara,zone,coulombfile,refxy)
%
%
% Created by Feng W.P, IGP-CEA&&GLU, 2009/08
% Modified by Feng W.P, IGP-CEA
% Coulomb 3.1 defines the right-lateral slip is positive...
% Modified by fWP, @UoG, 2014-02-04
% change cll to zone...
%
if nargin<1
    disp('sim_fpara2coulomb(fpara,zone,colmbfile)');
    disp(' >>>>> fpara, the faults model in PSOKINV');
    disp(' >>>>> cll,   the reference points, e.g [lon,lat]');
    disp(' >>>>> coulombfile, the output file');
    %
    return
end
if nargin<2 || isempty(zone) ==1
    disp('You must give a referenced point in degree...');
    return
end
if nargin<3 ||  isempty(coulombfile)==1
    %
    coulombfile = 'CLMB_testing01.inp';
end
%fpara = sim_psoksar2SIM(oksar);
%
fid = fopen(coulombfile,'w');
fprintf(fid,'%s\n','PSOKINV5.0 Distributed-SLip Model into Coulomb 3.1');
fprintf(fid,'%s\n','The fault Parameters from PSOKINV' );
%%%%%%%%%%%
nf = size(fpara,1);
%%%%%%%%%%%%%%%
fprintf(fid,'%s\n',['#reg1=  0  #reg2=  0   #fixed=  ' num2str(nf) '  sym=  1']);
fprintf(fid,'%s\n',' PR1=       .250      PR2=       .250    DEPTH=        0.');
fprintf(fid,'%s\n','  E1=   0.800000E+06   E2=   0.800000E+06');
fprintf(fid,'%s\n','XSYM=       .000     YSYM=       .000');
fprintf(fid,'%s\n','FRIC=       .800');
fprintf(fid,'%s\n','S1DR=    24.0001     S1DP=      0.0001    S1IN=    100.000     S1GD=   .000000');
fprintf(fid,'%s\n','S3DR=   114.0001     S3DP=      0.0001    S3IN=     30.000     S3GD=   .000000');
fprintf(fid,'%s\n','S2DR=    89.9999     S2DP=     -89.999    S2IN=      0.000     S2GD=   .000000');
%%%%%%%%%%%
fprintf(fid,'%s\n','  #   X-start    Y-start     X-fin      Y-fin   Kode  rt.lat    reverse   dip angle     top      bot');
fprintf(fid,'%s\n','xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx');

%%%%%%%%%%%%%%%%%%%%%%%%%
%[x0,y0,zone] = deg2utm(cll(2),cll(1));
%zone
%%%%%%%%%%%%%%%%%%%%%%%%%
for ni = 1:nf
    cfpara = fpara(ni,:);
    [x1,y1,z1]= sim_fpara2corners(cfpara,'ul');
    if ni ==1
        if nargin < 4
            x00 = x1;
            y00 = y1;
        else
            x00 = refxy(1);
            y00 = refxy(2);
        end
        [lat0,lon0] = utm2deg(x00*1000,y00*1000,zone);
    end
    [x2,y2,z2]= sim_fpara2corners(cfpara,'ur');
    [x3,y3,z3]= sim_fpara2corners(cfpara,'lr');
    fprintf(fid,'%3.0f %10.3f %10.3f %10.3f %10.3f%4.0d %10.3f %10.3f %10.2f %10.2f %5.2f %10s\n',...
        1,   x1-x00,   y1-y00,    x2-x00,   y2-y00,   100, -1*cfpara(8), cfpara(9), cfpara(4),z2, z3,['fault-' num2str(ni)]);
end
fprintf(fid,'%s\n','');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minx = min(fpara(:,1))-20;
miny = min(fpara(:,2))-20;
maxx = max(fpara(:,1))+20;
maxy = max(fpara(:,2))+20;
[minlat,minlon] = utm2deg(minx*1000,miny*1000,zone);
[maxlat,maxlon] = utm2deg(maxx*1000,maxy*1000,zone);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'%s\n','     Grid Parameters');
fprintf(fid,'%s\n',['  1  ----------------------------  Start-x =    ' num2str(minx-x00)]);
fprintf(fid,'%s\n',['  2  ----------------------------  Start-y =    ' num2str(miny-y00)]);
fprintf(fid,'%s\n',['  3  --------------------------   Finish-x =    ' num2str(maxx-x00)]);
fprintf(fid,'%s\n',['  4  --------------------------   Finish-y =    ' num2str(maxy-y00)]);
fprintf(fid,'%s\n',['  5  ------------------------  x-increment =    ' num2str(2)]);
fprintf(fid,'%s\n',['  6  ------------------------  y-increment =    ' num2str(2)]);
fprintf(fid,'%s\n','     Size Parameters');
fprintf(fid,'%s\n','  1  --------------------------  Plot size =        1.0000000');
fprintf(fid,'%s\n','  2  --------------  Shade/Color increment =        0.2000000');
fprintf(fid,'%s\n','  3  ------  Exaggeration for disp.& dist. =    10000.0000000');
fprintf(fid,'%s\n','Cross section default');
fprintf(fid,'%s\n',['  1  ----------------------------  Start-x =    ' num2str(minx)]);
fprintf(fid,'%s\n',['  2  ----------------------------  Start-y =    ' num2str(miny)]);
fprintf(fid,'%s\n',['  3  --------------------------   Finish-x =    ' num2str(maxx)]);
fprintf(fid,'%s\n',['  4  --------------------------   Finish-y =    ' num2str(maxy)]);
fprintf(fid,'%s\n','  5  ------------------  Distant-increment =     2.000000');
fprintf(fid,'%s\n','  6  ----------------------------  Z-depth =     30.00000');
fprintf(fid,'%s\n','  7  ------------------------  Z-increment =     1.000000');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'%s\n','     Map infomation');
fprintf(fid,'%s\n',['  1  ---------------------------- min. lon =    ' num2str(minlon)]);
fprintf(fid,'%s\n',['  2  ---------------------------- max. lon =    ' num2str(maxlon)]);
fprintf(fid,'%s\n',['  3  ---------------------------- zero lon =    ' num2str(lon0)]);
fprintf(fid,'%s\n',['  4  ---------------------------- min. lat =    ' num2str(minlat)]);
fprintf(fid,'%s\n',['  5  ---------------------------- max. lat =    ' num2str(maxlat)]);
fprintf(fid,'%s\n',['  6  ---------------------------- zero lat =    ' num2str(lat0)]);
fclose(fid);
