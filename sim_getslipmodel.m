function [fpara mabc] = sim_getslipmodel(matfile,funcs,index,oksarfile)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 fpara = [];
 mabc  = [];
 mat = load(matfile);
 switch upper(funcs) 
     case 'PLOT'
        rgh = mat.roughness;
        rgh = rgh-min(rgh(:));
        rgh = rgh./max(rgh(:));
        std = mat.std;
        std = std - min(std(:));
        std = std./max(std(:));
        figure();
        plot(mat.roughness,mat.std,'o-r');
        figure();
        distm = sqrt(rgh.^2+std.^2);
        index = find(distm==min(distm(:)));
        plot(rgh,std,'o-r');
        hold on 
        plot(rgh(index),std(index),'db');
     case 'MODEL'
         aslip = mat.dismodel{index};
         mat.disf(:,8) = aslip(1:mat.m/2);
         mat.disf(:,9) = aslip(mat.m/2+1:mat.m);
         abcs      = aslip(mat.m+1:mat.m+mat.dm);
         fpara     = mat.disf;
         whos fpara
         sim_fpara2oksar(fpara,oksarfile);
         ninp      = numel(mat.cinput);
         mabc      = cell(ninp,1);
         for ni = 1:ninp
             stind = (ni-1)*3;
             abc = abcs(stind+1:stind+3);
             fprintf('%s %f %f %f',mat.cinput{ni}{1},abc);
             mabc{ni} = {mat.cinput{ni}{1},abc};
         end
 end
