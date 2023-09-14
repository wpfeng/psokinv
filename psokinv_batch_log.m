function psokinv_batch_log()
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Developed by FWP,@GU, 2014-05-18
%
%
%
%
%************** FWP's work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%
cm = dir('*.m');
for ni = 1:numel(cm)
    cfile = cm(ni).name;
    fidopen = fopen(cfile,'r');
    fidout  = fopen(['D:\mdbase\users\psokin_sav\',cfile],'w');
    nl = 0;
    while ~feof(fidopen)
        nl = nl+1;
        tline = fgetl(fidopen);
        if nl == 2
            fprintf(fidout,'%s\n','%');
            fprintf(fidout,'%s\n','%************** FWP Work ************************');
            fprintf(fidout,'%s\n','%Developed by FWP, @GU/BJ, 2007-2014');
            fprintf(fidout,'%s\n','%  contact by wanpeng.feng@hotmail.com');
            fprintf(fidout,'%s\n','%************** Good Luck ***********************');
            fprintf(fidout,'%s\n',tline);
        else
            fprintf(fidout,'%s\n',tline);
        end
    end
    fclose(fidopen);
    fclose(fidout);
        
        
end
