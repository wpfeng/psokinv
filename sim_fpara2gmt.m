function sim_fpara2gmt(oksar,prefix,zone,lengths)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% sim_fpara2gmt(oksar,prefix,zone);
% + Input:
%    oksar, the fault parameters in oksar formation...
%    prefix, the prefix for output files...
%    zone,  a given utm projection zone for coordinates conversion...
% + Purpose:
%    Create fault vectors for gmt plot...
% + History:
% Developed by fWP, @ BJ, 2009-07
% Updated by fWp, @IGPP of ISO, UCSD, 2013-10-07
%---
% updated by Wanpeng Feng, @NRCan, 2017-03-10
%
%
if nargin < 4
    lengths = [];
end
if nargin < 3
    zone = [];
end
%
if nargin<1 || isempty(oksar)==1
    disp(' sim_fpara2gmt(oksar,prefix)');
    disp('     >>>oksar, the file saving the fault parameters');
    disp('     >>>prefix, the prefix for output. e.g, OKSAR_');
    %
    disp(' Developed by Feng Wanpeng, IGP-CEA,200907');
    disp(' Updated by FWP, @ IGPP of SIO, UCSD, 2013-10-07');
    %
    return
end
if nargin <2|| isempty(prefix)==1
    prefix='PSOKSAR_';
end
%
% Updated by fWP, instead of psoksar by oksar...
% 2013-10-07, @ IGPP of SIO, UCSD
% Updated by Wanpeng Feng, @NRCan, 2017-03-10
if ischar(oksar)
    [fpara,zone] = sim_openfault(oksar);
else
    fpara = oksar;
end
if isempty(zone)
    disp('No [zone] is given...')
    return
end
%
%
%
polyfile = [prefix,'POLY.inp'];
tofile   = [prefix,'TOP.inp'];
cpfile   = [prefix,'CEN.inp'];
geopolyfile = ['geo_',prefix,'POLY.inp'];
geotofile   = ['geo_',prefix,'TOP.inp'];
geocpfile   = ['geo_',prefix,'CEN.inp'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fidtopm  = fopen('segments.loc','w');
fidpoly  = fopen(polyfile,'w');
fidtop   = fopen(tofile,'w');
fidcp    = fopen(cpfile,'w');
geofidpoly  = fopen(geopolyfile,'w');
geofidtop   = fopen(geotofile,'w');
geofidcp    = fopen(geocpfile,'w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
nf    = size(fpara);
%  figure();
for ni = 1:nf
    if ~isempty(lengths)
        fpara(ni,7) = lengths;
    end
    %
    polygon    = sim_fpara2polygon(fpara(ni,:));
    %      plot(polygon(:,1),polygon(:,2),'b');
    [cx,cy,cz] = sim_fpara2corners(fpara(ni,:),'cc');
    %      hold on
    %      plot(cx,cy,'or');
    %
    rfpara   = sim_fpara2rand_UP(fpara(ni,:));
    [x1,y1]  = sim_fpara2corners(rfpara,'ul');
    [x2,y2]  = sim_fpara2corners(rfpara,'ur');
    ipolygon = polygon;
    for nps = 1:numel(polygon(:,1))
        [tx,ty] = utm2deg(polygon(nps,1)*1000,polygon(nps,2)*1000,zone);
        ipolygon(nps,:) = [ty tx];
    end
    %
    fprintf(fidpoly,'%s\n','>');
    fprintf(fidpoly,'%10.4f%10.4f\n',polygon');
    fprintf(geofidpoly,'%s\n','>');
    fprintf(geofidpoly,'%10.4f%10.4f\n',ipolygon');
    fprintf(fidcp,'%s\n','>');
    fprintf(fidcp,'%10.4f%10.4f%10.4f\n',[cx,cy,cz]);
    [gcy,gcx] = utm2deg(cx.*1000,cy.*1000,zone);
    fprintf(geofidcp,'%s\n','>');
    fprintf(geofidcp,'%10.4f%10.4f%10.4f\n',[gcx,gcy,cz]);
    fprintf(fidtop,'%s\n','>');
    fprintf(fidtop,'%10.4f%10.4f\n',[x1,y1]);
    fprintf(fidtop,'%10.4f%10.4f\n',[x2,y2]);
    %fprintf(fidtop,'%s\n','>');
    %fprintf(fidtopm,'%10.4f%10.4f\n',);
    %
    fprintf(geofidtop,'%s\n','>');
    [gy1,gx1] = utm2deg(x1*1000,y1*1000,zone);
    fprintf(geofidtop,'%10.4f%10.4f\n',[gx1,gy1]);
    [gy2,gx2] = utm2deg(x2*1000,y2*1000,zone);
    fprintf(geofidtop,'%10.4f%10.4f\n',[gx2,gy2]);
    
    fprintf(fidtopm,'%10.4f %10.4f\n',mean([gx1,gx2]),mean([gy1,gy2]));
    %
end
fclose(fidtop);
fclose(fidpoly);
fclose(fidcp);
fclose(geofidtop);
fclose(geofidpoly);
fclose(geofidcp);
fclose(fidtopm);
