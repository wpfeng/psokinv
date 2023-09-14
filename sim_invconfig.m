function sim_invconfig(confname,nfaults,clocal,isinv,...
                       inpfile,parts,lamda,myu,psoksarout,...
                       matfile,iterations,dispSIM,itersSIM,...
                       ntimes,ismc,mcloops,mcdir,mcsave,intpara,...
                       intabc,isvcm,rake,vcms,inpmc,mindist,...
                       mwinfo,unit,mwall,utmzone)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
    

% Purpose:
%     initiallize a configure file including some info for the model
%     inversion...
% Input:
%     confname, configure filename
%      nfaults, number of faults
%        parts, the number of particles of PSO algorithm
%        lamda, the constant of the earth
%          myu, the constant of the earth
%     oksarout, the filename to oksar format
%      matfile, the filename to matlab *.mat
% Output:
%     create a configure files based on the input parameters
% Author: Created by Wanpeng Feng
%         skyflow2008@hotmail.com
% Institute of Geophysics, CEA
% Completed this work in University of Glasgow, 03 Jane 2009
% Version0.2,11 June 2009
%
% Add rake control, Feng, W.P, 2011-02-27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin < 1) || isempty(confname)==1
    confname = 'PSOKINV.cfg';
end
if (nargin < 2) || isempty(nfaults)==1
    nfaults = 1;
end
if (nargin < 3) || isempty(clocal)==1
    clocal  = zeros(nfaults,1);
end
if (nargin < 4) || isempty(isinv)==1
    isinv = zeros(nfaults,10)+1;
end
if (nargin < 5) || isempty(inpfile)==1
    inpfile = {'insar.inp'};
end
if (nargin < 6) ||isempty(parts)==1
    parts = 200;
end
if (nargin < 7) ||isempty(lamda)==1
    lamda = 3.23e10;
end
if (nargin < 8) ||isempty(myu)==1
    myu   = 3.23e10;
end
if (nargin < 9) ||isempty(psoksarout)==1
    % standarlize the output
    psoksarout = 'OUTPUT.simp';
end
if (nargin < 10) ||isempty(matfile)==1
    matfile  = 'matfile.mat';
end
if (nargin <11) || isempty(iterations)==1
    iterations = 25;
end
if (nargin <12) || isempty(dispSIM)==1
    dispSIM = 0;
end
if (nargin < 13)|| isempty(itersSIM)==1
    itersSIM = 5000;
end
if (nargin <14)|| isempty(ntimes)==1
    ntimes = 1;
end
if (nargin <15) || isempty(ismc)==1
    ismc = 0;
end
if (nargin <16) || isempty(mcloops)==1
    mcloops = [1 100];
end
if (nargin <17) || isempty(mcdir)==1
    mcdir = 'pert';
end
if (nargin <18) || isempty(mcsave)==1
    mcsave = 'result';
end
if (nargin <19) || isempty(intpara)==1
    intpara = zeros(nfaults,10,3);
end
ninp = numel(inpfile);
if nargin <20 || isempty(intabc)==1
    intabc      = zeros(ninp,4)+0;
    intabc(:,4) = 1;
end
if nargin < 21 || isempty(isvcm)==1
    isvcm  = 0;
end
if nargin < 22 || isempty(isvcm)==1
    rake = [90,-135,45,1];
end
if nargin < 23
    vcms = cell(numel(inpfile),1);
    for ni = 1:numel(vcms)
        vcms{ni} = 'NULL';
    end
end
if nargin < 24
    inpmc = zeros(numel(inpfile),1);
end
if nargin < 25
    mindist = 5;
end
if nargin < 26
    unit='m';
end
if nargin < 27
    mwall='1';
end
if nargin < 27
    utmzone='30Q';
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen(confname,'w');
% Add a header info
fprintf(fid,'%s\n','---------------------------------------------------------------------------');
fprintf(fid,'%s\n','General information: PS-OKINV parameter file');
fprintf(fid,'%s\n','---------------------------------------------------------------------------');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'%s\n','# elastic constant: lambda');
fprintf(fid,'%3.2e\n',lamda);
%myu constant
fprintf(fid,'%s\n','# elastic constant: mu');
fprintf(fid,'%3.2e\n',myu);
fprintf(fid,'%s\n','# unit of displacements: m,cm or mm');
fprintf(fid,'%s\n',unit);
fprintf(fid,'%s\n','# utmzone of displacements, e.g. 19Q');
fprintf(fid,'%s\n',utmzone);
%Particle Number
fprintf(fid,'%s\n','# number of particles');
fprintf(fid,'%4.0f\n',parts);
%fprintf(fid,'%s\n','# PSO: inversion time');
fprintf(fid,'%s\n','# PSO: maximum restart number');
fprintf(fid,'%4.0f\n',ntimes);
fprintf(fid,'%s\n','# PSO: total iteration number (default: 25)');
%
if ischar(iterations)
    iterations = str2double(iterations);
end
%
fprintf(fid,'%4.0f\n',iterations);
fprintf(fid,'%s\n','# PSO: minimum distance among the particles  (default: 10^(-1))');
fprintf(fid,'%4.0f\n',mindist);
fprintf(fid,'%s\n','# SIMPLEX: maximum iteration number (default: 1000)');
fprintf(fid,'%7.0f\n',itersSIM);
fprintf(fid,'%s\n','# SIMPLEX: Info to be shown (1: Yes; 0: No)');
fprintf(fid,'%1.0f\n',dispSIM);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Monte Carlo ERROR estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'%s\n','# Monte Carlo Estimation: 1: Yes; 0: No');
fprintf(fid,'%1.0f\n',ismc);
fprintf(fid,'%s\n','# Monte Carlo: Loop numbers, e.g. from to');
%
if numel(mcloops)<2
    mcloops = [1,100];
