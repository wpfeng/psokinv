function sim_mcDTnoise(fpara,perts,prefix,vcm,output,smpara,whichnon,onlyres)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% +Name: sim_mcDTnoise, sim series function. Based MC method to analysis
% the uncertainty(noise) of Distributed Slip Model
%
% Input:
%      fpara, the distributed slip model, should be optimal geometry 
%      perts, the directory to save the simulation observation by MC
%      prefix, the prefix you will use to search the files.
%      vcm,   the variance-covariance matrix to the observation
%      smpara, the smooth weight parameter, you should have got one by
%              ps_smest
%      output, the outname for the result
% OUTPUT:
%      the bestModel for each observation data
%      the uncertainty of the slip in 2D, along the strike and dip
%      seperately.
%
if nargin<6
   disp('sim_mcDTnoise(fpara,perts,prefix,vcm,output,smpara,whichnon)');
   disp('!!! You must input the foregoing 6 parameters!');
   
   return
end
if nargin<7 || isempty(whichnon)==1
   whichnon = [];
end
if nargin<8
   onlyres = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vcm     = load(vcm);
vcm     = vcm.vcm;
W       = chol(inv(vcm));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lap     = sim_fpara2lap(fpara);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s_slip  = [min(fpara(:,8)),max(fpara(:,8))];
d_slip  = [min(fpara(:,9)),max(fpara(:,9))];
[lb,ub] = sim_fpara2constraint(fpara,s_slip(1),...
                                     d_slip(1),...
                                     s_slip(2),...
                                     d_slip(2),...
                                     whichnon);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
files   = dir(fullfile(perts,['*' prefix '*']));
names   = files(1).name;
file1   = fullfile(perts,names);
data1   = sim_inputdata(file1);
G       = sim_oksargreenALP(fpara,data1,0.0,0.5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L       = zeros(size(G,2));
nd      = size(lap,1);
L(1:nd,1:nd)         = lap;
L(nd+1:end,nd+1:end) = lap;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A       = [W*G;smpara.*L];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slips   = zeros(1,size(fpara,1)*2);
if onlyres==0
    for ni = 1:numel(files)
        input = sim_inputdata(fullfile(perts,files(ni).name));
        np    = size(A,1);
        rp    = size(input,1);
        if np > rp
            D = [W*input(:,3);zeros(np-rp,1)];
        else
            D = W*input(:,3);
        end
        options = optimset('LargeScale','on');
        aslip   = lsqlin(A,D,[],[],[],[],lb,ub,[],options);
        slips(ni,:)= aslip;
        disp(['You have finished NO: ' num2str(ni) ' sets!!!']);
        %
    end
    uncert     = std(slips);
    unstrike   = fpara;
    undip      = fpara;
    unstrike(:,8) = uncert(1:end/2);
    unstrike(:,9) = 0;
    undip(:,9)    = uncert(end/2+1:end);
    undip(:,8)    = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AA           = [G;smpara.*L];                         %
%R            = ((G'*inv(vcm)*G)+smpara.*L)\G'/vcm*G;%G'/(G'*G)*G;    
R            = (AA'*AA)\G'*G;%
Goodness     = sum(sum((R-eye(size(R,1))).^2));       %
Cm           = inv(AA'*AA);  
%ri           = sum(abs(R),2);    
ri           = diag(R);%
fpara(:,8)   = 1./sqrt(ri(1:size(fpara,1)));     %
fpara(:,9)   = 1./sqrt(ri(size(fpara,1)+1:end));
smodel       = fpara;                                  
smodel(:,9)  = 0;
dmodel       = fpara;
dmodel(:,8)  = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if onlyres==0
   eval(['save ' output ' slips smodel dmodel unstrike undip L R Cm G AA A']); 
else
   eval(['save ' output ' slips smodel dmodel L R Cm Goodness G AA A']); 
end
%

