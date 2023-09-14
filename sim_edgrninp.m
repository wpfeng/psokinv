function sim_edgrninp(outinp,layermodel,obsdepth)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************

if nargin < 1
   outinp = 'EDGRD06.inp';
end
if nargin < 2 || isempty(layermodel)
    layermodel = [0.000d+00      4.5000d+03      2.4000d+03     2.7000d+03;...
                  1.000d+03      4.5000d+03      2.4000d+03     2.7000d+03];
end
if nargin < 3
    obsdepth = 0.0;
end
fid = fopen(outinp,'w');
fprintf(fid,'%s\n','#=============================================================================');
fprintf(fid,'%s\n','# This is the input file of FORTRAN77 program "edgrn" for calculating');
fprintf(fid,'%s\n',['# the Green' '''' 's functions of a layered elastic half-space earth model. All']);
fprintf(fid,'%s\n','# results will be stored in the given directory and provide the necessary');
fprintf(fid,'%s\n','# data base for the program "edcmp" for computing elastic deformations');
fprintf(fid,'%s\n','# (3 displacement components, 6 strain/stress components and 2 vertical tilt');
fprintf(fid,'%s\n','# components) induced by a general dislocation source.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# For questions please contact with e-mail to "wang@gfz-potsdam.de".');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# First implemented in May, 1997');
fprintf(fid,'%s\n','# Last modified: Nov, 2001');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# by Rongjiang Wang');
fprintf(fid,'%s\n','# GeoForschungsZetrum Potsdam, Telegrafenberg, 14473 Potsdam, Germany');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# For questions and suggestions please send e-mails to wang@gfz-potsdam.de');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#	PARAMETERS FOR THE OBSERVATION PROFILE');
fprintf(fid,'%s\n','#	======================================');
fprintf(fid,'%s\n','# 1. the uniform depth of the observation points [m]');
fprintf(fid,'%s\n','# 2. number of the equidistant radial distances (max. = nrmax in edgglobal.h),');
fprintf(fid,'%s\n','#    the start and end of the distances [m]');
fprintf(fid,'%s\n','# 3. number of the equidistant source depths (max. = nzsmax in edgglobal.h),');
fprintf(fid,'%s\n','#    the start and end of the source depths [m]');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    If possible, please choose the observation depth either significantly');
fprintf(fid,'%s\n','#    different from the source depths or identical with one of them.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    The 2D distance and depth grids defined here should be necessarily large');
fprintf(fid,'%s\n','#    and dense enough for the discretisation of the real source-observation');
fprintf(fid,'%s\n','#    configuration to be considered later.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#    r1,r2 = minimum and maximum horizontal source-observation distances');
fprintf(fid,'%s\n','#    z1,z2 = minimum and maximum source depths');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
fprintf(fid,'%10.5f %s\n',obsdepth,'                              |dble: obs_depth;');
fprintf(fid,'%s\n',' 501  0.00d+00  1000.00d+03              |int: nr; dble: r1, r2;');
fprintf(fid,'%s\n',' 201  0.00d+00  40.00d+03              |int: nzs; dble: zs1, zs2;');
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#	WAVENUMBER INTEGRATION PARAMETERS');
fprintf(fid,'%s\n','#	=================================');
fprintf(fid,'%s\n','# 1. sampling rate for wavenumber integration (the ratio between the Nyquist');
fprintf(fid,'%s\n','#    wavenumber and the really used wavenumber sample; the suggested value is');
fprintf(fid,'%s\n','#    10-128: the larger this value is chosen, the more accurate are the results');
fprintf(fid,'%s\n','#    but also the more computation time will be required)');
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
fprintf(fid,'%s\n',' 64.0                            |dble: srate;');
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#	OUTPUT FILES');
fprintf(fid,'%s\n','#	============');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n',['# 1. output directory, the three file names for fundamental Green' '''' 's functions']);
fprintf(fid,'%s\n','#    Note that all file or directory names should not be longer than 80');
fprintf(fid,'%s\n','#    characters. Directories must be ended by / (unix) or \ (dos)!');
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
fprintf(fid,'%s\n',[' ' '''' './edgrnfcts/' '''' ' ' ''''  'izmhs.ss' '''' ' ' ''''  'izmhs.ds' '''' ' ' ''''  'izmhs.cl' '''' ' |char: outputs,grnfile(3);']);
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','#	MULTILAYERED MODEL PARAMETERS');
fprintf(fid,'%s\n','#	=============================');
fprintf(fid,'%s\n','# The interfaces at which the elastic parameters are continuous, the surface');
fprintf(fid,'%s\n','# and the upper boundary of the half-space are all defined by a single data');
fprintf(fid,'%s\n','# line; The interfaces, at which the elastic parameters are discontinuous,');
fprintf(fid,'%s\n','# are all defined by two data lines. This input format would also be needed for');
fprintf(fid,'%s\n','# a graphic plot of the layered model.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# Layers which have different upper and lower parameter values, will be treated');
fprintf(fid,'%s\n','# as layers with a constant gradient, and will be discretised by a number of');
fprintf(fid,'%s\n','# homogeneous sublayers. Errors due to the discretisation are limited within');
fprintf(fid,'%s\n','# about 5%.');
fprintf(fid,'%s\n','#');
fprintf(fid,'%s\n','# 1. total number of the data lines (max. = lmax in edgglobal.h)');
fprintf(fid,'%s\n','# 2. table for the layered model');
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
%
fprintf(fid,'%5d %s\n',size(layermodel,1),'                              |int: no_model_lines;');
%
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
fprintf(fid,'%s\n','#    no  depth[m]       vp[m/s]         vs[m/s]        ro[kg/m^3]');
fprintf(fid,'%s\n','#------------------------------------------------------------------------------');
for ni = 1:size(layermodel,1)
    fprintf(fid,'%4d %15.5f %15.5f %15.5f %15.5f\n',ni,layermodel(ni,1:4));
end
%fprintf(fid,'%s\n','  1      0.000d+00      4.5000d+03      2.4000d+03     2.7000d+03');
%fprintf(fid,'%s\n','#  2      1.000d+03      4.5000d+03      2.4000d+03     2.7000d+03');
%fprintf(fid,'%s\n','#  3      1.000d+03      5.6000d+03      3.3000d+03     2.7000d+03');
%fprintf(fid,'%s\n','#  4     13.000d+03      5.6000d+03      3.3000d+03     2.7000d+03');
%fprintf(fid,'%s\n','#  5     13.000d+03      6.2000d+03      3.7000d+03     2.9000d+03');
%fprintf(fid,'%s\n','#  6     30.000d+03      6.2000d+03      3.7000d+03     2.9000d+03');
%fprintf(fid,'%s\n','#  7     30.000d+03      7.9000d+03      4.6000d+03     3.3000d+03');
fprintf(fid,'%s\n','#=======================end of input==========================================');
fclose(fid);
