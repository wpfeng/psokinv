function sim_fpara2simp(fpara,outname,zone,llmode,ispoint,unit)
%
%
%
% fault slip model of fpara was outputed into a simp file...
% by Feng, W.P., @ Yj, 2015-05-20
% Now an explosive source is allowed with mogi-like point source with
% okada92
% the unit of slip should also be declared in the header
% by Wanpeng Feng, @NRCan, 2017-04-16
%
if nargin < 5 || isempty(ispoint)
    ispoint = 0;
end
if nargin < 6 || isempty(unit)
    unit = 'm';
end
%
if nargin < 4 || isempty(llmode)
    llmode = 0;
end
%
if nargin < 3
    disp('sim_fpara2simp(fpara,outname,zone,llmodel[0 or 1],ispoint[0 or 1],unit[m,cm or mm])');
    return
end
%
switch  ispoint 
    case 0
        modeltype = 'Rectangle';
    case 1
        modeltype = 'Explosion';
end
%
fid = fopen(outname,'w');
%
fprintf(fid,'%s\n',['# Updated on ',date]);
fprintf(fid,'%s\n',['# UTM ZONE: ',zone]);
fprintf(fid,'%s %s\n',['# Number of faults: ',num2str(numel(fpara(:,1)))],[' ModelType: ',modeltype]);
fprintf(fid,'%s\n','# x(km) y(km) str(deg) dip(deg) dep(km) wid(km) leng(km) s_slip(m) d_slip(m) o_slip(m)');
%
if llmode ~= 0
    [lat,lon] = utm2deg(fpara(:,1).*1000,fpara(:,2).*1000,zone);
    fpara(:,1) = lon;
    fpara(:,2) = lat;
end
%
%
switch upper(unit)
    case 'M'
        factor = 1.;
    case 'CM'
        factor = 0.01;
    case 'MM'
        factor = 0.001;
end
%
disp([' sim_fpara2simp-> conversion factor: ',num2str(factor),' based on a given unit <',unit,'>'])
%
fpara(:,8) = fpara(:,8)  .* factor;
fpara(:,9) = fpara(:,9)  .* factor;
fpara(:,10)= fpara(:,10) .* factor;
%
fprintf(fid,'%f %f %f %f %f %f %f %e %e %e\n',fpara');
%
fclose(fid);