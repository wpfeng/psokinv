%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%function sim_invnfault(invf,logfile)
%
% Purpose:
%       inversion main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Varibles you must change based on your need.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ntimes = 50;
global input fpara Inv index locals alpha symbols
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('*****************************************');
disp('The work is begun...');
disp('*****************************************');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the funcs into the system path.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
invf = 'wenchuan.inp';
if exist(invf,'file')==0
    disp(['! Sorry. CONFIGURE file, ' invf ' is not found...']); 
    return
else
    disp(['CONFIGURE file, ' invf ' has been found...']);
end
disp('*****************************************');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[psoPS,insfile,symbols,outoksar,outmatf,fpara,lamda,...
                       myu,scamin,scamax,Inv,locals] = ...
                       sim_readconfig(invf);
%
alpha = lamda/(lamda+myu);
index = find(Inv==1);
npara = numel(index);
scale = zeros(npara,2);
scale(:,1) = scamin(index);
scale(:,2) = scamax(index);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nf    = size(insfile,1);
input = [];
for ni=1:nf
    if exist(invf,'file')==0
       disp(['! Sorry. Observation file, ' insfile{ni} ' is not found...']); 
       return
    else
       disp(['Observation file, ' insfile{ni} ' has been found...']);
       data  = load(insfile{ni});
       input = [input;data];
    end
   
end
disp(['There will be about ' num2str(size(input,1)) ' Points for inversion...']);
disp('*****************************************');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the options for simplex algorithm.
simplexoptions = optimset('TolFun',1.E-1,'Display','iter','MaxIter',10000); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.iterations = 20;
outfpara           = cell(ntimes);
%
for ni=1:ntimes
  [x fval xsimp fvalsimp] ...
                          = pso_afwpIIII(@sim_obj,scale,psoPS,options,simplexoptions);
  [fpara objv]            = sim_obj_oksar_SLIPALP(xsimp);
  outfpara{ni}            = fpara;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim_fpara2oksar(fpara,outoksar);
if fpara(8) > 0  
   lb(1) = 0;
   ub(1) = fix(fpara(8))+2;
else
   lb(1) = fix(fpara(8))-2;
   ub(1) = 0;
end
if fpara(9) > 0  
   lb(2) = 0;
   ub(2) = fix(fpara(9))+2;
else
   lb(2) = fix(fpara(9))-2;
   ub(2) = 0;
end

%[disfpara,osim] = sim_distLS1fault(fpara,input,1,1,20,20,[0.1,0],lb,ub,[]);
%res{ni,2} = disfpara;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eval(['save ' outmatf ' outfpara']);
end


   
