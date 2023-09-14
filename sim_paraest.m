function [sigma,mu,a] = sim_paraest(fpara,ndix,samples,isfigs)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if nargin <=2 || isempty(samples)==1
    samples = 100;
 end
 if nargin <=3 || isempty(isfigs)==1
    isfigs = 0;
 end
 [yout,xout]  = hist(fpara(:,ndix),samples);
 xout         = xout(:);
 yout         = yout(:);
 [sigma,mu,a] = sim_gaussianfit(xout,yout);
 ynew         = a.*exp(-(xout-mu).^2./(2*sigma^2));
 %
 if isfigs==1
    hist(fpara(:,ndix),samples);
    hold on
    plot(xout,yout,'o-r');
    hold on
    plot(xout,ynew,'o-b');
    legend({'Obv','Est'});
 end
 
 
