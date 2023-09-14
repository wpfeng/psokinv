function [trif,Lapm,lbs,lbd,ubs,ubd,info,rfpara] = sim_pre4triest(fpara,l,w,dl,dw,maxarea,topdepth)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% 
% Created by W.P, Feng, July-30-2010
% part of TRIANGULAR inversion model...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 6
   maxarea = 5;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rfpara = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
for ni = 1:size(fpara(1:end,:),1);
    tfpara = fpara(ni,:);
    tfpara = sim_fpara2whole(tfpara);
    rfpara = [rfpara;sim_fpara2dist(tfpara,l(ni),w(ni),dl(ni),dw(ni),'d')];
end
%
[trif,~,info]     = sim_tri(rfpara,'maxlength',max([dl;dw]).*3.0,'maxarea',maxarea,'isshow',0);
[Lapm,lbs,lbd,ubs,ubd] = sim_trif2lap(trif,topdepth);
lbs = lbs.*0;
lbd = lbd.*0;
ubs = (abs(ubs) == min(abs(ubs))).*0 + ...
    (abs(ubs) >  min(abs(ubs))).*1000;
ubd = (abs(ubd) == min(abs(ubd))).*0 + ...
    (abs(ubd) >  min(abs(ubd))).*1000;
