function sim_pscmpinp(varargin)
%
%
% +Purpose:
%     Created input file for pscmp which will be used to simulate coseismic
%     or postseismic deformation using Wang's codes...
% +Input:
%     isgr, flag to calculate the gravity changes, 1:yes,0:no, 0 in default.
%     istile, the same as the above, but for tilt component, 0 in default
%     isrot,  the same as the above, but for rotation, 0 in default
%     isxyz,  the same as the above, but for e/n/u deformation at given
%             depth, 1 in default
%     istress,the same as the above, but for stress computation, 0 in
%             default. Which is a matrix with 6 elements for different
%             component
%     fpara,  the fault model in PSOKINV format or a filename for oksar
%             file... if the subfaults over 1, I prefere to use oksar...
%     obsp,   the observation data. We must give a right file which is
%             saving all valid points we need in lonlat...[lon,lat]...
%     thre,   the threshold [1,1] for further oversampling fpara...
%     isove,  the flag for oversampling fpara data, 1:yes, 0:no. 1 in
%             default
%     outinp, the output configure file which will be used by pscmp...
%
% +REMINDER
%     We must provide a right oksar file, an observations file. For
%     example:
%     sim_pscmpinp('fpara',[fullpath of oksar
%                   file],'obsp',[fullpath of reference points], 'outinp','pscmp.inp');
%
%
% Created by Feng, W.P., @ GU, 2012-08-10
% Updated by FWP, @ Institute of Geophysics and Planetary Physics, SIO,
%                   University of California, San Diego, California, US.
%                   2013-10-05
%                   %increase the patches if the patch size is too big...
%
isxyz    = [1,1,1];
istress  = zeros(1,6);
%outdir   = pwd;
if isempty(strfind(computer,'WIN'))
    outdir = [pwd,'/pscmp/'];
