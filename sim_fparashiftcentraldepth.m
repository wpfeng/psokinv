function sim_fparashiftcentraldepth(inoksar,outoksar,sdepth,isplot)
%
% 
% Developed by Feng, W.P., @ EOS of NTU, Singapore, 2015-06-25
%
if nargin < 4
    isplot = 1;
end
%
[~,~,bext] = fileparts(inoksar);
%
switch upper(bext)
    case '.OKSAR'
        [fpara,zone] = sim_oksar2SIM(inoksar);
    case '.SIMP'
        [fpara,zone] = sim_simp2fpara(inoksar);
end
if isplot==1
    %
    sfpara    = fpara;
    sfpara(8) = 10;
    sfpara(9) = 0;
    sim_fig3d(sfpara,1,[],'edgecolor',[0,1,0]);
end
%
cwid      = abs(sdepth)./sind(fpara(4)).*2;
cfpara    = sim_fparaconv(fpara,0,3);
cfpara(6) = cwid;
cfpara    = sim_fparaconv(cfpara,3,0);
%
if sdepth > 0
   %
   % meaning moving upward...
   %
   cfpara(6)  = fpara(6);
   ofpara     = sim_fparaconv(cfpara,3,0);
else
   %
   % meaning moving downward...
   %
   cfpara     = sim_fparaconv(cfpara,0,13);
   cfpara(6)  = fpara(6);
   ofpara     = sim_fparaconv(cfpara,3,0);
end
sim_fpara2oksar(ofpara,outoksar,zone);
%
if isplot==1
    %
    sfpara = ofpara;
    sfpara(8) = 20;
    sfpara(9) = 0;
    hold on
    sim_fig3d(sfpara,1,[],'edgecolor',[0,1,1]);
    %
end
%
