function [m1,m2,m3] = sim_trif2moment(trif,mu)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Calculate the seismic momonet of the triangular source models
 % Based on the following formular, return the magnitudes.
 %     mw = 2/3*log10(mo)-6.033;
 % Writed by Feng, W.P, fengwp@cea-igp.ac.cn
 % Modified at 2010-08-10
 %
 if nargin < 1
    disp('sim_trif2moment(trif,mu)');
    disp('-----------------------------------------------------');
    disp('  trif, the triangular source model, a n*structure ;');
    disp('    mu, the elastic coefficent,default is 3.23*10^10');
    disp('-----------------------------------------------------');
    disp('Author: Feng W.P, Institute of Geophysics, CEA');
    disp('eMail:  skyflow2008@hotmail.com');
    disp('Modified at 2010-08-10');
    return
 end
 if nargin < 2
    mu = 3.23e10;
 end
 ntri = numel(trif);
 m1   = zeros(ntri,1);
 m2   = zeros(ntri,2);
 for ni=1:ntri
     trix  = trif(ni).x;
     triy  = trif(ni).y;
     triz  = trif(ni).z;
     P     = [trix(:) triy(:) triz(:)]; 
     P     = [P P(:,1)];
     %
     %areas = triangle_area(P,'h');
     areas = triangle_area(P);
     slip  = sqrt(trif(ni).ss^2+...
                  trif(ni).ds^2+...
                  trif(ni).ts^2);
        
     m1(ni)= mu*areas*10^6*slip;
     m2(ni)= 2/3*log10(m1(ni))-6.033;
 end
 %
 m3 = 2/3*log10(sum(m1(:)))-6.033;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % End of the function...
 
