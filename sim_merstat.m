function [models indexs] = sim_merstat(matfile,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 if nargin<2 || isempty(isplot)==1
    isplot = 0;
 end
 mat = load(matfile);
 rgh = mat.roughness;
 nmodel = size(rgh,1);
 models = cell(1,1);
 indexs = zeros(nmodel);
 %disp(nmodel);
 for nj=1:nmodel
        rgh = mat.roughness;
        rgh = rgh(nj,:)-min(rgh(nj,:)');
        rgh = rgh(:)./max(rgh(:)');
        std = mat.std;
        std = std(nj,:) - min(std(nj,:)');
        std = std(:)./max(std(:)');
        distm = sqrt(rgh.^2+std.^2);
        index = find(distm==min(distm(:)));
        if isempty(index)==1
           index = 1;
        end
        indexs(nj) = index(1);
        if isplot==1
          figure();
          plot(mat.roughness,mat.std,'o-r');
          figure();
          plot(rgh,std,'o-r');
          hold on 
          plot(rgh(index),std(index),'*b','MarkerSize',10);
        end
        %
        aslip = mat.dismodel{nj,indexs(nj)};
         if mat.isabc ==1
           mat.disf(:,8) = aslip(1:mat.m/2);
           mat.disf(:,9) = aslip(mat.m/2+1:mat.m);
         else
           mat.disf(:,8) = aslip(1:end/2);
           mat.disf(:,9) = aslip(end/2+1:end);
         end
         fpara     = mat.disf;
         models{nj}= fpara;
         disp(['You have finished the NO:' num2str(nj) ' RAND ERROR ESTIMATION!']);
 end
%          whos fpara
         %sim_fpara2oksar(fpara,oksarfile);
%          ninp      = numel(mat.cinput);
%          mabc      = cell(ninp,1);
%          for ni = 1:ninp
%              stind = (ni-1)*3;
%              abc = abcs(stind+1:stind+3);
%              fprintf('%s %f %f %f',mat.cinput{ni}{1},abc);
%              mabc{ni} = {mat.cinput{ni}{1},abc};
%          end
% if mat.isabc==1
%    abc = mat.abc{index};
% else
%    abc = mat.abc;
% end
% %
% [a,bname] = fileparts(oksarfile);
% fid = fopen([bname '_ABC.log'],'w');
% cinput = mat.cinput;
% nf  = numel(cinput);
% for ni = 1:nf
%     fprintf(fid,'%15s %15.12f %15.12f %15.12f\n',cinput{ni}{1},abc((ni-1)*3+1:(ni-1)*3+3));
% end
% %
% fid = fopen([bname '_RHGSTD.log'],'w');
% fprintf(fid,'%f %f\n',[mat.roughness(:) mat.std(:)]);
% fclose(fid);
% %
% fid = fopen([bname '_RHGSTD_NORM.log'],'w');
% fprintf(fid,'%f %f\n',[rgh(:) std(:)]);
% fclose(fid);
