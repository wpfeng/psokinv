%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
function psokinv_processing(scale,psoPS,options,simplexoptions)
  global initialONE

  [x fval xsimp fvalsimp maxtab fswarm] ...
                          = pso_localv4(@sim_obj,scale,psoPS,options,simplexoptions);
  % disp(x);
  initialONE = xsimp(:)';
  [sfpara abc vobj1 vobj2]= sim_obj_psoksar_SLIPALP(xsimp);
  %whos abc
  njj = 0;
  if nset > 0 
     counter   = 0;
     conNJJ    = zeros(1,1);
     conNJJ(1) = counter;
     for njj=1:nset
         % modified by Feng W.P, 2009-10-25
         % Now the package supports just a&&b inversion or just c inversion
         mabc(njj).fname = cinput{cindex(njj)};
         cofabc          = abccof(cindex(njj),:);
         if cofabc(3)==1
            counter = counter+2;
         end
         if cofabc(4)==1
            counter = counter+1;
         end
         conNJJ(njj+1) = counter;
         %counter
         Cabc          = abc(conNJJ(njj)+1:conNJJ(njj+1));
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % the flag if the a&b need to invert. It's easy to clip C.
         %
         NowCON       = 0;
         if cofabc(3) == 1
             mabc(njj).a     = Cabc(1);
             mabc(njj).b     = Cabc(2);
             NowCON          = 2;
         else
             mabc(njj).a     = 0;
             mabc(njj).b     = 0;
         end
         if cofabc(4) == 1
            mabc(njj).c      = Cabc(NowCON+1:end);
         else
            mabc(njj).c      = 0;
         end
     end
  end
  if numel(cnoind)>0
     for nij=(njj+1):(numel(cnoind)+njj)
        mabc(nij).fname = cinput{cnoind(nij-njj)};
        mabc(nij).a     = 0;%abc(((njj-1)*3)+1);
        mabc(nij).b     = 0;%abc(((njj-1)*3)+2);
        mabc(nij).c     = 0;%abc(((njj-1)*3)+3); 
     end
  end
  %
  abcsm{ni}               = mabc;
  abcm{ni}                = abc;
  outfpara{ni}            = sfpara;
  outstd(ni,:)            = [vobj1,vobj2];
  outfpswm{ni}            = fswarm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim_fpara2psoksar(sfpara,fullfile(savedir,[outoksar{1}{1} num2str(ni)]));
sim_okinv2res(sfpara,mabc(:),ni,alpha);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eval(['save ' fullfile(savedir,outmatf{1}{1}) ' outfpara outfpswm outstd fpara abcm abcsm cinput cyeind cnoind']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp([fullfile(savedir,outmatf{1}{1}) ' has been saved!']);
disp(['Congratulations! PSOKINV finished JOB Number ' num2str(ni) '!']);
