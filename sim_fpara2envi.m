function sim_fpara2envi(fpara,dinc,dazi,ainc,aazi,x,y,...
                        outname,xstep,ystep,zone,lamd,band,thd,noise,abc,alpha)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: sim_fpara2envi
%            
% Purpose:
%       forward simulation of the coseismic deformation field...
% Compiled by Feng W.P, 07/06/2009, IGP-CEA
% Worked this in University of Glasgow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frsize  = lamd;
dis     = multiokadaALP(fpara,x,y,1,alpha,thd);
flag    = zeros(2,1);
dsim    = cell(2,1);
if isempty(dinc)~=1
  dsim{1} = (dis.N.*sind(dazi)-dis.E.*cosd(dazi)).*sind(dinc)+...
             dis.V.*cosd(dinc);
  flag(1) = 1;
end
if isempty(ainc)~=1
  dsim{2} = (dis.N.*sind(aazi)-dis.E.*cosd(aazi)).*sind(ainc)+...
             dis.V.*cosd(ainc);
  flag(2) = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for noz = 1:2
    if flag(noz) == 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      dph   = dsim{noz}./(-frsize).*4.*pi;
      dwrap = atan2(sin(dph),cos(dph));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      [nline,nrow]   = size(x);
      outdata        = zeros(nrow,nline,band);
      if isempty(noise)~=1 
         noise = rand(nline,nrow).*2*noise-noise;
         tt    = x.*abc(1)+y.*abc(2)+abc(3);
         noise = tt+noise;
      else
         noise = 0;
         tt    = x.*abc(1)+y.*abc(2)+abc(3);
         noise = tt+noise;
      end
      outdata(:,:,1) = (dph')+noise';
      outdata(:,:,2) = (dwrap');
      if band>=3
         outdata(:,:,3) = (dis.N./(-frsize).*4.*pi)';
         outdata(:,:,4) = (dis.E./(-frsize).*4.*pi)';
         outdata(:,:,5) = (dis.V./(-frsize).*4.*pi)';
         band = 5;
      else
         band = 2;
      end
      fid            = fopen([outname '.img'],'w');
      fwrite(fid,outdata,'float32');
      fclose(fid);
      %
      if isempty(zone)~=1
         sim_mat2en(nrow,nline,min(min(x.*1000)),...
                    max(max(y.*1000)),xstep,ystep,zone,...
                    [outname,'.hdr'],band);
      end
     end
end
disp('The work has been done well.');
