function [lb,ub] = sim_rakelbub(fpara,wich)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Created by Feng, W.P, 2010-10-13
 % 
 % 
 lb    = zeros(size(fpara,1),1);
 ub    = lb + 10^4;
 % updated by FWP, @ GU, 2013-03-13
 index = sim_fpara2sortv2(fpara);
 %
 ub(index(:,1)==min(index(:,1))) = 0.0000001;
 ub(index(:,1)==max(index(:,1))) = 0.0000001;
 ub(index(:,2)==min(index(:,2))) = 0.0000001;
 ub(index(:,2)==max(index(:,2))) = 0.0000001;
 %
 %
 if isempty(wich) ~= 1
     nsize = size(wich,2);
     for ni= 1:nsize
         % 
         switch wich{ni}
             case 'B'
               ub(index(:,2)==max(index(:,2))) = 10^4;  
             case 'U'
               ub(index(:,2)==min(index(:,2))) = 10^4;
             case 'L'
               ub(index(:,1)==min(index(:,1))) = 10^4;
             case 'R'
               ub(index(:,1)==max(index(:,1))) = 10^4;
         end
     end
 end
 lb = [lb ;lb];
 ub = [ub ;ub];
