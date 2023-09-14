function sim_psokinv4SIM(psoksar,incf,azif,model,outname,alpha,thd,rzone,unwf)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% + Name:
%     sim_psokinv4SIM(psoksar,incf,model,outname,alpha)
% Input:
%    psoksar, the full path of the oksar model file
%       incf, the prefix of the ROI RSC header info
%      model, eg, "MEAN" use the a mean incidence angle;
%             "LOS" will use the incidence matrix, and incf, as inc
%             file must be available.
%    outname, the prefix for saving all result, including 3 components,
%             E,N,V and simulation of interferogram
%      alpha, option paramters for the earth media paramters, eg. 0.5
%      rzone, the zone in UTM projection,if the files are still in UTM,
%             it's not necessary.
% Created by Feng W.P, CEA-IGP && University of Glasgow
% 26 June 2009, add usage details...
% Modified by Feng W.P at 23 July 2009
%        added a new kyword,"rzone', to force to convert the PROJ to rzone
%*************************************************************************
% -> Modified by Feng, Wanpeng, 2011-04-15,@ BJ
%    now support OKSAR fault model as input
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global synmodel
%
if ~exist('synmodel','var')
    synmodel = 'los';
end
%
if nargin<1 || isempty(psoksar)==1 || isempty(incf)==1
    disp('sim_psokinv4SIM(psoksar,incf,model,outname,alpha,thd)');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    return
end
incfrsc   = sim_checkfiles(incf,azif,unwf);
%
if nargin<2 || isempty(model)==1
    model = 'MEAN';
end
%
if nargin<5 || isempty(outname)==1
    [tmp_a,b]   = fileparts(incfrsc);
    [tmp_a,b]   = fileparts(b);
    outname = b;
end
if nargin<6 || isempty(alpha)==1
    alpha = 0.5;
end
%
%
if nargin<8
    rzone = [];
end
%
pi = 3.141592653589793;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Input PSOksar Model %%%%%%%%%%%%%
disp([psoksar ' is reading...']);
type = 'FPARA';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Feng, Wanpeng, 2011-04-15, @ BJ
% now standarlize the input. Now support fault model based on postfix
[tmp_a,tmp_a,postfix] = fileparts(psoksar);
postfix=strrep(postfix,' ','');
%postfix
switch upper(postfix)
    case '.MAT'
        type = 'TRIF';
        trif  = load(psoksar);
        trif  = trif.trif;
    case '.PSOKSAR'
        fpara = sim_psoksar2SIM(psoksar);
    case '.OKSAR'
        fpara = sim_oksar2SIM(psoksar);
    case '.SIMP'
        fpara = sim_simp2fpara(psoksar);
        %
end
%whos fpara
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmpi(model,'LOS')==1
    %
    %
    [incdata,ux,uy,sarinfo]   = sim_readroi(incf);
    %
else
    %
    sarinfo = sim_roirsc(incfrsc);
    incdata = sarinfo.incidence;
    x0      = sarinfo.x_first;
    xstep   = sarinfo.x_step;
    y0      = sarinfo.y_first;
    ystep   = sarinfo.y_step;
    wid     = sarinfo.width;
    len     = sarinfo.file_length;
    x1      = (wid-1)*xstep+x0;
    y1      = (len-1)*ystep+y0;
    [ux,uy] = meshgrid(double(x0):xstep:double(x1),double(y0):ystep:double(y1));
    %
end
%
%
if isempty(strfind(lower(sarinfo.projection),'utm'))==1
    [ux,uy] = ll2utm(uy,ux,rzone);
    ux      = ux./1000;
    uy      = uy./1000;
    %
else
    if isempty(strfind(lower(sarinfo.y_unit),'k'))==1
        ux   = ux./1000;
    end
    if isempty(strfind(lower(sarinfo.y_unit),'k'))==1
        uy   = uy./1000;
    end
end
%
%  plot(ux,uy,'or');
%  hold on
%  sim_fig3d(fpara);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sarinfo = sim_roirsc(incfrsc);
if sarinfo.wavelength ==0
    sarinfo.wavelength = 0.05623;
end
%
if strcmpi(type,'fpara')~=0
    %
    dis = multiokadaALP(fpara,ux,uy,1,alpha,thd);
    E   = dis.E;
    N   = dis.N;
    U   = dis.V;
else
    [m,n] = size(ux);
    dis   = multiTRIdis(trif,ux(:),uy(:),ux(:).*0);
    E     = reshape(dis.x,m,n);
    N     = reshape(dis.y,m,n);
    U     = reshape(dis.z,m,n);
