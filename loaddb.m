function loaddb(index,opt)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % add different database by user
 switch opt 
     case 'add'
        switch index
           case 'raw'
                 p = path();
                 path(p,'D:\mdbase\dbase_0');
           case 'psov1'
                 p = path();
                 path(p,'D:\mdbase\dbase_1');
           case 'psov2'
                 p = path();
                 path(p,'D:\mdbase\dbase_2');
           case 'stamps'
                 p = path();
                 path(p,'D:\mdbase\StaMPS_v3.0.4_beta\matlab');
        end
     case 'rm'
         switch index
           case 'raw'
                 p = path();
                 rmpath('D:\mdbase\dbase_0');
           case 'psov1'
                 p = path();
                 rmpath('D:\mdbase\dbase_1');
           case 'psov2'
                 p = path();
                 rmpath('D:\mdbase\dbase_2');
         end
 end
