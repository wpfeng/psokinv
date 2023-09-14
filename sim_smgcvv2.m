function [smest disf dismodel cinput isabc abc osim input abic L] = sim_smgcvv2(matfile,inf,alpha,px,py,l,w,minscale,bdconts)%
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
tmpabc= mat.abcsm{1};
abc   = [];
%
for ni = 1:numel(tmpabc)
    a = tmpabc(ni).a;
    b = tmpabc(ni).b;
    c = tmpabc(ni).c;
    tmp = [a,b,c];
    abc = [abc,tmp];
end
    
%
alpha       = alpha(1):alpha(3):alpha(2);
nalpha      = numel(alpha);
smest       = zeros(nalpha,3);
nalpha      = numel(alpha);
smest       = zeros(nalpha,3);
dismodel    = cell(nalpha,1);
abic        = zeros(nalpha,1);
osim        = dismodel;
isabc       = 0;
%
%disfpara,input,G,lap,lb,ub,am,cinput
dips    = 50;
abic    = zeros(1,5);
counter = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[disf,input,tG,lap,lb,ub,am,cinput] = sim_pre4smest(fpara,inf,px,py,l,w,bdconts,abc,0);
%
iD      = input(:,3);
tmpD    = cell(10,4);
for k = 1:10
   is   = sim_rig(1,numel(iD),fix(numel(iD)/10));
   inds = 1:numel(iD);
   isds = inds.*0+1;
   for nk = 1:numel(is)
       isds(inds==is(nk)) = 0;
   end
   ns   = inds(isds==1);
   tmpD{k,1} = iD(is);
   tmpD{k,2} = iD(ns);
   tmpD{k,3} = is;
   tmpD{k,4} = ns;
end

for ndip = 1:numel(dips);
 fpara(4) = dips(ndip);
 [disf,input,tG,lap,lb,ub,am,cinput] = sim_pre4smest(fpara,inf,px,py,l,w,bdconts,abc,0);
 %
 disp(['No DIP: ' num2str(dips(ndip)) ' Models!']);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %options = optimset('LargeScale','on');
 disp(['Now the estimation work is beginning.' num2str(nalpha) ' Loops!']);
for ni =1:nalpha
    counter      = counter+1;
    smest(ni,1)  = alpha(ni);
    %pi    = 3.14159265;
    %[N,M] = size(tG);
    %cvssith = 0;
    L       = [lap lap.*0;lap.*0 lap];
    cvss    = 0;
    for nk = 1:10
     cD = tmpD{nk,2};
     cG = tG(tmpD{nk,4},:);
     if minscale == 0
         A      = [cG;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap];
         AA     = [cG;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap];
         D      = [cD;lap(:,1).*0;lap(:,1).*0];
     else
         slips  = cG(1,:).*0+1;
         slips  = slips.*minscale;       
         A      = [cG;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap;slips];
         AA     = [cG;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap,;slips];
         D      = [cD;lap(:,1).*0;lap(:,1).*0;0];
     end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %aslip  = lsqlin(A,D,[],[],[],[],lb,ub,[],options);
        aslip   = ((cG'*cG+alpha(ni).*L))\cG'*cD;
%%%%%%%%%%%%%%&&&&& CV %%%%%%%%%%%%%%%%%%%%
        nG      = tG(tmpD{nk,3},:);
        nD      = iD(tmpD{nk,3},:);
        f0      = (nD-nG*aslip).^2./alpha(ni);%+(aslip'*L*aslip);
        %f1     = iD-(tG/(tG'*tG+(L'*L))*tG'*iD);
        %f2      = (1-trace(tG/(tG'*tG+alpha(ni)*(L'*L))*tG'));
        cvss    = cvss+sum(f0);
        disp(['K-fold: ' num2str(nk) ' Fininshed!']);
    end
    abic(counter,2)   = alpha(ni);
    abic(counter,1)   = fpara(4);
    abic(counter,3)   = cvss;%sum((f1./f2).^2);
    smest(counter,2)  = norm(tG*aslip-input(:,3));
    smest(counter,3)  = aslip'*L*aslip;
    dismodel{counter} = aslip;
    osim{counter}     = tG*aslip;
    disp(['The ' num2str(ni) ' Loop has been finished!']);
 end
end
