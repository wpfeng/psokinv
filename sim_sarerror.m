function [phserror deferror] = sim_sarerror(deltaDEM,baseline,lamda,sathigh,incidence)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 if nargin<1 || isempty(deltaDEM)==1
    
    disp('sim_sarerror(deltaDEM,baseline,lamda)');
    disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    disp('>> deltaDEM, the error of DEM');
    disp('>> baseline, the perpandicular baseline, m');
    disp('>> lamda, the wavelength of the satellite, m');
    disp('>> sathigh, the high of the satellite, m');
    disp('>> incidence, the sight of light, deg');
    disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    disp('So, you must give DEM error size.');
    return
 end
 if nargin<2|| isempty(baseline)==1
    disp('sim_sarerror(deltaDEM,baseline,lamda)');
    disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    disp('>> deltaDEM, the error of DEM');
    disp('>> baseline, the perpandicular baseline');
    disp('>> lamda, the wavelength of the satellite');
    disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    disp('So, you must give the perpendicular baseline');
    return
 end
 if nargin<3|| isempty(lamda)==1
    lamda = 0.05623;
 end
 if nargin<4|| isempty(sathigh)==1
    sathigh = 0.7899368582E+06;
 end
 if nargin<5|| isempty(incidence)==1
    incidence = 23;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 pi    = 3.1415926535897932384626433832795;
 phserror = 4*pi./lamda.*(baseline.*deltaDEM)./(sathigh.*sind(incidence));
 deferror = (baseline.*deltaDEM)./(sathigh.*sind(incidence));
 
 
