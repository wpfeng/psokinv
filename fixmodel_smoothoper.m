function [ps,dips] = fixmodel_smoothoper(ps,dips)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created by Feng, W.P, 2011/0/01, @ BJ
%
np = size(ps,1);
if np > 2
   tps   = cell(numel(dips),1);
   tdips = cell(numel(dips),1);
   for ni = 1:np
       if ni==1 || ni == np
            tps{ni} = ps(ni,:);
          tdips{ni} = dips(ni);
       else
           [str1,dist1] = sim_2points2str(ps(ni-1,:),ps(ni,:));
           [str2,dist2] = sim_2points2str(ps(ni,:),ps(ni+1,:));
            if dist1 < 2
                clen1 = dist1/2;
            else
                clen1 = 2;
            end
             if dist2 < 2
                clen2 = dist2/2;
            else
                clen2 = 2;
            end
            f1      = [ps(ni,1),ps(ni,2),str1,90,0,1,clen1,0,0,0]; 
            f2      = [ps(ni,1),ps(ni,2),str2,90,0,1,clen2,0,0,0]; 
            [x1,y1] = sim_fpara2corners(f1,'ul');
            [x2,y2] = sim_fpara2corners(f2,'ur');
            x0      = (x1+x2)/2;
            y0      = (y1+y2)/2;
            %
            cdips   = [ (dist1-clen1)/dist1*(dips(ni)-dips(ni-1)) + dips(ni-1),...
                       ((dist1-clen1)/dist1*(dips(ni)-dips(ni-1)) + dips(ni-1) + ...
                         clen2/dist2*(dips(ni+1)-dips(ni)) + dips(ni))/2,...
                         clen2/dist2*(dips(ni+1)-dips(ni)) + dips(ni)];
            %
            tps{ni}   = [x1,y1;x0,y0;x2,y2];
            tdips{ni} = cdips'; 
       end
   end
   ps   = [];
   dips = [];
   for ni = 1:np
        ps   = [ps;tps{ni}];
        dips = [dips;tdips{ni}];
   end
end
% 
