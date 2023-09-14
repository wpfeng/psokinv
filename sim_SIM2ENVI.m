function sim_SIM2ENVI(fpara,incfile,azi,outname,lamd,thd,noise,abc,alpha)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Name: sim_SIM2ENVi.m
% Simluation InSAR fringe by fpara...
% Input:
%      fpara, the fault parameters, m*10,m is the number of the faults
%    incfile, the file in ENVI format widt geoGRID
%        azi, the azimuth angle, degree
%    outname, the simulation coseimic ENVI
%      noise, add the noise level +- noise
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin <1 || isempty(fpara)
   display('You must supply fpara variable. Please give one...');
end
if nargin <2 || isempty(incfile)==1
   display('You must supply a INC file for the simulation work...');
   return
end
if nargin <3 || isempty(azi) ==1
   azi     = -167.7236970;
end
if nargin <4 || isempty(outname) ==1
   outname = 'SIMdata.IMG';
end
if nargin <5 || isempty(lamd) ==1
      lamd = 0.0562356424;           % unit of deformation.
end
if nargin <6 || isempty(thd) ==1
     thd   = 0.0;
end
if nargin <7 || isempty(noise)==1
     noise = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[inc,gridinfo,dims,hdrfile] = sim_readenvi(incfile);
%
%%
x1   = gridinfo(1);
x2   = gridinfo(1)+gridinfo(3)*dims(1)-gridinfo(3);
y2   = gridinfo(2);
y1   = gridinfo(2)-gridinfo(4)*dims(2)+gridinfo(4);
geox = x1:gridinfo(3):x2;
geox = repmat(geox,dims(2),1);
geoy = y1:gridinfo(4):y2;
geoy = repmat(geoy',1,dims(1));
geoy = flipud(geoy);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mapinfo = sim_envi4info(hdrfile);
sim_fpara2envi(fpara,inc',azi,[],[],geox,geoy,outname,...
               gridinfo(3)*1000,gridinfo(4)*1000,mapinfo,lamd,5,thd,noise,abc,alpha);
% outhdr = [outname '.hdr'];
% copyfile(hdrfile,outhdr,'f');
