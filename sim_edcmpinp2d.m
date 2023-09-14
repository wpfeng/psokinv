function sim_edcmpinp2d(fpara,rsc,outinp,outdisp,islayered,obsdepth)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng, W.P, working for EDCMP code produced by R.J Wang
% @ BJ, 2011-05-13
%
if nargin < 2 || exist(rsc,'file')==0
   disp('sim_edcmpinp2d(fpara,rsc,outinp,outdisp,islayered,obsdepth)');
   return
end
if nargin < 4 || isempty(outinp)
    outinp = 'EDCMP06.inp';
end
if nargin < 5 || isempty(outdisp)
    outdisp = 'EDCMP06_XYZ.disp';
end
if nargin < 6 || isempty(islayered)
    islayered = 0;
end
if nargin < 7 || isempty(obsdepth)==1
    obsdepth = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen(outinp,'w');
%
fprintf(fid,'%s\n','# This is the input file of FORTRAN77 program "edcomp" for calculating');
fprintf(fid,'%s\n',['# earthquakes' '''' ' static deformations (3 displacement components, 6 strain/stress']);
fprintf(fid,'%s\n','# components and 2 vertical tilt components) based on the dislocation theory.');
fprintf(fid,'%s\n','# The earth model used is either a homogeneous or multi-layered, isotropic and');
fprintf(fid,'%s\n','# elastic half-space. The earthquke source is represented by an arbitrary number');
fprintf(fid,'%s\n','# of rectangular dislocation planes.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# Note that the Cartesian coordinate system is used and the seismological');
fprintf(fid,'%s\n','# convention is adopted, that is, x is northward, y is eastward, and z is');
fprintf(fid,'%s\n','# downward.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# First implemented in Potsdam, Feb, 1999');
fprintf(fid,'%s\n','# Last modified: Potsdam, Nov, 2001');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# by');
fprintf(fid,'%s\n','# Rongjiang Wang, Frank Roth, & Francisco Lorenzo');
fprintf(fid,'%s\n','# GeoForschungsZetrum Potsdam, Telegrafenberg, 14473 Potsdam, Germany');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# For questions and suggestions please send e-mails to wang@gfz-potsdam.de');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n','# OBSERVATION ARRAY');
fprintf(fid,'%s\n','# =================');
fprintf(fid,'%s\n','# 1. switch for irregular positions (0) or a 1D profile (1)');
fprintf(fid,'%s\n','#    or a rectangular 2D observation array (2): ixyr');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    IF (1 for irregular observation positions) THEN');
fprintf(fid,'%s\n','#    ');
fprintf(fid,'%s\n','# 2. number of positions: nr');
fprintf(fid,'%s\n','# 3. coordinates of the observations: (xr(i),yr(i)),i=1,nr');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    ELSE IF (1 for regular 2D observation array) THEN');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 2. number of position samples of the profile: nr');
fprintf(fid,'%s\n','# 3. the start and end positions: (xr1,yr1), (xr2,yr2)');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    ELSE IF (2 for rectanglular 2D observation array) THEN');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 2. number of xr samples, start and end values [m]: nxr, xr1,xr2');
fprintf(fid,'%s\n','# 3. number of yr samples, start and end values [m]: nyr, yr1,yr2');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note that the total number of observation positions (nr or nxr*nyr)');
fprintf(fid,'%s\n','#    should be <= NRECMAX (see edcglobal.h)!');
fprintf(fid,'%s\n','#===============================================================================');
% fprintf(fid,'%s\n','  0');
% fprintf(fid,'%10d\n',numel(x));
% for ni=1:3:numel(x)
%     outstr = cell(3,1);
%     for nj = 1:3
%         if ni+nj-1 < numel(x)
%           outstr{nj} = ['(',num2str([y(ni+nj-1),x(ni+nj-1)],'%15.5f, %15.5f\n'),'),'];
%         end
%         if ni+nj-1 > numel(x)
%            outstr{ni} = '';
%         end
%         if ni+nj-1 == numel(x)
%             outstr{nj} = ['(',num2str([y(ni+nj-1),x(ni+nj-1)],'%15.5f, %15.5f\n'),')'];
%         end
%     end
%     neoutstr = [outstr{1},' ',outstr{2},' ',outstr{3}];
%     fprintf(fid,'%s\n',neoutstr);
% end
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#  1');
fprintf(fid,'%s\n','#  500');
fprintf(fid,'%s\n','#  (-20.0d+03,20d+03), (20.0d+03,20.0d+03)');
fprintf(fid,'%s\n','#');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info   = sim_roirsc(rsc);
nx     = info.width;
startx = info.x_first;
endx   = info.x_first + (nx-1)*info.x_step;
ny     = info.file_length;
starty = info.y_first + (ny-1)*info.y_step;
endy   = info.y_first;
fprintf(fid,'%s\n','  2');
fprintf(fid,'%5d %15.5f %15.5f \n',ny,starty.*1000,endy.*1000);
fprintf(fid,'%5d %15.5f %15.5f \n',nx,startx.*1000,endx.*1000);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n','# OUTPUTS');
fprintf(fid,'%s\n','# =======');
fprintf(fid,'%s\n','# 1. output directory in char format: outdir');
fprintf(fid,'%s\n','# 2. select the desired outputs (1/0 = yes/no)');
fprintf(fid,'%s\n','# 3. the file names in char format for displacement vector, strain tensor,');
fprintf(fid,'%s\n','#    stress tensor, and vertical tilts:');
fprintf(fid,'%s\n','#    dispfile, strainfile, stressfile, tiltfile');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note that all file or directory names should not be longer than 80');
fprintf(fid,'%s\n','#    characters. Directories must be ended by / (unix) or \ (dos)!');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n',['  ' '''' './outdata/' '''']);
fprintf(fid,'%s\n','        1               0              0              0');
fprintf(fid,'%s\n',['  ' '''' outdisp '''' ' ' ''''   'izmhs.strn' '''' ' ' ''''   'izmhs.strss' '''' ' ' '''' 'izmhs.tilt' '''' ]);
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n','# RECTANGLAR DISLOCATION SOURCES');
fprintf(fid,'%s\n','# ==============================');
fprintf(fid,'%s\n','# 1. number of the source rectangles: ns (<= NSMAX in edcglobal.h)');
fprintf(fid,'%s\n','# 2. the 6 parameters for the 1. source rectangle:');
fprintf(fid,'%s\n','#    Slip [m],');
fprintf(fid,'%s\n','#    coordinates of the upper reference point for strike (xs, ys, zs) [m],');
fprintf(fid,'%s\n','#    length (strike direction) [m], and width (dip direction) [m],');
fprintf(fid,'%s\n','#    strike [deg], dip [deg], and rake [deg];');
fprintf(fid,'%s\n','# 3. ... for the 2. source ...');
fprintf(fid,'%s\n','# ...');
fprintf(fid,'%s\n','#                   N');
fprintf(fid,'%s\n','#                  /');
fprintf(fid,'%s\n','#                 /| strike');
fprintf(fid,'%s\n','#         Ref:-> @------------------------');
fprintf(fid,'%s\n','#                |\        p .            \ W');
fprintf(fid,'%s\n','#                :-\      i .              \ i');
fprintf(fid,'%s\n','#                |  \    l .                \ d');
fprintf(fid,'%s\n','#                :90 \  S .                  \ t');
fprintf(fid,'%s\n','#                |-dip\  .                    \ h');
fprintf(fid,'%s\n','#                :     \. | rake               \ ');
fprintf(fid,'%s\n','#                Z      -------------------------');
fprintf(fid,'%s\n','#                              L e n g t h');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note that if one of the parameters length and width = 0, then a line source');
fprintf(fid,'%s\n','#    will be considered and the displocation parameter Slip has the unit m^2; if');
fprintf(fid,'%s\n','#    both length and width = 0, then a point source will be considered and the');
fprintf(fid,'%s\n','#    Slip has the unit m^3.');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%d\n',size(fpara,1));
fprintf(fid,'%s\n','#         coord. origin: (40.739N, 30.05E)');
fprintf(fid,'%s\n','#-------------------------------------------------------------------------------');
fprintf(fid,'%s\n','# no  Slip   xs        ys       zs        length    width   strike   dip  rake');
fprintf(fid,'%s\n','#-------------------------------------------------------------------------------');
for ni=1:size(fpara,1)
   crake  = atan2(fpara(ni,9),fpara(ni,8))*180/pi;
   cfpara = sim_fparaconv(fpara(ni,:),0,1); 
   fprintf(fid,'%4d %6.3f %12.6f %12.6f %12.6f %8.4f %8.4f %8.4f %8.4f %8.4f\n',ni,sqrt(fpara(ni,8).^2+fpara(ni,9).^2),...
           cfpara(2)*1000,cfpara(1)*1000,cfpara(5)*1000,fpara(ni,7)*1000,fpara(ni,6)*1000,fpara(ni,3),fpara(ni,4),crake);
       
   %fprintf(fid,'%s\n','   1  3.70 0.0d+03 10.0d+03  0.0d+00   20.1d+03  20.0d+03   0.0  30.0  180.0');
end
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n',['# If the earth model used is a layered half-space, then the numerical Green' '''' 's']);
fprintf(fid,'%s\n',['# function approach is applied. The Green' '''' 's functions should have been prepared']);
fprintf(fid,'%s\n','# with the program "edgrn" before the program "edcmp" is started. In this case,');
fprintf(fid,'%s\n',['# the following input data give the addresses where the Green' '''' 's functions have']);
fprintf(fid,'%s\n','# been stored and the grid side to be used for the automatic discretization');
fprintf(fid,'%s\n','# of the finite rectangular sources.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# If the earth model used is a homogeneous half-space, then the analytical');
fprintf(fid,'%s\n',['# method of Okada (1992) is applied. In this case, the Green' '''' 's functions are']);
fprintf(fid,'%s\n','# not needed, and the following input data give the shear modulus and the');
fprintf(fid,'%s\n','# Poisson ratio of the model.');
fprintf(fid,'%s\n','#===============================================================================');
fprintf(fid,'%s\n','# CHOICE OF EARTH MODEL');
fprintf(fid,'%s\n','# =====================');
fprintf(fid,'%s\n','# 1. switch for layered (1) or homogeneous (0) model');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    IF (layered model) THEN');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n',['# 2. directory of the Green' '''' 's functions and the three files for the']);
fprintf(fid,'%s\n',['#    fundamental Green' '''' 's functions: grndir, grnfiles(3);']);
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    Note that all file or directory names should not be longer than 80');
fprintf(fid,'%s\n','#    characters. Directories must be ended by / (unix) or \ (dos)!');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    ELSE (homogeneous model) THEN');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 2. the observation depth, the two Lame constants parameters of the homogeneous');
fprintf(fid,'%s\n','#    model: zrec [m], lambda [Pa], mu [Pa]');
fprintf(fid,'%s\n','#===============================================================================');
%
if islayered==0
   fprintf(fid,'%s\n','# 1');
   fprintf(fid,'%s\n',['#   ' '''' './edgrnfcts/' '''' ' ' ''''  'izmhs.ss' '''' ' ' ''''  'izmhs.ds' '''' ' ' ''''  'izmhs.cl' '''']);
   fprintf(fid,'%s\n','  0');
   fprintf(fid,'%s\n',[' ' num2str(obsdepth,'%12.5f\n') ' '   '3.23E+10  3.23E+10']);
else
   fprintf(fid,'%s\n', '1');
   fprintf(fid,'%s\n',['   ' '''' './edgrnfcts/' '''' ' ' ''''  'izmhs.ss' '''' ' ' ''''  'izmhs.ds' '''' ' ' ''''  'izmhs.cl' '''']);
   fprintf(fid,'%s\n','#  0');
   fprintf(fid,'%s\n',['#  ' num2str(obsdepth,'%12.5f\n') ' '   '3.23E+10  3.23E+10']);
end
fprintf(fid,'%s\n','#================================end of input===================================');
%
fclose(fid);
