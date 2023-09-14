function [fpara,moutps] = sim_polygon4faultpatches(polygons,dx,dy,dumpingfactor)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Developed by FWP, @IGPP of SIO, UCSD, 2013-10-10
%
if nargin < 4
    dumpingfactor = 1.2;
end
%
outps = cell(1);

for ni = 1:numel(polygons)
    %
    poly = polygons{ni};
    p1   = poly(1,:);
    p2   = poly(4,:);
    %
    [dip,azi,dist] = sim_2points4dip(p1,p2);
    %
    tfpara    = [p1(1:2),azi,dip,0,abs(p2(3)-p1(3))./sind(dip),1,0,0,0];
    inidep    = abs(p2(3)-p1(3));
    cdy       = dy;
    cdepth    = 0;
    outp      = p1;
    while cdepth <= inidep
        %
        cdistp   = sim_fpara2dist(tfpara,dx,cdy,dx,cdy,'d',cdepth);
        cdy      = cdy*dumpingfactor;
        [x,y,z]  = sim_fpara2corners(cdistp,'dc');
        outp     = [outp;x,y,z];
        cdepth   = z;
    end
    %
    outps{ni} = outp;
end
%
p1   = poly(2,:);
p2   = poly(3,:);
%
[dip,azi] = sim_2points4dip(p1,p2);
tfpara    = [p1(1:2),azi,dip,0,abs(p2(3)-p1(3))./sind(dip),1,0,0,0];
inidep    = abs(p2(3)-p1(3));
cdy       = dy;
cdepth    = 0;
outp      = p1;
%
while cdepth <= inidep
    %
    cdistp   = sim_fpara2dist(tfpara,dx,cdy,dx,cdy,'d',cdepth);
    cdy      = cdy*dumpingfactor;
    [x,y,z]  = sim_fpara2corners(cdistp,'dc');
    outp     = [outp;x,y,z];
    cdepth   = z;
    %
end
%
outps{ni+1} = outp;
%
fpara    = [];
moutps   = cell(1);
numpatch = 0;
%
for ni = 1:numel(outps)-1
    %
    lines1 = outps{ni};
    lines2 = outps{ni+1};
    %
    for nj = 1:numel(lines1(:,1))-1
       dy = sqrt((lines1(nj,1)-lines1(nj+1,1)).^2+...
              (lines1(nj,2)-lines1(nj+1,2)).^2+...
              (lines1(nj,3)-lines1(nj+1,3)).^2);
       dist = sqrt((lines1(nj,1)-lines2(nj,1)).^2+...
              (lines1(nj,2)-lines2(nj,2)).^2+...
              (lines1(nj,3)-lines2(nj,3)).^2);
       %
       npatch  = ceil(dist/dy);
       if npatch < 1
          disp('  ERROR: No valid patch need to be generated!!!!')
       end
       if npatch > 5000
          disp(' WARNING: Too much patches will be generated.')
          npatch = 600;
       end
       %
       xsu     = linspace(lines1(nj,1),lines2(nj,1),npatch+1);
       ysu     = linspace(lines1(nj,2),lines2(nj,2),npatch+1);
       zsu     = xsu.*0+lines1(nj,3);%linspace(lines1(nj,3),lines2(nj,3),npatch);
       xsd     = linspace(lines1(nj+1,1),lines2(nj+1,1),npatch+1);
       ysd     = linspace(lines1(nj+1,2),lines2(nj+1,2),npatch+1);
       zsd     = xsu.*0+lines1(nj+1,3);
       %
       for nk = 1:numel(xsu)-1
           %
           x = [xsu(nk),xsu(nk+1),xsd(nk+1),xsd(nk),xsu(nk)];
           y = [ysu(nk),ysu(nk+1),ysd(nk+1),ysd(nk),ysu(nk)];
           z = [zsu(nk),zsu(nk+1),zsd(nk+1),zsd(nk),zsu(nk)];
           %
           numpatch = numpatch + 1;
           moutps{numpatch} = [x(:),y(:),z(:)];
           outfpara = sim_4points4fpara([x(:),y(:),z(:)]);
           fpara    = [fpara;outfpara];
       end
    end
    
end
