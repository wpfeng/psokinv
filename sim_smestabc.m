function [smest disf dismodel m dm cinput isabc abc osim input] = sim_smestabc(matfile,inf,alpha,px,py,l,w,minscale,bdconts)%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Name: sim_smest
%

mat   = load(matfile); 
fpara = mat.outfpara{1};
abc   = mat.abcm{1};
%
[disf,input,G,lap,lb,ub,am,cinput,vcm] = sim_pre4smest(fpara,inf,px,py,l,w,[],abc,1);
alpha                    = alpha(1):alpha(3):alpha(2);
nalpha                   = numel(alpha);
smest                    = zeros(nalpha,3);
dismodel                 = cell(nalpha,1);
isabc                    = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = optimset('LargeScale','on');
disp(['Now the estimation work is beginning.' num2str(nalpha) ' Loops!']);
ninput = numel(cinput);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m = size(G,2);
dm= ninput*3;
% m
for nj=1:ninput
    am(:,(nj-1)*3+1) = am(:,(nj-1)*3+1)./10000;
    am(:,(nj-1)*3+2) = am(:,(nj-1)*3+2)./10000;
end
abc          = cell(1,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
npara = size(G,2);
L     = zeros(npara);
indstr= 0;
for ni=1:numel(lap)
    tlap = lap{ni};
    cdim = size(tlap,1);
    L(indstr+1:indstr+cdim,indstr+1:indstr+cdim) = tlap;
    indstr = indstr+cdim;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W = chol(inv(vcm));  % Based on the Wright's paper,2004

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ni =1:nalpha
    smest(ni,1)  = alpha(ni);
    A            = [G;alpha(ni).*L];
    [n,m]        = size(A);
    [dn,dm]      = size(am);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AA                = zeros(n,m+dm);
    AA(1:n,1:m)       = A;
    AA(1:dn,m+1:m+dm) = am;
    np                = size(AA,1);
    rp                = size(input,1);
    if np>rp
        D = [input(:,3);zeros(np-rp,1)];
    else
        D = input(:,3);
    end
    if minscale ~=1
       AA = [AA;AA(1,:).*minscale];
       D  = [D;0];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Am           = size(AA,1);
    Wm           = size(W, 1);
    if Am>Wm
       NW = ones(Wm,Am);
       NW(1:Wm,1:Wm) = W;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    aslip        = lsqlin(NW*AA,NW*D,[],[],[],[],lb,ub,[],options);
    smest(ni,2)  = norm(input(:,3)-[G am]*aslip);
    smest(ni,3)  = aslip(1:m)'*[lap lap.*0;lap.*0 lap]*aslip(1:m);
    dismodel{ni} = aslip;
    abc{ni}      = aslip(m+1:m+dm);
    disp(['The ' num2str(ni) ' Loop has been finished!']);
end
