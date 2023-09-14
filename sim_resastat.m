function [fpara index] = sim_resastat(matfile,psoksarfile,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Created by Feng, W.P
 %
 global cfgname
 if nargin<3 || isempty(isplot)==1
    isplot = 0;
 end
 mat = load(matfile);
 rgh = mat.roughness;
 rgh = rgh-min(rgh(:));
 rgh = rgh./max(rgh(:));
 std = mat.std;
 std = std - min(std(:));
 std = std./max(std(:));
 distm = sqrt(rgh.^2+std.^2);
 index = find(distm==min(distm(:)));
 if isempty(index)==1
     index = 1;
 end
 if isplot==1
     figure();
     plot(mat.roughness,mat.std,'o-r');
     figure();
     plot(rgh,std,'o-r');
     hold on
     plot(rgh(index),std(index),'*b','MarkerSize',10);
 end
 %
 aslip = mat.dismodel{index};
 mat.disf(:,8) = aslip(1:end/2);
 mat.disf(:,9) = aslip(end/2+1:end);
 fpara         = mat.disf;
 
 %
 if isvarname(cfgname)==0
     cfgname = 'result';
 end
 if isempty(cfgname)==1
     cfgname = 'result';
 end
 sim_fpara2psoksar(fpara,[cfgname,'/',psoksarfile]);
 [~,bname] = fileparts(psoksarfile);
 bname     = [cfgname,'/',bname];
 fid       = fopen([bname '_ABC.log'],'w');
 cinput    = mat.cinput;
 nf        = numel(cinput);
 out       = mat.mabicre;
 abc       = out.mabc{end};
 for ni = 1:nf
     fprintf(fid,'%15s %15.12f %15.12f %15.12f\n',cinput{ni}{1},abc((ni-1)*3+1:(ni-1)*3+3));
 end
 %
 fid = fopen([bname '_RHGSTD.log'],'w');
 fprintf(fid,'%f %f\n',[mat.roughness(:) mat.std(:)]');
 fclose(fid);
 %
 fid = fopen([bname '_RHGSTD_NORM.log'],'w');
 fprintf(fid,'%f %f\n',[rgh(:) std(:)]');
 fclose(fid);
