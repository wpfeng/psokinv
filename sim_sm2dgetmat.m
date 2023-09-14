function [res,ZIcor,ZIstd,ZImo,XI,YI] = sim_sm2dgetmat(dirs,post,psoksar,prefix,nofault1,nopara1,nofault2,nopara2,xsize,ysize,alpha)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
  %
  %
  %
  %
  if nargin < 9
     xsize = 0.2;
  end
  if nargin < 10
     ysize = 0.2;
  end
  if nargin < 11
      alpha = 0.12;
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  mats = dir([dirs,'/',post,'*mat']);
  res  = zeros(numel(mats),5);
  for ni=1:numel(mats)
      [fpara,~,corv,stdv] = sim_smgetre([dirs,'/',mats(ni).name],[],0,alpha);
      [~,m0]            = sim_fpara2moment(fpara);
      sindex            = strfind(mats(ni).name,'.');
      strings= mats(ni).name;
      s1     = strings(sindex(1)+1:sindex(2)-1);
      s2     = strings(sindex(2)+1:sindex(3)-1);
      %
      psoksarname = [psoksar,'/',prefix,'.',s1,'.',s2,'.psoksar'];
      disp(psoksarname);
      fpara       = sim_psoksar2SIM(psoksarname);
      %
      %psoksarfile(1).name
      res(ni,:) = [fpara(nofault1,nopara1),fpara(nofault2,nopara2),...
                   corv,stdv,m0];
  end
  %
  xrange  = [min(res(:,1)),max(res(:,1))];
  yrange  = [min(res(:,2)),max(res(:,2))];
  [XI,YI] = meshgrid(xrange(1):xsize:xrange(2),...
                     yrange(1):ysize:yrange(2));
  ZIcor      = griddata(res(:,1),res(:,2),res(:,3),XI,YI,'cubic');    
  ZIstd      = griddata(res(:,1),res(:,2),res(:,4),XI,YI,'cubic');   
  ZImo      = griddata(res(:,1),res(:,2),res(:,5),XI,YI,'cubic');   
