function ndk = sim_inpndk(ndkfile)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % to read NDK format InSAR.
 % Created by Feng W.P, 2010-03-19
 % 
 if exist(ndkfile,'file')==0
    ndk = [];
    disp('No found the file!');
    return
 end
    
 fid     = fopen(ndkfile);
 nrecord = 0;
 ndk     = struct();
 while feof(fid)==0
     % to get first line
     nrecord = nrecord+1;
     tlines  = fgetl(fid);
     ndk(nrecord).refcat = tlines(1:4);               % reference catalog
     ndk(nrecord).date   = tlines(6:15);              % the date of event
     ndk(nrecord).time   = tlines(17:26);             % the time of event
     ndk(nrecord).lat    = str2double(tlines(28:33)); % latitude of event
     ndk(nrecord).lon    = str2double(tlines(35:41));
     ndk(nrecord).depth  = str2double(tlines(43:47));
     tmp = textscan(tlines(49:55),'%f%f');
     ndk(nrecord).mag    = tmp{1};
     ndk(nrecord).magerro= tmp{2};
     
     % to get second line
     tlines               = fgetl(fid);
     ndk(nrecord).cmtname = tlines(1:16);
     
     % to get third line
     tlines               = fgetl(fid);
     ndk(nrecord).deptype = tlines(60:63);
     %
     tmp  = textscan(tlines(1:58),'%s%f%f%f%f%f%f%f%f');
     ndk(nrecord).centime   = tmp{2};
     ndk(nrecord).givetime  = tmp{3};
     ndk(nrecord).cenlat    = tmp{4};
     ndk(nrecord).errlat    = tmp{5};
     ndk(nrecord).cenlon    = tmp{6};
     ndk(nrecord).errlon    = tmp{7};
     ndk(nrecord).cendep    = tmp{8};
     ndk(nrecord).errdep    = tmp{9};
     ndk(nrecord).typedep   = tlines(60:63);
     % to get forth line
     tlines               = fgetl(fid);
     ndk(nrecord).expon   = str2double(tlines(1:2));
     mom = textscan(tlines(3:80),'%f%f%f%f%f%f%f%f%f%f%f%f'); %moment tensor
     ndk(nrecord).mrr     = mom{1};
     ndk(nrecord).mrrerr  = mom{2};
     ndk(nrecord).mtt     = mom{3};
     ndk(nrecord).mtterr  = mom{4};
     ndk(nrecord).mpp     = mom{5};
     ndk(nrecord).mpperr  = mom{6};
     ndk(nrecord).mrt     = mom{7};
     ndk(nrecord).mrterr  = mom{8};
     ndk(nrecord).mrp     = mom{9};
     ndk(nrecord).mrperr  = mom{10};
     ndk(nrecord).mtp     = mom{11};
     ndk(nrecord).mtperr  = mom{12};
     % to get fifth line
     tlines   = fgetl(fid);
     ndk(nrecord).vcode   = tlines(1:3);
     ndk(nrecord).scalemom= str2double(tlines(50:56));
     mec = textscan(tlines(58:80),'%f%f%f%f%f%f');
     ndk(nrecord).str1 = mec{1};
     ndk(nrecord).dip1 = mec{2};
     ndk(nrecord).rak1 = mec{3};
     ndk(nrecord).str2 = mec{4};
     ndk(nrecord).dip2 = mec{5};
     ndk(nrecord).rak2 = mec{6}; 
 end
 fclose(fid);
