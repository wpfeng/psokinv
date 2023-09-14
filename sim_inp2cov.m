function sim_inp2cov(inpfile,unwfile,lamda)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng, Wanpeng, 2010-07
% global inpdata
 if nargin < 3
     info  = sim_roirsc([unwfile,'.rsc']);
     lamda = info.wavelength;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [ipath,iname] = fileparts(inpfile);
 inpdata       = sim_inputdata(inpfile);
 boxfile       = fullfile(ipath,[iname,'.quad.box.xy']);
 if exist(boxfile,'file')==0
    boxfile    = fullfile(ipath,[iname,'.rb.box.xy']);
 end
 %
 fid = fopen(boxfile,'r');
%outd = [];
outd    = zeros(size(inpdata,1),2);
counter = 0;
while feof(fid)==0 
    
    tfline = fgetl(fid);
    index  = findstr(tfline,'>');
    if isempty(index)==1
       counter = counter +1;
       %disp(counter);
       tmp  = textscan(tfline,'%f%f');
       %whos tmp
       outd(counter,:) = [tmp{1},tmp{2}];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose(fid);
%whos outd
nregion = size(outd,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[indata,cx,cy,info] = sim_readroi(unwfile);
if isempty(findstr(lower(info.x_unit),'k'))==1
    cx = cx./1000;
end
if isempty(findstr(lower(info.y_unit),'k'))==1
    %
    %
    cy = cy./1000;
    %
    %
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmpInd = zeros(nregion/5,3);
%
% matlabpool open;
%
parfor ni=1:nregion/5
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    out = sim_inp2cov_sub(indata,inpdata,cx,cy,outd,ni,lamda);
    %
    tmpInd(ni,:) = out;
    %disp(out);
end
inpdata(tmpInd(:,1),7) = tmpInd(:,2);
inpdata(tmpInd(:,1),8) = tmpInd(:,3);
%
fid       = fopen(fullfile(ipath,[iname,'_COV','.inp']),'w');
fprintf(fid,'%15.8f %15.8f %11.8f %11.8f %11.8f %11.8f %11.8f %11.8f\n',inpdata');
fclose(fid);
covm      = 1./(inpdata(:,7).*sum(1./inpdata(:,7)));
vcm       = diag(covm);
outmat    = fullfile(ipath,[iname,'.cov.mat']);
eval(['save ',outmat,' vcm']);
boxv      = sqrt(inpdata(:,8))./sum(sqrt(inpdata(:,8)));
vcm       = diag(boxv);
outmat    = fullfile(ipath,[iname,'.box.mat']);
eval(['save ',outmat,' vcm']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%matlabpool close;
