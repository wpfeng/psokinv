function out = sim_smtrif(trif,data,vcm,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Batch Test trif model (elastic triangle dislocation)
%
if nargin<3
   disp('sim_smtrif(trif,dataf,vcmf,varargin)');
end
% trif  = '';
% vcmf  = '';
% dataf = '';
% data  = sim_inputdata(dataf);
% vcm   = load(vcmf);
% vcm   = vcm.vcm;
% fpara = load(trif);
% trif  = fpara.trif;
mins  = [-5,0];
maxs  = [5,5];
alpha = [0.1,1];
niters= 10;
pr    = 0.25; % possion's ratio
isdisp= 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v = sim_varmag(varargin);
for j = 1:length(v)
    eval(v{j});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

W     = chol(inv(vcm));
%%%%%%%%%%%% 
disp('Now calculating Green matrix...');
[Gs,Gd,Gt,G]          = sim_trif2G(trif,data,pr);
disp('Now Green Matrixes have been created!');
[lap,lbs,lbd,ubs,ubd] = sim_trif2lap(trif);
disp('Now Lalacian Matrix has been created!');
malpha                = linspace(alpha(1),alpha(2),niters);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lbs(lbs==-1) = mins(1);
lbd(lbd==-1) = mins(2);
lb           = [lbs; lbd];
%%%
ubs(ubs==1)  = maxs(1);
ubd(ubd==1)  = maxs(2);
ub           = [ubs;ubd];
%ub(ub==1)  = maxs;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smest      = zeros(numel(malpha),3);
mslip      = cell(numel(malpha),1);
mtrif      = mslip;
for nalpha =1:numel(malpha);
    alpha = malpha(nalpha);
    L     = [lap lap.*0;lap.*0 lap];
    A     = [W*G ; alpha.*L];
    ndim  = size(A,1);
    D     = zeros(ndim,1);
    D(1:numel(data(:,1)))     = W*data(:,3);
    %
    options = optimset('LargeScale','on','display','off');
    aslip   = lsqlin(A,D,[],[],[],[],lb',ub',[],options);
    mslip{nalpha}    = aslip;
    smest(nalpha,1)  = alpha;
    smest(nalpha,2)  = norm(W*(G*aslip-data(:,3)));
    smest(nalpha,3)  = sum(abs(L*aslip))/numel(aslip);
    disp(['NOW it is NO: ' num2str(nalpha) ' times!']);
end
for ni=1:nalpha
    aslip  = mslip{ni};
    slip_s = aslip(1:end/2);
    slip_d = aslip(end/2+1:end);
    %
    for nj=1:numel(trif)
        trif(nj).ss = slip_s(nj);
        trif(nj).ds = slip_d(nj);
    end
    mtrif{ni} = trif;
end
if isdisp==1
    figure;
    sim_trifshow(trif,'strike');
    figure;
    sim_trifshow(trif,'dip');
    figure;
    plot(smest(:,3),smest(:,2),'*-r');
end
out.trif = trif;
out.smest= smest;
out.mtrif= mtrif;
