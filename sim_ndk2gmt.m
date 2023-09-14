function sim_ndk2gmt(ndk,outname,outdate)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created by FWP, @ BJ, 2010-01-01
% Modified by FWP, @ GU, 2013-04-01
%
if nargin < 1
    disp('sim_ndk2gmt(ndk,outname)');
    return
else
   if ischar(ndk)
       ndk = sim_inpndk(ndk);
   end
end
%
%
if nargin < 2
   outname = 'GCMT.ndk';
end
if nargin < 3
    outdate = 1;
end
%
fid = fopen(outname,'A');
for ni=1:size(ndk,2)
    if outdate == 1
        fprintf(fid,'%8.4f %7.4f %7.2f %6.2f %4.1f %6.2f %4.2f %8.4f %7.4f %s\n',ndk(ni).lon,...
            ndk(ni).lat,ndk(ni).depth,ndk(ni).str1,ndk(ni).dip1,...
            ndk(ni).rak1,ndk(ni).mag,ndk(ni).lon,ndk(ni).lat,ndk(ni).date);
    else
        fprintf(fid,'%8.4f %7.4f %7.2f %6.2f %4.1f %6.2f %4.2f %8.4f %7.4f\n',ndk(ni).lon,...
            ndk(ni).lat,ndk(ni).depth,ndk(ni).str1,ndk(ni).dip1,...
            ndk(ni).rak1,ndk(ni).mag,ndk(ni).lon,ndk(ni).lat);
    end
end
fclose(fid);
