function sim_psokinv4COL(psoksar,incf,azif,model,outname,alpha,thd,rzone)
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
 %      model, eg, "MEAN" a mean incidence angle;
 %             "LOS" will use the incidence matrix, and incf, as inc
 %             file must be available.
 %    outname, the prefix for saving all result, including 3 components, 
 %             E,N,V and simulation of interferogram
 %      alpha, option paramters for the earth media paramters, eg. 0.5
 %      rzone, the zone in UTM projection,if the files are still in UTM,
 %             it's not necessary. 
 % Created by Feng W.P., CEA-IGP && University of Glasgow
 % 26 June 2009, add usage details...
 % Modified by Feng W.P at 23 July 2009
 %        added a new kyword,"rzone', to force to convert the PROJ to rzone
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 global strike dip friction depth rake young posi 
 if nargin<1 || isempty(psoksar)==1 || isempty(incf)==1
    disp('sim_psokinv4SIM(psoksar,incf,model,outname,alpha,thd)');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    return
 end
 %
 if nargin<2 || isempty(model)==1 
    model = 'MEAN';
 end

 if nargin<5 || isempty(outname)==1
    [a,b]   = fileparts(incf);
    outname = b;
 end
 if nargin<6 || isempty(alpha)==1
     alpha = 0.5;
 end
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
 [~,~,postfix] = fileparts(psoksar);
 %
 fpara = sim_openfault(psoksar);
 %
 switch upper(postfix)
     case '.PSOKSAR'
         fpara = sim_openfault(psoksar);
     case '.OKSAR'
         fpara = sim_openfault(psoksar);
     case '.SIMP'
         fpara = sim_openfault(psoksar);
     case '.MAT'
         %%%%%%%%%%%%%%%% Input TRIF Model %%%%%%%%%%%%%
         %
         type = 'TRIF';
         trif  = load(psoksar);
         trif  = trif.trif;
 end
 %whos fpara
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if strcmpi(model,'LOS')==1 && exist(incf,'file')~=0
    [cdata,ux,uy,sarinfo]= sim_readroi(incf);
    %cdata(cdata<0.01) = inf;
 else
    sarinfo = sim_roirsc([incf,'.rsc']);
    cdata   = sarinfo.incidence;
    x0      = sarinfo.x_first;
    xstep   = sarinfo.x_step;
    y0      = sarinfo.y_first;
    ystep   = sarinfo.y_step;
    wid     = sarinfo.width;
    len     = sarinfo.file_length;
    x1      = (wid-1)*xstep+x0;
    y1      = (len-1)*ystep+y0;
    [ux,uy] = meshgrid(double(x0):xstep:double(x1),double(y0):ystep:double(y1));
  
 end
 if isempty(strfind(lower(sarinfo.projection),'utm'))==1
    [ux,uy] = ll2utm(uy,ux,rzone);
    ux      = ux./1000;
    uy      = uy./1000;
 else
    if isempty(strfind(lower(sarinfo.y_unit),'k'))==1
       ux = ux./1000;
    end
    if isempty(strfind(lower(sarinfo.y_unit),'k'))==1
       uy = uy./1000;
    end
 end
 %save Fengcheck.mat fpara ux uy
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 sarinfo = sim_roirsc([incf,'.rsc']);
 if sarinfo.wavelength ==0
    sarinfo.wavelength = 0.05623;
 end
 %disp(sarinfo.wavelength)
 
     [m,n] = size(ux);
     %
     ux = ux(:);
     uy = uy(:);
     counter = 0;
     coulomb = [];
     vnormal = [];
     vshear  = [];
     interv  = 200000;
     if interv > m*n
         interv = m*n;
     end
     for ni=interv:interv:m*n
         if ni+interv+1 > m*n
             ni = m*n;
         end
         %disp([counter+1,ni]);
         if strcmpi(type,'fpara')~=0
             %[strike,dip,rake,friction]
             dis = multiokada3Dstress(fpara,ux(counter+1:ni),uy(counter+1:ni),ux(counter+1:ni).*0+depth,...
                 strike,dip,rake,friction,1,alpha,young,posi,thd);
         else
             [~,tri] = multiTRIstrain(trif,ux(counter+1:ni),uy(counter+1:ni),ux(counter+1:ni).*0+depth);
             ss      = [tri.sxx';tri.syy';tri.szz';tri.sxy';tri.sxz';tri.syz'];
            [dis.shear,dis.normal,dis.coulomb] = sim_stress2coulomb(strike,dip,rake,friction,ss);
         end
         
         coulomb = [coulomb;dis.coulomb];
         vnormal = [vnormal;dis.normal];
         vshear  = [vshear;dis.shear];
         counter = ni;
         
     end
     
     E   = reshape(coulomb,m,n);
     N   = reshape(vnormal,m,n);
     U   = reshape(vshear,m,n);
     %  else
     %      [m,n] = size(ux);
     %      %dis   = multiTRIdis(trif,ux(:),uy(:),ux(:).*0);
     %      [~,tri] = multiTRIstrain(trif,ux(:),uy(:),ux(:).*0+depth);
     %      ss      = [tri.sxx';tri.syy';tri.szz';tri.sxy';tri.sxz';tri.syz'];
     %      [U,N,E] = sim_stress2coulomb(strike,dip,rake,friction,ss);
     %      %
     %      E       = reshape(E,m,n);
     %      N       = reshape(N,m,n);
     %      U       = reshape(U,m,n);
     %  end
     %
     %      if strcmpi(azif,'NULL')==1
     %          azi = sarinfo.heading_deg;
     %      else
     %          azi= sim_readroi(azif);
     %          azi= azi-90;
     %      end
     %      %
     %
     %  SIM = ((N.*sind(azi)-E.*cosd(azi)).*...
     %            sind(cdata)+U.*cosd(cdata)).*(-4*pi/sarinfo.wavelength);
     %
     %if strcmpi(model,'LOS')==1
     szeros              = cdata;
     szeros(cdata < 0.1) = 0;
     szeros(cdata >=0.1) = 1;
     E                   = E.*szeros;
     N                   = N.*szeros;
     U                   = U.*szeros;
     %      SIM                 = U.*0;%SIM.*szeros;
     %end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Define outputFiles Names:
 file_X    = [outname '_X.los'];
 file_Xrsc = [file_X '.rsc'];
 file_Xhdr = [outname '_X.hdr'];
 file_Y    = [outname '_Y.los'];
 file_Yrsc = [file_Y '.rsc'];
 file_Yhdr = [outname '_Y.hdr'];
 %
 file_E    = [outname '_coulomb.los'];
 file_Ersc = [file_E '.rsc'];
 file_Ehdr = [outname '_coulomb.hdr'];
 file_N    = [outname '_normal.los'];
 file_Nrsc = [file_N '.rsc'];
 file_Nhdr = [outname '_normal.hdr'];
 file_U    = [outname '_shear.los'];
 file_Ursc = [file_U '.rsc'];
 file_Uhdr = [outname '_shear.hdr'];
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %  file_INSAR    = [outname '_LOS.phs'];
 %  file_INSARrsc = [file_INSAR '.rsc'];
 %  file_INSARhdr = [outname '_LOS.phs.hdr'];
 %%%% Output E %%%%
 cdirs = fileparts(file_E);
 if exist(cdirs,'dir')==0
     mkdir(cdirs);
 end
 fid = fopen(file_E,'w');
 fwrite(fid,E','float32');
 fclose(fid);
 copyfile([incf '.rsc'],file_Ersc);
 %disp(sarinfo);
 sim_rsc2envihdr(file_Ehdr,sarinfo,'Coulomb-Failure-Stress',sarinfo.projection,sarinfo.utmzone);
 %%%% Output N %%%%
 fid = fopen(file_N,'w');
 fwrite(fid,N','float32');
 fclose(fid);
 copyfile([incf '.rsc'],file_Nrsc);
 sim_rsc2envihdr(file_Nhdr,sarinfo,'Normal-Stress',sarinfo.projection,sarinfo.utmzone);
 %%%% Output V %%%%
 fid = fopen(file_U,'w');
 fwrite(fid,U','float32');
 fclose(fid);
 copyfile([incf '.rsc'],file_Ursc);
 sim_rsc2envihdr(file_Uhdr,sarinfo,'Shear-Stress',sarinfo.projection,sarinfo.utmzone);
 %%%% Output SIM %%%%
 %  fid = fopen(file_INSAR,'w');
 %  fwrite(fid,SIM','float32');
 %  fclose(fid);
 %  copyfile([incf '.rsc'],file_INSARrsc);
 %  sim_rsc2envihdr(file_INSARhdr,sarinfo,'INSAR',sarinfo.projection,sarinfo.utmzone);
 %%%% Output X %%%%
 fid = fopen(file_X,'w');
 fwrite(fid,ux','float32');
 fclose(fid);
 copyfile([incf '.rsc'],file_Xrsc);
 sim_rsc2envihdr(file_Xhdr,sarinfo,'X',sarinfo.projection,sarinfo.utmzone);
  %%%% Output Y %%%%
 fid = fopen(file_Y,'w');
 fwrite(fid,uy','float32');
 fclose(fid);
 copyfile([incf '.rsc'],file_Yrsc);
 sim_rsc2envihdr(file_Yhdr,sarinfo,'X',sarinfo.projection,sarinfo.utmzone);
 
