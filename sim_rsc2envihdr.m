function sim_rsc2envihdr(outname,info,bandname,proj,zone,datatype)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
  %
  %
  % Modification History:
  %   the permit given hemisphere based on info
  %   Feng W.P, @ BJ, 2011-1-2 
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin <3 || isempty(bandname) ==1
     bandname = 'SIM_ENVI';
  end
  if nargin <4 || isempty(proj) ==1
     proj = 'LL';
  end
  if strcmpi(proj,'UTM')==1 && (nargin<5 || isempty(zone)==1)
     disp('Prj is UTM. So you must give the zone of the coordiantes.');
     return
  end
  % new modification by Feng, W.P, 2011-01-02
  if isfield(info,'hemi') == 0
     info.hemi = 'N';
  end
  if nargin < 6
      datatype = 4; % float
  end
  %
  fid = fopen(outname,'w');
  %
  fprintf(fid,'%s\n','ENVI');
  fprintf(fid,'%s%d\n','samples = ',info.width);
  fprintf(fid,'%s%d\n','lines   = ',info.file_length);
  fprintf(fid,'%s%d\n','bands   = ',1);
  fprintf(fid,'%s\n',  'header offset = 0');
  fprintf(fid,'%s\n','file type = ROI_PAC');
  fprintf(fid,'%s\n',['data type = ',datatype]);
  fprintf(fid,'%s\n','interleave = bsq');
  fprintf(fid,'%s\n','byte order = 0');
  if isempty(strfind(upper(proj),'L'))==0
     fprintf(fid,'%s\n',['map info = {Geographic Lat/Lon, 1.0000, 1.0000,',...
                       num2str(info.x_first) ',' num2str(info.y_first) ','...
                       num2str(info.x_step) ',' num2str(abs(info.y_step)) ...
                       ', WGS-84, units=Degrees}']);
  else
     if strcmpi(info.x_unit,'km')==1
        xfirst = info.x_first*1000;
        yfirst = info.y_first*1000;
        xstep  = info.x_step*1000;
        ystep  = info.y_step*1000;
     else
        xfirst = info.x_first;%*1000;
        yfirst = info.y_first;%*1000;
        xstep  = info.x_step;%*1000;
        ystep  = info.y_step;%*1000;
     end
     if strcmpi(info.hemi,'S')==1
        hemi = 'South';
     else
        hemi = 'North';
     end
     fprintf(fid,'%s\n',['map info = {UTM, 1.000, 1.000, '...
                         num2str(xfirst) ',' num2str(yfirst)...
                         ','  num2str(abs(xstep)) ',' num2str(abs(ystep)) ...
                         ',' num2str(zone)  ...
                         ', ',hemi,' , WGS-84, units=Meters}']); 
  end
  fprintf(fid,'%s\n',['band names = { ' bandname ' }']);    
  fclose(fid);
