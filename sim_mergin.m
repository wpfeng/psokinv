function [am,index,noind] = sim_mergin(cinput,abccof)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Purpose: 
 % create the matrix including (x,y,1) for the inverison of a,b,c.
 %%%%%%%%%
 % Output:
 %     coefficient matrix for inversion of the offsets or orbit ramps 
 %                 in default, none of them will be returned...
 %
 %     index, the index of the data set which will be inverted ab or abc
 %     or c only
 %     noind, the index of the data set which will not be inverted abc.
 %
 % The number of the data set we need estimate the orbit error and offsets
 % Created by Feng, W.P, @IGP/CEA, wanpeng.feng@hotmail.com
 % 
     index = find(abccof(:,2)==1);
     noind = find(abccof(:,2)~=1);
     am = [];
     for ni = 1:numel(index)
         finput   = cinput{index(ni)};
         input    = sim_inputdata(finput{1});
         tmp_1    = [];
         tmp_2    = [];
         if abccof(index(ni),3)==1
            tmp_1 = input(:,1:2);
         end
         if abccof(index(ni),4)==1
            tmp_2 = input(:,1).*0+1;
         end
         tmp      = [tmp_1 tmp_2];
         %
         %
         [n,m]   = size(am);
         [dn,dm] = size(tmp);
         data    = zeros(n+dn,m+dm);
         if n > 0 && m >0
            data(1:n,1:m) = am;
         end
         data(n+1:n+dn,m+1:m+dm) = tmp;
         am                      = data;
         
     end
 
         
     
