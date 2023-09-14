function [fmoment,mo,mw,mo2,mw2] = sim_fpara2moment(fpara,mu,depth,factor)
%
%************** FWP Work ************************
% Developed by FWP, @UoG/BJ, 2007-2014
% contact at wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by FWP, @IGP/CEA, BJ, 2008/10
% mw = 2/3*log10(mo)-6.033;
% 
 if nargin<1 || isempty(fpara)==1
    %
    disp('sim_fpara2moment(fpara,mu)');
    disp('-----------------------------------------------------');
    disp('  fpara, the source model in m*10,m is number of subfaults;');
    disp('     mu, the elastic coefficent,default is 3.23*10^10');
    disp('-----------------------------------------------------');
    disp('Author: Feng W.P, Institute of Geophysics, CEA');
    disp('eMail:  skyflow2008@hotmail.com');
    disp('The time last modified: 5 June 2009');
    return
 end
 if nargin < 4
     factor = 1;
 end
 %
 %
 if nargin<2 || isempty(mu) ==1
     mu = 3.23e10;
 end
 %
 nfault      = size(fpara,1);
 fmoment     = zeros(nfault,2);
 %
 fpara(:,8)  = fpara(:,8) * factor;
 fpara(:,9)  = fpara(:,9) * factor;
 fpara(:,10) = fpara(:,10) * factor;
 %
 for nf  = 1:nfault
     %
     a   = fpara(nf,6) * fpara(nf,7) * 10^6;
     s   = sqrt(fpara(nf,8)^2 + fpara(nf,9)^2 + fpara(nf,10)^2);
     fmoment(nf,1) = mu*a*s;
     fmoment(nf,2) = (fmoment(nf,1)~=0)*(2/3)*log10(fmoment(nf,1))-6.033+(fmoment(nf,1)==0)*0;
     fmoment(nf,3) = mu*a*(abs(fpara(nf,8))+abs(fpara(nf,9)));
     fmoment(nf,4) = (2/3)*log10(fmoment(nf,3))-6.033;
 end
 mo  = sum(fmoment(:,1));
 mw  = (2/3)*log10(mo)-6.033;
 mo2 = sum(fmoment(:,3));
 mw2 = (2/3)*log10(mo2)-6.033;
%
if nargin == 3
    %
    cfpara     = fpara(fpara(:,5)<=depth,:);
    [t_mp,mo1] = sim_fpara2moment(cfpara);
    disp([' PRESENT: ',num2str(mo1/mo,'%5.4f')]);
    %
end