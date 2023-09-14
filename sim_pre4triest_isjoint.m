function [trif,Lapm,lbs,lbd,ubs,ubd,info,rfpara] = sim_pre4triest_isjoint(fpara,l,w,dl,dw,maxarea,topdepth,isjoint)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% 
% Created by W.P, Feng, July-30-2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 6
   maxarea = 5;
end
if nargin < 8
    isjoint = 1;
end
if isjoint==0
   isjoint = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [trif,Lapm,lbs,lbd,ubs,ubd,info,rfpara] = sim_pre4triest(fpara(isjoint:end,:),...
                                           l(isjoint:end),w(isjoint:end),dl(isjoint:end),...
                                           dw(isjoint:end),maxarea,topdepth);
if isjoint > 1
   temptrif   = cell(1);
   tempLapm   = temptrif;
   templbs    = [];
   templbd    = [];
   tempubs    = [];
   tempubd    = [];
   tempinfo   = temptrif;
   temprfpara = temptrif;
   counter    = zeros(isjoint-1,1);
   for ni=1:isjoint-1
       [temptrif{ni},tempLapm{ni},itemplbs,itemplbd,itempubs,...
                     itempubd,tempinfo{ni},temprfpara{ni}] = sim_pre4triest(fpara(ni,:),...
                                           l(ni),w(ni),dl(ni),...
                                           dw(ni),maxarea,topdepth);
       templbs     = [templbs;itemplbs];
       templbd     = [templbd;itemplbd];
       tempubs     = [tempubs;itempubs];
       tempubd     = [tempubd;itempubd];
       counter(ni) = numel(itemplbs);
   end
   tempinfo{ni+1}   = info;
   temprfpara{ni+1} = rfpara;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   L = zeros(sum(counter));
   itrif = [];
   for ni=1:isjoint-1
       if ni == 1
          istart = 0;
       else
          istart = counter(ni-1);
       end
       L(istart+1:counter(ni)+istart,istart+1:counter(ni)+istart) = tempLapm{ni};
       itrif = [itrif temptrif{ni}];
   end
   trif = [itrif trif];
   iL   = zeros(size(L,1)+size(Lapm,1));
   iL(1:size(L,1),1:size(L,1)) = L;
   iL(size(L,1)+1:end,size(L,1)+1:end) = Lapm;
   Lapm      = iL;
   lbs       = [templbs;lbs];
   lbd       = [templbd;lbd];
   ubs       = [tempubs;ubs];
   ubd       = [tempubd;ubd];
   info      = tempinfo;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   rfpara    = temprfpara;
       
end    
