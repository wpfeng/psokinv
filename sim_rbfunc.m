function sim_rbfunc(fpara,unwfile,outname,incfile,azifile,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************


% developed by FWP, @GU, 2009-05-06
% Updated by fWP, @BJ, 2009-12-05
% 
%global isinv datatype
%
global OUTPROJ UTMZONE 
if iscell(incfile)==0
   incfile = {'NULL'};
end
if iscell(azifile)==0
   azifile = {'NULL'};
end
if nargin<4
   azifile = [];
end
if nargin<3
   incfile = [];
end
output_path     = '.';
threshold       = 0.01;            % the value close to zero, then the number of data will be high
lamd            = 0.01 ;           % as above, decide the number of data.
subxsize        = zeros(size(fpara,1),1)+1;               % Distributed Slip Model's subfault size in STRIKE direction
subysize        = zeros(size(fpara,1),1)+1;               % Distributed Slip Model's subfault size in DIP direction
flen            = zeros(size(fpara,1),1)+20;
fwid            = zeros(size(fpara,1),1)+20;
fractor         = 0.2;             % proportion of non-zero elements required in a
minblocksize    = 1;
maxblocksize    = 64;
qtminvar        = 0.2;
qtmaxvar        = 628.; 
isdisp          = 0;
zone            = 'UTM59S';              % if the projection of InSAR is LL, the zone is necessary.e.g, "UTM50S"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v  = ge_parse_pairs(varargin);
 for j = 1:length(v)
    eval(v{j});
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UTMZONE = zone;
input = cell(1);
for ni =1:numel(unwfile)
    %
    info = sim_roirsc([unwfile{ni},'.rsc']);
    %
    if isempty(strfind(lower(info.projection),'utm'))
        OUTPROJ = 'LL';
    else
        OUTPROJ = 'UTM';
    end
    %
    null_file        = fullfile(output_path,[outname{ni} '_', OUTPROJ,'_',MCM_rmspace(UTMZONE),'ODRs.null']);  % For saving some quadrad sampling infomation 
    qti_file         = fullfile(output_path,[outname{ni} '_', OUTPROJ,'_',MCM_rmspace(UTMZONE),'ODRs.qti']);   % For saving some quadrad sampling infomation
    outfile          = fullfile(output_path,[outname{ni} '_', OUTPROJ,'_',MCM_rmspace(UTMZONE),'.rb.box.xy']);
    %
    disp(['PS_DSM: ',unwfile{ni},' is loading...']);
    %
    input{ni}        = sim_rquads(fpara,unwfile{ni},incfile{ni},azifile{ni},outfile,maxblocksize,minblocksize,fractor,null_file,...
                       qti_file,threshold, lamd, subxsize, subysize,qtminvar,qtmaxvar,zone,flen,fwid);
   %                
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   data = input{ni};
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   outinp   = fullfile(output_path,[outname{ni},'_RB_UTM','_',MCM_rmspace(UTMZONE),'.inp']);
   fid      = fopen(outinp,'w');
   fprintf(fid,'%12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f\n',data');
   fclose(fid);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % UTMZONE
   
   [lat,lon] = utm2deg(data(:,1).*1000,data(:,2).*1000,UTMZONE);
   
   data(:,1) = lon;
   data(:,2) = lat;
   outinpT   = fullfile(output_path,[outname{ni},'_RB_LL_',MCM_rmspace(UTMZONE),'.inp']);
   fid       = fopen(outinpT,'w');
   fprintf(fid,'%12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f\n',data');
   fclose(fid);
   %
   % update data weights by the area...
   % by Feng, W.P., @ EOS of NTU in Singapore, 2015-06-21
   % Switch off, one day after it's created...
   %
   %sim_dsmweightbyarea(outfile,outinpT);
   %data1 = load(outinp);
   %data2 = load(outinpT);
   %data1(:,7) = data2(:,7);
   %sim_input2outfile(data1,outinp);
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if isempty(strfind(lower(OUTPROJ),'l'))==0
       outinp = outinpT;
   end
   % outinp
   if isdisp==1
       figure('Color',[1,1,1]);
       showquad(outfile,outinp);
       disp([min(data(:,3)),max(data(:,3))]);
       caxis([min(data(:,3)),max(data(:,3))]);
       colorbar();
       %
       % add painters for rander
       % painters can speed up my hp laptop...
       %
       set(gcf,'renderer','painters');
   end
end

