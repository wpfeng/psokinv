function [osim,stdv,rms,input] = sim_siminp(fpara,inp,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng, W.P., @ BJ, 2010/05/01
% Improved by Feng, W.P., @ GU, 2011/10/25
% Improved by Feng,W.P., @ Glasgow, 2012/09/08
%
%
if nargin < 1
   disp('stdv = sim_checkinp(fpara,inp,isplot)');
   stdv = [];
   return
end
if nargin < 3
    isplot=0;
end
%
if ischar(fpara)
   fpara = sim_openfault(fpara);
end
%%
% Modified by Feng, W.P., @ Glasgow, 2012-09-08.
% "inp" can be the vector of observations as well in this new version...
%
if isnumeric(inp)==0
  input = sim_inputdata(inp);
  [tmp,bname] = fileparts(inp);
else
  input = inp;
  bname = 'inp';
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dis  = multiokadaALP(fpara,input(:,1),input(:,2));
osim = dis.E.*input(:,4) + dis.N.*input(:,5) + dis.V.*input(:,6);
stdv = std(input(:,3)-osim); 
%