else
    outdir = [pwd,'\pscmp\'];
end
greendir = '.\psgrnfcts\';
%
%
icmpflag   = [0 0.700 0.000 330.000 90.000 180.000 0.0E+00 0.0E+00 0.0E+00];
istilt     = [0,0];
isrot      = 0;
isgd       = 1;
isgr       = 0;
fpara    = rand(1,10);
utmproj  = [];
obstype  = 0;     
obsp     = rand(1000,2);
obsnum   = [10,1];
obsp_sta = rand(1,2);
obsp_x   = [0,1];
obsp_y   = [0,1];
isove    = 1;
thre     = [2,2];
event    = 'Feng W.P';
outinp   = 'pscmp_test.inp';
days     = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v = sim_varmag(varargin);
for j = 1:length(v)
    %disp(v);
    eval(v{j});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen(outinp,'w');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n','# This is input file of FORTRAN77 program "pscmp08" for modeling post-seismic');
fprintf(fid,'%s\n','# deformation induced by earthquakes in multi-layered viscoelastic media using');
fprintf(fid,'%s\n',['# the Green','''','s function approach. The earthquke source is represented by an']);
fprintf(fid,'%s\n','# arbitrary number of rectangular dislocation planes. For more details, please');
fprintf(fid,'%s\n','# read the accompanying READ.ME file.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# written by Rongjiang Wang');
fprintf(fid,'%s\n','# GeoForschungsZentrum Potsdam');
fprintf(fid,'%s\n','# e-mail: wang@gfz-potsdam.de');
fprintf(fid,'%s\n','# phone +49 331 2881209');
fprintf(fid,'%s\n','# fax +49 331 2881204');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# Last modified: Potsdam, July, 2008');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#################################################################');
fprintf(fid,'%s\n','##                                                             ##');
fprintf(fid,'%s\n',['## Green','''','s functions should have been prepared with the        ##']);
fprintf(fid,'%s\n','## program "psgrn08" before the program "pscmp08" is started.  ##');
fprintf(fid,'%s\n','##                                                             ##');
fprintf(fid,'%s\n',['## For local Cartesian coordinate system, the Aki','''','s convention ##']);
fprintf(fid,'%s\n','## is used, that is, x is northward, y is eastward, and z is   ##');
fprintf(fid,'%s\n','## downward.                                                   ##');
fprintf(fid,'%s\n','##                                                             ##');
fprintf(fid,'%s\n','## If not specified otherwise, SI Unit System is used overall! ##');
fprintf(fid,'%s\n','##                                                             ##');
fprintf(fid,'%s\n','#################################################################');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n','# OBSERVATION ARRAY');
fprintf(fid,'%s\n','# =================');
fprintf(fid,'%s\n','# 1. selection for irregular observation positions (= 0) or a 1D observation');
fprintf(fid,'%s\n','#    profile (= 1) or a rectangular 2D observation array (= 2): iposrec');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    IF (iposrec = 0 for irregular observation positions) THEN');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 2. number of positions: nrec');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 3. coordinates of the observations: (lat(i),lon(i)), i=1,nrec');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    ELSE IF (iposrec = 1 for regular 1D observation array) THEN');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 2. number of position samples of the profile: nrec');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 3. the start and end positions: (lat1,lon1), (lat2,lon2)');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    ELSE IF (iposrec = 2 for rectanglular 2D observation array) THEN');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 2. number of x samples, start and end values: nxrec, xrec1, xrec2');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 3. number of y samples, start and end values: nyrec, yrec1, yrec2');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    sequence of the positions in output data: lat(1),lon(1); ...; lat(nx),lon(1);');
fprintf(fid,'%s\n','#    lat(1),lon(2); ...; lat(nx),lon(2); ...; lat(1),lon(ny); ...; lat(nx),lon(ny).');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note that the total number of observation positions (nrec or nxrec*nyrec)');
fprintf(fid,'%s\n','#    should be <= NRECMAX (see pecglob.h)!');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%d\n',obstype);
%
%
%tmp = [];
switch obstype
    case 0
        if ischar(obsp)
            obsp = load(obsp);
        end
        %whos obsp
        fprintf(fid,'%d\n',numel(obsp(:,1)));
        for ni = 1:5:numel(obsp(:,1))
            tmp = sprintf('%s %7.4f %s %7.4f %s','(',obsp(ni,2),',',obsp(ni,1),')');
            for nj = 1:4
                if ni+nj <= numel(obsp(:,1))
                    ctmp = sprintf('%s %7.4f %s %7.4f %s','(',obsp(ni+nj,2),',',obsp(ni+nj,1),')');
                    tmp = [tmp,' ',ctmp];
                end
            end
            %
            
            %
            fprintf(fid,'%s\n',tmp);
            %
        end
    case 1
        fprintf(fid,'%d\n',obsnum);
        fprintf(fid,'%s\n',['(',num2str(obsp_sta(1)),',',num2str(obsp_sta(2)),'),',...
                            '(',num2str(obsp_end(1)),',',num2str(obsp_end(2)),')']);
    case 2
        %fprintf(fid,'%d\n',obsnum);
        fprintf(fid,'%d %f %f \n',obsnum(1),obsp_y);
        fprintf(fid,'%d %f %f \n',obsnum(2),obsp_x);
end
% fprintf(fid,'%s\n','  0');
% fprintf(fid,'%s\n','  180');
% fprintf(fid,'%s\n','#  1');
% fprintf(fid,'%s\n','#  51');
% fprintf(fid,'%s\n','#  (0.0, -100.0), (0.0, 400.0)0');
% fprintf(fid,'%s\n','#');
% fprintf(fid,'%s\n','#  2');
% fprintf(fid,'%s\n','# 101     30.59521  31.92271');
% fprintf(fid,'%s\n','# 101    103.49411 105.00661');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n','# OUTPUTS');
fprintf(fid,'%s\n','# =======');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 1. select (1/0) output for los displacement (only for snapshots, see below),');
fprintf(fid,'%s\n','#    x, y, and z-cosines to the INSAR orbit: insar, xlos, ylos, zlos');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    if this option is selected, the snapshots will include additional data:');
fprintf(fid,'%s\n','#    LOS_Dsp = los displacement to the given satellite orbit.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 2. select (1/0) output for Coulomb stress changes (only for snapshots, see');
fprintf(fid,'%s\n','#    below): icmb, friction, Skempton ratio, strike, dip, and rake angles [deg]');
fprintf(fid,'%s\n','#    describing the uniform regional master fault mechanism, the uniform regional');
fprintf(fid,'%s\n','#    principal stresses: sigma1, sigma2 and sigma3 [Pa] in arbitrary order (the');
fprintf(fid,'%s\n','#    orietation of the pre-stress field will be derived by assuming that the');
fprintf(fid,'%s\n','#    master fault is optimally oriented according to Coulomb failure criterion)');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    if this option is selected (icmb = 1), the snapshots will include additional');
fprintf(fid,'%s\n','#    data:');
fprintf(fid,'%s\n','#    CMB_Fix, Sig_Fix = Coulomb and normal stress changes on master fault;');
fprintf(fid,'%s\n','#    CMB_Op1/2, Sig_Op1/2 = Coulomb and normal stress changes on the two optimally');
fprintf(fid,'%s\n','#                       oriented faults;');
fprintf(fid,'%s\n','#    Str_Op1/2, Dip_Op1/2, Slp_Op1/2 = strike, dip and rake angles of the two');
fprintf(fid,'%s\n','#                       optimally oriented faults.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note: the 1. optimally orieted fault is the one closest to the master fault.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 3. output directory in char format: outdir');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 4. select outputs for displacement components (1/0 = yes/no): itout(i), i=1,3');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 5. the file names in char format for the x, y, and z components:');
fprintf(fid,'%s\n','#    toutfile(i), i=1,3');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 6. select outputs for stress components (1/0 = yes/no): itout(i), i=4,9');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 7. the file names in char format for the xx, yy, zz, xy, yz, and zx components:');
fprintf(fid,'%s\n','#    toutfile(i), i=4,9');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 8. select outputs for vertical NS and EW tilt components, block rotation, geoid');
fprintf(fid,'%s\n','#    and gravity changes (1/0 = yes/no): itout(i), i=10,14');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 9. the file names in char format for the NS tilt (positive if borehole top');
fprintf(fid,'%s\n','#    tilts to north), EW tilt (positive if borehole top tilts to east), block');
fprintf(fid,'%s\n','#    rotation (clockwise positive), geoid and gravity changes: toutfile(i), i=10,14');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note that all above outputs are time series with the time window as same');
fprintf(fid,'%s\n',['#    as used for the Green','''','s functions']);
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#10. number of scenario outputs ("snapshots": spatial distribution of all above');
fprintf(fid,'%s\n','#    observables at given time points; <= NSCENMAX (see pscglob.h): nsc');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#11. the time [day], and file name (in char format) for the 1. snapshot;');
fprintf(fid,'%s\n','#12. the time [day], and file name (in char format) for the 2. snapshot;');
fprintf(fid,'%s\n','#13. ...');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note that all file or directory names should not be longer than 80');
fprintf(fid,'%s\n','#    characters. Directories must be ended by / (unix) or \ (dos)!');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n',' 0    0.0  0.0  -1.00      !displacement upward positive');
%fprintf(fid,'%s\n',' 0     0.700  0.000  330.000   90.000  180.000    0.0E+00    0.0E+00    0.0E+00');
% 
fprintf(fid,'%d %f %f %f %f %f %f %f %f\n',...
            icmpflag);%0     0.700  0.000  330.000   90.000  180.000    0.0E+00    0.0E+00    0.0E+00');
%fprintf(fid,''.\'');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if ~exist(outdir,'dir')
    mkdir(outdir);
end
fprintf(fid,'%s\n',['''',outdir,'''']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
fprintf(fid,'%s\n',[num2str(isxyz(1)),' ',num2str(isxyz(2)),' ',num2str(isxyz(3))]);
fprintf(fid,'%s\n',['''',  'ux.dat' ,'''',' ', '''',  'uy.dat' ,'''',' ',''''   'uz.dat','''']);
fprintf(fid,'%s\n',[num2str(istress(1)),' ',num2str(istress(2)),' ',num2str(istress(3)),...
         ' ',num2str(istress(4)),' ',num2str(istress(5)),' ',num2str(istress(6))]);
%fprintf(fid,'%s\n','  0           0           0           0            0           0');
fprintf(fid,'%s\n',['''',  'sxx.dat','''',' ', '''',...
            'syy.dat','''',' ','''', 'szz.dat','''',...
            ' ','''','sxy.dat','''',' ', '''','syz.dat','''',' ','''','szx.dat','''']);
%fprintf(fid,'%s\n','  0           0           0           0           0');
fprintf(fid,'%s\n',[num2str(istilt(1)),' ',num2str(istilt(2)),' ',num2str(isrot(1)),...
         ' ',num2str(isgd(1)),' ',num2str(isgr(1))]);
fprintf(fid,'%s\n',['''','tx.dat','''',' ','''','ty.dat','''',' ','''','rot.dat','''',...
         ' ','''','gd.dat','''',' ','''','gr.dat','''']);
fprintf(fid,'%s\n','  1');
fprintf(fid,'%s\n',['     0.00  ','''','coseis-gps.dat','''',' ','|0 co-seismic']);
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n',['# GREEN','''','S FUNCTION DATABASE']);
fprintf(fid,'%s\n','# =========================');
fprintf(fid,'%s\n',['# 1. directory where the Green','''','s functions are stored: grndir']);
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n',['# 2. file names (without extensions!) for the 13 Green','''','s functions:']);
fprintf(fid,'%s\n','#    3 displacement komponents (uz, ur, ut): green(i), i=1,3');
fprintf(fid,'%s\n','#    6 stress components (szz, srr, stt, szr, srt, stz): green(i), i=4,9');
fprintf(fid,'%s\n','#    radial and tangential components measured by a borehole tiltmeter,');
fprintf(fid,'%s\n','#    rigid rotation around z-axis, geoid and gravity changes (tr, tt, rot, gd, gr):');
fprintf(fid,'%s\n','#    green(i), i=10,14');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note that all file or directory names should not be longer than 80');
fprintf(fid,'%s\n','#    characters. Directories must be ended by / (unix) or \ (dos)! The');
fprintf(fid,'%s\n','#    extensions of the file names will be automatically considered. They');
fprintf(fid,'%s\n','#    are ".ep", ".ss", ".ds" and ".cl" denoting the explosion (inflation)');
fprintf(fid,'%s\n','#    strike-slip, the dip-slip and the compensated linear vector dipole');
fprintf(fid,'%s\n','#    sources, respectively.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n',['''',greendir,'''']);
fprintf(fid,'%s\n',['''','uz','''',' ','''','ur','''',' ','''','ut','''']);
fprintf(fid,'%s\n',['''','szz','''',' ','''','srr','''',' ','''','stt','''',' ','''','szr','''',...
            ' ','''','srt','''',' ','''','stz','''']);
%
fprintf(fid,'%s\n',['''','tr','''',' ','''','tt','''',' ','''','rot','''',' ','''','gd','''',' ','''','gr','''']);
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n','# RECTANGULAR SUBFAULTS');
fprintf(fid,'%s\n','# =====================');
fprintf(fid,'%s\n','# 1. number of subfaults (<= NSMAX in pscglob.h), latitude [deg] and east');
fprintf(fid,'%s\n','#    longitude [deg] of the regional reference point as  origin of the Cartesian');
fprintf(fid,'%s\n','#    coordinate system: ns, lat0, lon0');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 2. parameters for the 1. rectangular subfault: geographic coordinates');
fprintf(fid,'%s\n','#    (O_lat, O_lon) [deg] and O_depth [km] of the local reference point on');
fprintf(fid,'%s\n','#    the present fault plane, length (along strike) [km] and width (along down');
fprintf(fid,'%s\n','#    dip) [km], strike [deg], dip [deg], number of equi-size fault');
fprintf(fid,'%s\n','#    patches along the strike (np_st) and along the dip (np_di) (total number of');
fprintf(fid,'%s\n','#    fault patches = np_st x np_di), and the start time of the rupture; the');
fprintf(fid,'%s\n','#    following data lines describe the slip distribution on the present sub-');
fprintf(fid,'%s\n','#    fault:');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    pos_s[km]  pos_d[km]  slip_along_strike[m]  slip_along_dip[m]  opening[m]');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    where (pos_s,pos_d) defines the position of the center of each patch in');
fprintf(fid,'%s\n','#    the local coordinate system with the origin at the reference point:');
fprintf(fid,'%s\n','#    pos_s = distance along the length (positive in the strike direction)');
fprintf(fid,'%s\n','#    pos_d = distance along the width (positive in the down-dip direction)');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 3. ... for the 2. subfault ...');
fprintf(fid,'%s\n','# ...');
fprintf(fid,'%s\n','#                   N');
fprintf(fid,'%s\n','#                  /');
fprintf(fid,'%s\n','#                 /| strike');
fprintf(fid,'%s\n','#                +------------------------');
fprintf(fid,'%s\n','#                |\        p .            \ W');
fprintf(fid,'%s\n','#                :-\      i .              \ i');
fprintf(fid,'%s\n','#                |  \    l .                \ d');
fprintf(fid,'%s\n','#                :90 \  S .                  \ t');
fprintf(fid,'%s\n','#                |-dip\  .                    \ h');
fprintf(fid,'%s\n','#                :     \. | rake               \');
fprintf(fid,'%s\n','#                Z      -------------------------');
fprintf(fid,'%s\n','#                              L e n g t h');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note that a point inflation can be simulated by three point openning');
fprintf(fid,'%s\n','#    faults (each causes a third part of the volume of the point inflation)');
fprintf(fid,'%s\n','#    with orientation orthogonal to each other. the results obtained should');
fprintf(fid,'%s\n','#    be multiplied by a scaling factor 3(1-nu)/(1+nu), where nu is the Poisson');
fprintf(fid,'%s\n','#    ratio at the source. The scaling factor is the ratio of the seismic');
fprintf(fid,'%s\n','#    moment (energy) of an inflation source to that of a tensile source inducing');
fprintf(fid,'%s\n','#    a plate openning with the same volume change.');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n',['# n_faults (Slip model by ',event,')']);
fprintf(fid,'%s\n','#-------------------------------------------------------------------------------');
%
if ischar(fpara)
    [tmp_a,tmp_b,fext] = fileparts(fpara);
    switch upper(fext)
        case '.OKSAR'
            [fpara,uzone] = sim_oksar2SIM(fpara);
            if isempty(uzone)==0
                utmproj = uzone;
            end
        case '.FPARA'
    end
end
%
%
% we should try to make more samples within one patch...
%
if isove == 1
    fpara = sim_fpara2oversamplebyscale(fpara,thre);
end
%
fprintf(fid,'%d \n',numel(fpara(:,1)));
%
fprintf(fid,'%s\n','#-------------------------------------------------------------------------------');
fprintf(fid,'%s\n','# n   O_lat   O_lon    O_depth length  width strike dip   np_st np_di start_time');
fprintf(fid,'%s\n','# [-] [deg]   [deg]    [km]    [km]     [km] [deg]  [deg] [-]   [-]   [day]');
fprintf(fid,'%s\n','#     pos_s   pos_d    slp_stk slp_dip open');
fprintf(fid,'%s\n','#     [km]    [km]     [m]     [m]     [m]');
fprintf(fid,'%s\n','#-------------------------------------------------------------------------------');
%
% fprintf(fid,'%s\n',' 1    32.5224 105.4260 0.7411  315.00  40.00 229.00 33.00  21   8     0.00');
%
for ni = 1:numel(fpara(:,1))
    %
    if isempty(utmproj)
        [cx,cy,uzone] = deg2utm(fpara(ni,2),fpara(ni,1));
        cfpara        = fpara(ni,:);
        cfpara(1)     = cx./1000;
        cfpara(2)     = cy./1000;
        %
        tfpara        = sim_fparaconv(cfpara,0,11);
        [clat,clon]   = utm2deg(tfpara(1).*1000,tfpara(2).*1000,uzone);
        %
    else
        %
        tfpara = sim_fparaconv(fpara(ni,:),0,11);
        [clat,clon]   = utm2deg(tfpara(1).*1000,tfpara(2).*1000,utmproj);
    end
    %
    np_st = 1;
    np_di = 1;
    fprintf(fid,'%d %f %f %f %f %f %f %f %d %d %d\n',[ni,clat,clon,tfpara(5),...
            tfpara(7),tfpara(6),tfpara(3),tfpara(4),np_st,np_di,days] );%    0.00');
    fprintf(fid,'%s %f %f %f %f %f\n',' ',[tfpara(7)/2,tfpara(6)/2,tfpara(8),tfpara(9).*-1,tfpara(10)]);
    %
end

fprintf(fid,'%s\n','#================================end of input===================================');
fclose(fid);