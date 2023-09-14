function [data npoint] = sim_inputdata(inpfile)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 % created by FWP, @ GU, 2009/06
 %
 if nargin < 1
     data   = [];
     npoint = [];
     disp('[data npoint] = sim_inputdata(inpfile);');
     return
 end
 if exist(inpfile,'file')~=0
   fid = fopen(inpfile);
   %
   npoint = 0;
   data   = zeros(1,7);
   while feof(fid)~=1
     txt = fgetl(fid);
     % modified by Feng, W.P, 2011-04-22
     % There will be more lines with no data at the end.
     if strcmpi(txt,'') ~= 1
         npoint = npoint+1;
         %
         tmp = textscan(txt,'%s %s %s %s %s %s %s');
         data(npoint,1) = str2double(tmp{1});
         data(npoint,2) = str2double(tmp{2});
         data(npoint,3) = str2double(tmp{3});
         data(npoint,4) = str2double(tmp{4});
         data(npoint,5) = str2double(tmp{5});
         data(npoint,6) = str2double(tmp{6});
         data(npoint,7) = str2double(tmp{7});
     end
   end
   fclose(fid);
 else
   disp([inpfile ' does not exist! ' 'Please input correct data file! ']);
   data   = [];
   npoint = 0;
 end
