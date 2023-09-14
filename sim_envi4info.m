function mapinfo = sim_envi4info(hdr)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 fid = fopen(hdr,'r');
 %
 mapinfo = [];
 %
 while feof(fid)~=1
     tlines = fgetl(fid);
     index  = findstr(tlines,'map info');
     if isempty(index)~=1
         mapinfo = tlines;
         return
     end
 end
 fclose(fid);
