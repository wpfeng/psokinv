function sim_tradeoffdip(matfile,outname,ishow)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 %
 pmat = load(matfile);
 abic = pmat.mabicre;
 mdata= zeros(1,5);
 for ni=1:numel(abic)
     out   = abic{ni};
     smest = out.smest;
     rough = smest(:,3);
     stdd  = smest(:,2);
     rough = rough-min(rough(:));
     rough = rough./max(rough(:));
     stdd  = stdd-min(stdd(:));
     stdd  = stdd./max(stdd(:));
     dist  = sqrt(stdd.^2+rough.^2);
     ind   = find(dist==min(dist(:)));
     if isempty(ind)==0
        index = ind(1);
     else
        index = 1;
     end
     mdata(ni,1) = ni;
     mdata(ni,2) = index;
     mdata(ni,3) = smest(index,3);
     mdata(ni,4) = smest(index,2);
     mdata(ni,5) = smest(index,5);
     %plot(smest(:,3),smest(:,2),'o-r');
     %hold on
 end
 if ishow==1
    plot(mdata(:,5),mdata(:,4),'o-r');
 end
 beind = find(mdata(:,4)==min(mdata(:,4)));
 nodip = mdata(beind(1),1);
 dip   = mdata(beind(1),5);
 nsm   = mdata(beind(1),2);
 bmodel= abic{nodip};
 mslip = bmodel.dismodel{nsm};
 fpara = pmat.fpara;
 fpara(:,8) = mslip(1:end/2);
 fpara(:,9) = mslip(end/2+1:end);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %figure();
 sim_fig2d(fpara);
 sim_fpara2psoksar(fpara,[outname '.psoksar']);
 fid = fopen([outname '.tradeoff.dip'],'w');
 fprintf(fid,'%5.3f %5.3f\n',[mdata(:,5),mdata(:,4)]');
 fclose(fid);