end
fprintf(fid,'%3.0f %3.0f\n',mcloops);
fprintf(fid,'%s\n','# Monte Carlo: Directory of InputFiles');
while iscell(mcdir)
    mcdir = mcdir{1};
end
%
while iscell(mcsave)
    mcsave = mcsave{1};
end
fprintf(fid,'%s\n',mcdir);
%
fprintf(fid,'%s\n','# Monte Carlo: Directory of OutputFiles');
fprintf(fid,'%s\n',mcsave);
fprintf(fid,'%s\n','# Weight Matrix from VCM: 1: YES; 0: NO');
fprintf(fid,'%1.0f\n',isvcm);
%
fprintf(fid,'%s\n','# the mode of moment magnitudes for use in constraints');
fprintf(fid,'%s\n',mwall);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Feng,W.P, 2011-04-15, @ BJ
% change PSOKSAR -> OKSAR
fprintf(fid,'%s\n','# output file name: oksar format ');
fprintf(fid,'%s\n',psoksarout);
fprintf(fid,'%s\n','# output file name: matlab format');
fprintf(fid,'%s\n',matfile);
%structure the obv data file
fprintf(fid,'%s\n','---------------------------------------------------------------------------');

fprintf(fid,'%9s %3.0f\n','Number of inputfiles:   ',ninp);
fprintf(fid,'%s\n','---------------------------------------------------------------------------');
fprintf(fid,'%s\n','#No Inv(0/1)  A&&B   C    Weight  VCM  MC(0/1)  PathFileName');

for ni=1:ninp
    ttcinps = inpfile{ni};
    if iscell(ttcinps)
        ttcinps = ttcinps{1};
    end
   tempvcms = vcms{ni};
   if iscell(tempvcms)
       tempvcms = tempvcms{1};
   end
    fprintf(fid,'%2.0f %4.0f %8.0f %5.0f %5.3f %9s %3.0f %20s\n',ni,intabc(ni,1),intabc(ni,2),intabc(ni,3),...
        intabc(ni,4),tempvcms,inpmc(ni),ttcinps);
end
%%%%%%%%%%%%%%%
fprintf(fid,'%s\n','---------------------------------------------------------------------------');
fprintf(fid,'%s\n',['Number of faults:  ' num2str(nfaults)]);

%output the fault initial value

if nargin < 26
    mwinfo = zeros(numel(rake(:,1)),4);
end
%
for ni = 1:nfaults
    fprintf(fid,'%s\n','---------------------------------------------------------------------------');
    fprintf(fid,'%s %s\n','#     Value      MinV        MaxV    Inv(0/1)  Symbol Parameters of fault  ' ,num2str(ni));
    fprintf(fid,'%s\n','---------------------------------------------------------------------------');
    %disp(clocal(ni));
    fprintf(fid,'%9s %2.0f \n','COORTYPE: ',clocal(ni));
    fprintf(fid,'%s\n','---------------------------------------------------------------------------');
    fprintf(fid,'%10.2f %10.2f %10.2f %10.0f  %10s %15s\n',intpara(ni,1,1), intpara(ni,1,2),  intpara(ni,1,3), ...
        isinv(ni,1),['f(', num2str(ni),',1)'],'x-start(km)');
    fprintf(fid,'%10.2f %10.2f %10.2f %10.0f  %10s %15s\n',intpara(ni,2,1), intpara(ni,2,2),  intpara(ni,2,3), ...
        isinv(ni,2),['f(', num2str(ni),',2)'],'y-start(km)');
    fprintf(fid,'%10.2f %10.2f %10.2f %10.0f  %10s %15s\n',intpara(ni,3,1), intpara(ni,3,2),  intpara(ni,3,3), ...
        isinv(ni,3),['f(', num2str(ni),',3)'],'strike(degree)');
    fprintf(fid,'%10.2f %10.2f %10.2f %10.0f  %10s %15s\n',intpara(ni,4,1), intpara(ni,4,2),  intpara(ni,4,3), ...
        isinv(ni,4),['f(', num2str(ni),',4)'],'dip(degree)'   );
    fprintf(fid,'%10.2f %10.2f %10.2f %10.0f  %10s %15s\n',intpara(ni,5,1), intpara(ni,5,2),  intpara(ni,5,3), ...
        isinv(ni,5),['f(', num2str(ni),',5)'],'depth(km)'  );
    fprintf(fid,'%10.2f %10.2f %10.2f %10.0f  %10s %15s\n',intpara(ni,6,1), intpara(ni,6,2),  intpara(ni,6,3), ...
        isinv(ni,6),['f(', num2str(ni),',6)'],'width(km)'  );
    fprintf(fid,'%10.2f %10.2f %10.2f %10.0f  %10s %15s\n',intpara(ni,7,1), intpara(ni,7,2),  intpara(ni,7,3), ...
        isinv(ni,7),['f(', num2str(ni),',7)'],'length(km)');
    fprintf(fid,'%10.2f %10.2f %10.2f %10.0f  %10s %15s\n',rake(ni,1), rake(ni,2),  rake(ni,3), ...
        rake(ni,4),'RakeCons','Rake(degree)');
    fprintf(fid,'%10.2f %10.2f %10.2f %10.0f  %10s %15s\n',mwinfo(ni,1),mwinfo(ni,2), mwinfo(ni,3), ...
        mwinfo(ni,4),'MagnCons','MW(mag)');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Subfunction-1,joint the string array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strout = jointstr(strcell)
ncells = numel(strcell);
tmp    = [];
if ncells > 1
    for ni = 1:ncells-1
        tmp = [tmp,strcell{ni},'|'];
    end
    tmp = [tmp,strcell{end}];
else
    tmp = strcell{1};
end
strout = tmp;




