function oksar2gmt(oksar,prefix,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Modified by Feng W.P
%             Emphasize the oksar should be oksar.
%************************************************************************
% Modified by Feng, W.P, 2011-04-15, @ BJ
%  Copy psoksar2gmt as oksar2gmt
%************************************************************************
% Modified by Feng, W.P, @ BJ, 2011-06-17
% -> working for automatica return of fault info in the PSOKINV.
%
% updated by Wanpeng Feng, @SYSU, 2018-08-03
% 
global obsunit
%
if nargin<1 || isempty(oksar)==1
    disp(' oksar2gmt(oksar,prefix)');
    disp('     >>>oksar, file keeping the fault parameters');
    disp('     >>>prefix,  prefix of the output file. e.g, PSOKSAR_');
    disp('     >>>lonlat,  used to determine the zone of UTM,e.g, []');
    disp(' ***** Developed by Wanpeng Feng, IGP-CEA, July 2009 *********');
    disp(' *****      Modified by Feng W.P, 27 July 2009       *********');
    disp(' *****      Modified by Feng W.P, 22 Apri 2010       *********');
    disp(' ***  Emphasize the psoksar should be created by PSOKINV.  ***');
    return
end
if nargin <2|| isempty(prefix)==1
    prefix = 'SIMP_';
end
lonlat  = [];
utmzone = [];
outindex= 0;
isgeo   = 1;
stitle  = [];
minstd  = [];
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v = sim_varmag(varargin);
for j = 1:length(v)
    %disp(v);
    eval(v{j});
end
%
% updated by Wanpeng Feng, @NRCan, 2017-09-19
%
[fpara,zone] = sim_openfault(oksar);
%
if isempty(utmzone)
    utmzone = zone;
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(utmzone)
    if isempty(lonlat)
        zone = [];
    else
        [tx,ty,zone] = deg2utm(lonlat(2),lonlat(1),[]);
    end
else
    zone = utmzone;
end
%
polyfile = [prefix,'POLY.inp'];
tofile   = [prefix,'TOP.inp'];
cpfile   = [prefix,'CEN.inp'];
genfile  = [prefix,'GEN.info'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if outindex <=1
    fidpoly  = fopen(polyfile,'a+');
end
if outindex ==2 || outindex == 0
    fidtop   = fopen(tofile,'a+');
end
if outindex ==3 || outindex == 0
    fidcp    = fopen(cpfile,'a+');
end
if outindex ==4 || outindex == 0
    fidgen   = fopen(genfile,'a+');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(zone) ==0 && isempty(isgeo)==0
    gfidpoly = fopen(['geo_' polyfile],'a+');
    gfidtop  = fopen(['geo_' tofile],'a+');
    gfidcp   = fopen(['geo_' cpfile],'a+');
    %gfidgen  = fopen(['geo_' genfile],'w');
end
%
% fpara    = sim_oksar2SIM(oksar);
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
    if isempty(zone)==0 && isempty(isgeo)==0
        zone = MCM_rmspace(zone);
        zone = [zone(1:numel(zone)-1),' ',zone(end)];
        [gcx,gcy]    = utm2deg(cx*1000,cy*1000,zone);
        [gy1,gx1]    = utm2deg(x1*1000,y1*1000,zone);
        [gy2,gx2]    = utm2deg(x2*1000,y2*1000,zone);
        gpolygon     = polygon;
        for npp=1:size(polygon(:,1),1)
            [gpolygon(npp,2),gpolygon(npp,1)] = utm2deg(polygon(npp,1)*1000,polygon(npp,2)*1000,zone);
        end
        %
        fprintf(gfidpoly,'%s\n','>');
        fprintf(gfidpoly,'%10.4f %10.4f\n',gpolygon');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(gfidcp,'%s\n','>');
        fprintf(gfidcp,'%10.4f %10.4f %10.4f\n',[gcy,gcx,cz]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(gfidtop,'%s\n','>');
        fprintf(gfidtop,'%10.4f %10.4f\n',[gx1,gy1]);
        fprintf(gfidtop,'%10.4f %10.4f\n',[gx2,gy2]);
        
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if outindex<=1
        fprintf(fidpoly,'%10.4f %10.4f\n',polygon'.*1000);
        fprintf(fidpoly,'%s\n','>');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if outindex==3 || outindex == 0
        fprintf(fidcp,'%s\n','>');
        fprintf(fidcp,'%10.4f %10.4f %10.4f\n',[cx.*1000,cy.*1000,cz]);
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if outindex == 2 || outindex == 0
        fprintf(fidtop,'%s\n','>');
        fprintf(fidtop,'%10.4f %10.4f\n',[x1,y1].*1000);
        fprintf(fidtop,'%10.4f %10.4f\n',[x2,y2].*1000);
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [x1,y1,z1] = sim_fpara2corners(fpara(ni,:),'uc');
    [x2,y2,z2] = sim_fpara2corners(fpara(ni,:),'lc');
    if isempty(zone)==0
        zone = MCM_rmspace(zone);
        zone = [zone(1:numel(zone)-1),' ',zone(end)];
        [tcy,tcx]    = utm2deg(x1*1000,y1*1000,zone);
        [bcy,bcx]    = utm2deg(x2*1000,y2*1000,zone);
    else
        tcy          = 0.00;
        tcx          = 0.00;
        bcy          = 0.00;
        bcx          = 0.00;
    end
    
    %
    if isempty(stitle)
        ttitle = ['>>>>> Fault Number ' num2str(ni) ' <<<<<'];
    else
        ttitle = ['>>>>> ' stitle ' <<<<<'];
    end
    fprintf(fidgen,'%s\n',ttitle);
    fprintf(fidgen,'%s\n',['TC(x,y,z)  : ' num2str([x1,y1,z1],  '%10.5f %10.5f %10.5f\n')]);
    fprintf(fidgen,'%s\n',['(Lonlat)   : ' num2str([tcx,tcy,z1],'%10.5f %10.5f %10.5f\n')]);
    fprintf(fidgen,'%s\n',['Width(km)  : ' num2str(fpara(ni,6),'%10.5f\n')]);
    fprintf(fidgen,'%s\n',['Length(km) : ' num2str(fpara(ni,7),'%10.5f\n')]);
    fprintf(fidgen,'%s\n',['Strike(deg): ' num2str(fpara(ni,3),'%10.5f\n')]);
    fprintf(fidgen,'%s\n',['Dip(deg)   : ' num2str(fpara(ni,4),'%10.5f\n')]);
    fprintf(fidgen,'%s\n',['Rake(deg)  : ' num2str(atan2(fpara(ni,9),fpara(ni,8))*180/3.14159265,'%10.5f\n')]);
    fprintf(fidgen,'%s\n',['Slip(m)    : ' num2str(sqrt(fpara(ni,9)^2+fpara(ni,8)^2),'%10.5f\n')]);
    fprintf(fidgen,'%s\n',['Std        : ' num2str(minstd,'%10.5f\n')]);
    %
    if strcmpi(obsunit,'m')==1
        factor = 1;
    elseif strcmpi(obsunit,'cm') == 1
        factor = 0.01;
    else
        factor = 0.001;
    end  
    m1 = sim_fpara2moment(fpara,3.23e10,0,factor);
    fprintf(fidgen,'%s\n',['Mw         : ' num2str(m1(ni,4),'%10.5f\n')]);
    fprintf(fidgen,'%s\n',['BC(x,y,z)  : ' num2str([x2,y2,z2])]);
    fprintf(fidgen,'%s\n',['(Lonlat)   : ' num2str([bcx,bcy,z2])]);
    fprintf(fidgen,'%s\n',['MC(x,y,z)  : ' num2str([mean([x1,x2]),mean([y1,y2]),mean([z1,z2])])]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fix a bug by Feng, W.P. 2011-08-16 @BJ, When zone is not given, the
    % lonlat coordinate will not be calculated
    %
    if isempty(zone)==0
        [bcy,bcx] = utm2deg(mean([x1,x2])*1000,mean([y1,y2])*1000,zone);
    else
        bcy = 0;
        bcx = 0;
    end
    fprintf(fidgen,'%s\n',['(Lonlat)   : ' num2str([bcx,bcy,mean([z1,z2])])]);
    
    fprintf(fidgen,'%s\n',['UTMZONE    : ' zone]);
    %fprintf(fidgen,'%s\n','<<<<<<<<<<<<<<<<<<<<< END >>>>>>>>>>>>>>>>>>>>>>>');
    
    
end
if outindex<=1
    fclose(fidpoly);
end
if outindex==2 || outindex ==0
    fclose(fidtop);
end
if outindex==3 || outindex == 0
    fclose(fidcp);
end

fclose(fidgen);
if isempty(zone)==0 && isempty(isgeo)==0
    fclose(gfidpoly);
    fclose(gfidtop);
    fclose(gfidcp);
end
