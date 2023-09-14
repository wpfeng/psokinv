function dis_energ = sim_enalongstrike(fpara,linestyle,plotindex,istitle)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************

 %%%
 % Usage:
 %      dis_energ = sim_enalongstrike(fpara,linestyle)
 %                  (en)ergy(along)(strike)
 % Input: 
 %      fpara, Nx10, the SIM format for fault model
 %  linestyle, 'o-r' or '*-b'
 % Output: 
 %      return a figure and statistic result...
 % LOG:
 % Created by Feng W.P,2010/09/28
 %
 %
 if nargin < 1
    disp('dis_energ = sim_enalongstrike(fpara,linestyle)');
    dis_energ = [];
    return
 end
 if nargin < 2
    linestyle = '-r';
 end
 if nargin < 3
     plotindex = 1;
 end
 if nargin < 4
    istitle = 0;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 isort     = sim_fpara2sort(fpara);
 colum     = unique(isort(:,1));
 dis_energ = zeros(numel(colum),2); 
 for ni=1:numel(colum)
     cfpara   = fpara(isort(:,1)==colum(ni),:);
     [~,m2] = sim_fpara2moment(cfpara);
     dis_energ(ni,1) = colum(ni).*cfpara(1,7);
     dis_energ(ni,2) = m2;
 end
 
 switch plotindex 
     case 1
         h1 = area(dis_energ(:,1),dis_energ(:,2));
         set(h1,'FaceColor',[0.8,0.8,0.8]);
         if istitle ~= 0
             xlabel('Along Strike (km)');
             ylabel('Energe (N.m)')
         end
     otherwise
         pid1 = subplot(2,1,1);
             sim_enalongstrike(fpara,'-r',1,0);
             set(gca,'XTickLabel',[]);       
         pid2 = subplot(2,1,2);
            sim_fig2d(fpara,'vector',3:2:30,'lwid',1.2,'qlen',0.5,'conCol','y','isnoline',0,'isquiver',1,'colorbarloc',2);
         %
         hid = findobj('type','axes');
         %p1 = get(hid(1),'Position');
         p2 = get(hid(2),'Position');
         p3 = get(hid(3),'Position');
         if p2(4) + p2(2) >= p3(2) + p3(4)
            set(hid(2), 'Position', [p2(1), p3(2)+p3(4), p2(3) , p3(2)/2]);
         else
            set(hid(3), 'Position', [p3(1), p2(2)+p2(4), p3(3) , p2(2)/2]);
         end
         
 end
 