end
%
if strcmpi(azif,'NULL')==1
    azi = sarinfo.heading_deg;
else
    azi= sim_readroi(azif);
    azi= azi-90;
end
%
disp([' PS_SIM: ', upper(synmodel), ' is working now...']);
switch upper(synmodel)
    case 'LOS'
        SIM =(-1.*cosd(azi).*sind(incdata).*E + ...
               sind(azi).*sind(incdata).*N + ...
               cosd(incdata).*U).*(-4*pi/sarinfo.wavelength);
    case 'RNG'
        %          SIM = sind(azi+90).*E + ...
        %                cosd(azi+90).*N;
        %
        % fixed a bug, @ GU, 2013-03-03
        %
        SIM = ( -1.*cosd(azi).*sind(incdata).* E + ...
                   sind(azi).*sind(incdata).* N + ...
                              cosd(incdata).* U).*-1; %.*(-4*pi/sarinfo.wavelength);
    case 'AZI'
        SIM = sind(azi).*E + ...
            cosd(azi).*N;
end
%
% Updated by Feng,W.P.,@ GU, 2012-09-27
%
if exist(unwf,'file') && ~strcmpi(unwf,'NULL')
    unw = sim_readimg(unwf);
    SIM(unw==0) = 0;
end
%
if strcmpi(model,'LOS')==1
    szeros              = incdata;
    szeros(incdata < 0.1) = 0;
    szeros(incdata >=0.1) = 1;
    E                   = E.*szeros;
    N                   = N.*szeros;
    U                   = U.*szeros;
    SIM                 = SIM.*szeros;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define outputFiles Names:
file_X    = [outname '_X.los'];
file_Xrsc = [file_X '.rsc'];
file_Xhdr = [outname '_X.hdr'];
file_Y    = [outname '_Y.los'];
file_Yrsc = [file_Y '.rsc'];
file_Yhdr = [outname '_Y.hdr'];
%
file_E    = [outname '_E.los'];
file_Ersc = [file_E '.rsc'];
file_Ehdr = [outname '_E.hdr'];
file_N    = [outname '_N.los'];
file_Nrsc = [file_N '.rsc'];
file_Nhdr = [outname '_N.hdr'];
file_U    = [outname '_U.los'];
file_Ursc = [file_U '.rsc'];
file_Uhdr = [outname '_U.hdr'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_INSAR    = [outname '_LOS.phs'];
file_INSARrsc = [file_INSAR '.rsc'];
file_INSARhdr = [outname '_LOS.phs.hdr'];
%%%% Output E %%%%
fid = fopen(file_E,'w');
fwrite(fid,E','float32');
fclose(fid);
%
%
% Update by Feng,W.P.,@ GU, 2012-09-27
% new version don't need provide an existing incfile unless you want to use LOS parameters at each pixel..
%
copyfile(incfrsc,file_Ersc);
%
sim_rsc2envihdr(file_Ehdr,sarinfo,'E',sarinfo.projection,sarinfo.utmzone);
%%%% Output N %%%%
fid = fopen(file_N,'w');
fwrite(fid,N','float32');
fclose(fid);
copyfile(incfrsc,file_Nrsc);
sim_rsc2envihdr(file_Nhdr,sarinfo,'N',sarinfo.projection,sarinfo.utmzone);
%%%% Output V %%%%
fid = fopen(file_U,'w');
fwrite(fid,U','float32');
fclose(fid);
copyfile(incfrsc,file_Ursc);
sim_rsc2envihdr(file_Uhdr,sarinfo,'U',sarinfo.projection,sarinfo.utmzone);
%%%% Output SIM %%%%
fid = fopen(file_INSAR,'w');
fwrite(fid,SIM','float32');
fclose(fid);
copyfile(incfrsc,file_INSARrsc);
sim_rsc2envihdr(file_INSARhdr,sarinfo,'INSAR',sarinfo.projection,sarinfo.utmzone);
%%%% Output X %%%%
fid = fopen(file_X,'w');
fwrite(fid,ux','float32');
fclose(fid);
copyfile(incfrsc,file_Xrsc);
sim_rsc2envihdr(file_Xhdr,sarinfo,'X',sarinfo.projection,sarinfo.utmzone);
%%%% Output Y %%%%
fid = fopen(file_Y,'w');
fwrite(fid,uy','float32');
fclose(fid);
copyfile(incfrsc,file_Yrsc);
sim_rsc2envihdr(file_Yhdr,sarinfo,'X',sarinfo.projection,sarinfo.utmzone);

