function sim_okinv2res(fpara,abcsm,ntimes,alpha)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 for ni=1:size(abcsm,1);
     fname             = abcsm(ni).fname{1};
     a                 = abcsm(ni).a;
     b                 = abcsm(ni).b;
     c                 = abcsm(ni).c;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     [odir,bname]      = fileparts(fname);
     outname           = fullfile(odir,[bname,'_' num2str(ntimes) '.mod']);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     input             = sim_inputdata(fname);
     %[green,sgreen,dgreen] = sim_oksargreenALP(fpara,input,0,alpha);
     %osim              = sgreen*fpara(:,8)+dgreen*fpara(:,9);
     dis               = multiokada(fpara,input(:,1),input(:,2),0,alpha);
     osim              = dis.E.*input(:,4) + dis.N.*input(:,5) + dis.V .* input(:,6);
     res               = input(:,3)-osim-input(:,1).*a-input(:,2).*b-c;
     %error             = input(:,3)-input(:,1).*a-input(:,2).*b-c;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     fid = fopen(outname,'w'); % when the file can not be openned, message will return...
     %      disp(outname);
     %      disp(fid);
     %      disp(owmes);
     if fid==-1
         disp([outname ' is not opened successfully..']);
     else
         for nk=1:size(input,1)
             fprintf(fid,'%f %f %f %f %f\n',input(nk,1),input(nk,2),input(nk,3),osim(nk),res(nk));
         end
         fclose(fid);
     end
 end
 
