function [lap,L] = sim_fpara2lap(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 % Created by Feng, Wanpeng, 2009
 %
 % whos fpara
 index = sim_fpara2sort(fpara);
 n     = max(index(:,1));
 m     = max(index(:,2));
 tnum  = m*n;
 lap   = zeros(tnum);
 for nor=1:n
     for noj=1:m
         nol = (nor-1)*m+noj;
         if nor ==1
            lap(nor*m+noj,nol)       = lap(nor*m+noj,nol)+(-1);
            lap((nor-1)*m+noj,nol)   = lap((nor-1)*m+noj,nol)+(1);
         end
         if nor ==n
            lap((nor-2)*m+noj,nol)   = lap((nor-2)*m+noj,nol)+(-1);
            lap((nor-1)*m+noj,nol)   = lap((nor-1)*m+noj,nol)+1;
         end
         if nor~=n && nor ~=1
            lap(nor*m+noj,nol)       = lap(nor*m+noj,nol)+(-1);
            lap((nor-2)*m+noj,nol)   = lap((nor-2)*m+noj,nol)+(-1);
            lap((nor-1)*m+noj,nol)   = lap((nor-1)*m+noj,nol)+2;
         end
         %%%
         if noj ==1
            lap((nor-1)*m+noj+1,nol) = lap((nor-1)*m+noj+1,nol)+(-1);
            lap((nor-1)*m+noj,nol)   = lap((nor-1)*m+noj,nol)+1;
         end
         if noj ==m
            lap((nor-1)*m+noj-1,nol) = lap((nor-1)*m+noj-1,nol)+(-1);
            lap((nor-1)*m+noj,nol)   = lap((nor-1)*m+noj,nol)+1;
         end
         if noj~=m && noj ~=1
            lap((nor-1)*m+noj+1,nol) = lap((nor-1)*m+noj+1,nol)+(-1);
            lap((nor-1)*m+noj-1,nol) = lap((nor-1)*m+noj-1,nol)+(-1);
            lap((nor-1)*m+noj,nol)   = lap((nor-1)*m+noj,nol)+2;
         end
         
     end
 end
 L = [lap lap.*0;lap.*0 lap];
             
