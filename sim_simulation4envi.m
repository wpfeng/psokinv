%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% Name: sim_simulation4envi.m
% Simluation InSAR fringe by fpara...
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
incfile              = 'E:\EQw\italy_20090406\italy\InSAR\gamma_080427_090412.inc';
azi                  = -167.7236970;
outname              = 'E:\EQw\italy_20090406\sim\dist_143';
lamd                 = 0.0562356424; % unit of deformation.
thd                  = 0.05;
%zone                 = 46;
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
sim_fpara2envi(fpara,inc',azi,[],[],geox,geoy,outname,...
               gridinfo(3)*1000,gridinfo(4)*1000,[],lamd,5,thd);
outhdr = [outname '.hdr'];
copyfile(hdrfile,outhdr,'f');
