function ps_psoksar2gmt(psoksar,prefix,lonlat)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Modified by Feng W.P
 %             Emphasize the oksar should be psoksar.
 %
 if nargin<1 || isempty(psoksar)==1
    disp(' ps_psoksar2gmt(psoksar,prefix)');
    disp('     >>>psoksar, file keeping the fault parameters');
    disp('     >>>prefix,  prefix of the output file. e.g, PSOKSAR_');
    disp('     >>>lonlat,  used to determine the zone of UTM,e.g, []');
    disp(' Developed by Wanpeng Feng, IGP-CEA, July 2009');
    disp(' Modified by Feng W.P, 27 July 2009');
    disp('     >>>Emphasize the psoksar should be created by PSOKINV.');
    return
 end
 if nargin <2|| isempty(prefix)==1
    prefix = 'PSOKSAR_';
 end
 %
 polyfile = [prefix,'POLY.inp'];
 tofile   = [prefix,'TOP.inp'];
 cpfile   = [prefix,'CEN.inp'];
 genfile  = [prefix,'GEN.info'];
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fidpoly  = fopen(polyfile,'w');
 fidtop   = fopen(tofile,'w');
 fidcp    = fopen(cpfile,'w');
 fidgen   = fopen(genfile,'w');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if nargin>2 && isempty(lonlat)==0
    gfidpoly = fopen(['geo_' polyfile],'w');
    gfidtop  = fopen(['geo_' tofile],'w');
    gfidcp   = fopen(['geo_' cpfile],'w');
    %gfidgen  = fopen(['geo_' genfile],'w');
 end
 
 fpara    = sim_psoksar2SIM(psoksar);
 nf       = size(fpara);
 %
 for ni = 1:nf
     polygon    = sim_fpara2polygon(fpara(ni,:));
     rfpara     = sim_fpara2rand_UP(fpara(ni,:));
     [cx,cy,cz] = sim_fpara2corners(rfpara,'cc');
     [x1,y1]    = sim_fpara2corners(rfpara,'ul');
     [x2,y2]    = sim_fpara2corners(rfpara,'ur');
     %
     %
     if nargin >2
        [tx,ty,zone] = deg2utm(lonlat(2),lonlat(1),[]);
        [gcx,gcy]    = utm2deg(cx*1000,cy*1000,zone);
        [gy1,gx1]    = utm2deg(x1*1000,y1*1000,zone);
        [gy2,gx2]    = utm2deg(x2*1000,y2*1000,zone);
        gpolygon     = polygon;
        for npp=1:size(polygon(:,1),1)
            [gpolygon(npp,2),gpolygon(npp,1)] = utm2deg(polygon(npp,1)*1000,polygon(npp,2)*1000,zone);
        end
        %
        fprintf(gfidpoly,'%10.4f %10.4f\n',gpolygon');
        fprintf(gfidpoly,'%s\n','>');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(gfidcp,'%10.4f %10.4f %10.4f\n',[gcy,gcx,cz]);
        fprintf(gfidcp,'%s\n','>');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(gfidtop,'%10.4f %10.4f\n',[gx1,gy1]);
        fprintf(gfidtop,'%10.4f %10.4f\n',[gx2,gy2]);
        fprintf(gfidtop,'%s\n','>');
     end
      %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %
     fprintf(fidpoly,'%10.4f %10.4f\n',polygon'.*1000);
     fprintf(fidpoly,'%s\n','>');
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     fprintf(fidcp,'%10.4f %10.4f %10.4f\n',[cx.*1000,cy.*1000,cz]);
     fprintf(fidcp,'%s\n','>');
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     fprintf(fidtop,'%10.4f %10.4f\n',[x1,y1].*1000);
     fprintf(fidtop,'%10.4f %10.4f\n',[x2,y2].*1000);
     fprintf(fidtop,'%s\n','>');
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     [x1,y1,z1] = sim_fpara2corners(fpara(ni,:),'uc');
     [x2,y2,z2] = sim_fpara2corners(fpara(ni,:),'lc');
     if nargin > 2 
        [tcy,tcx]    = utm2deg(x1*1000,y1*1000,zone);
        [bcy,bcx]    = utm2deg(x2*1000,y2*1000,zone);
     else
        tcy          = 0.00;
        tcx          = 0.00;
        bcy          = 0.00;
        bcx          = 0.00;
     end
        
     %
     fprintf(fidgen,'%s\n',['>>>>> Fault Number ' num2str(ni) ' <<<<<']);
     fprintf(fidgen,'%s\n',['TC  (x,y,z): ' num2str([x1,y1,z1])]);
     fprintf(fidgen,'%s\n',['   (Lonlat): ' num2str([tcx,tcy,z1])]);
     fprintf(fidgen,'%s\n',['Width  (km): ' num2str(fpara(ni,6))]);
     fprintf(fidgen,'%s\n',['Length (km): ' num2str(fpara(ni,7))]);
     fprintf(fidgen,'%s\n',['Strike(deg): ' num2str(fpara(ni,3))]);
     fprintf(fidgen,'%s\n',['Dip   (deg): ' num2str(fpara(ni,4))]);
     fprintf(fidgen,'%s\n',['Rake  (deg): ' num2str(atan2(fpara(ni,9),fpara(ni,8))*180/3.14159265)]);
     fprintf(fidgen,'%s\n',['Slip    (m): ' num2str(sqrt(fpara(ni,9)^2+fpara(ni,8)^2))]);
     fprintf(fidgen,'%s\n',['BC  (x,y,z): ' num2str([x2,y2,z2])]);
     fprintf(fidgen,'%s\n',['   (Lonlat): ' num2str([bcx,bcy,z2])]);
     %fprintf(fidgen,'%s\n','<<<<<<<<<<<<<<<<<<<<< END >>>>>>>>>>>>>>>>>>>>>>>');
     
        
 end
 
 fclose(fidpoly);
 fclose(fidtop);
 fclose(fidcp);
 fclose(fidgen);
 if nargin > 2 && isempty(lonlat)==0
   fclose(gfidpoly);
   fclose(gfidtop);
   fclose(gfidcp);
 end
