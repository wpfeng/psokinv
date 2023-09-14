function outv = sim_working4obj(fpara,type,xory)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 %
 if numel(fpara(1,:))<=10
    cfpara = zeros(1,10);
    cfpara(1:7) = fpara(1:7);
    fpara = cfpara;
 end
 
 incoor  = 'UTM';
 outcoor = 'UTM';
 outzone = '30 T';
 %
 [x,y,z] = sim_fpara2corners(fpara,type,incoor,outcoor,outzone);
 if xory==1
    outv = x;
 end
 if xory==-1
     outv = y;
 end
 if xory==0
    outv = z;
 end
