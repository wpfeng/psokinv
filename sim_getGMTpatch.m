function [patchsize,points] = sim_getGMTpatch(gmtdata,nstep,pixelsize)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
if nargin < 2
    nstep = 5;
end
if nargin < 3
    pixelsize = 0.16;
end
%
%point   = [];
counter = 0;
fid = fopen(gmtdata,'r');
outd= [];
while feof(fid)==0 
    tfline = fgetl(fid);
    index  = findstr(tfline,'>');
    if isempty(index)==1
       tmp  = textscan(tfline,'%f%f');
       outd = [outd;tmp{1},tmp{2}];
    else 
       counter = counter + 1;
    end
end
fclose(fid);
points    = cell(counter,1);
patchsize = zeros(counter,1);
for ni = 1:counter
    cps = outd((ni-1)*nstep+1:(ni-1)*nstep + 5,:);
    patchsize(ni,1) = ceil((max(cps(:,1))-min(cps(:,1)))/pixelsize);
    points{ni} = cps;
end
