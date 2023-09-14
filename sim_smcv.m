function [smest disf dismodel cinput isabc abc osim input abic] = sim_smcv(matfile,inf,alpha,px,py,l,w,minscale,bdconts)%
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
dips = 50;
abic = zeros(1,5);
counter = 0;
for ndip = 1:numel(dips);
 fpara(4) = dips(ndip);
 [disf,input,tG,lap,lb,ub,am,cinput] = sim_pre4smest(fpara,inf,px,py,l,w,bdconts,abc,0);
 %
 disp(['No DIP: ' num2str(dips(ndip)) ' Models!']);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 options = optimset('LargeScale','on');
 disp(['Now the estimation work is beginning.' num2str(nalpha) ' Loops!']);
for ni =1:nalpha
    counter      = counter+1;
    smest(ni,1)  = alpha(ni);
    pi    = 3.14159265;
    [N,M] = size(tG);
    iN    = 1:N;
    cvssith = 0;
    for npoints = 1:10
        disp(['Iteration: ' num2str(npoints) ' Time!']);
        ns    = sim_rig(1,N,fix(N*0.1));
        TempN = iN.*0+1;
        TempN(ns) = 0;
        is    = iN(TempN==1);
        %is    = iN(iN~=ns);
        G     = tG(is,:);
        nG    = tG(ns,:);
        iD    = input(is,3);
        nD    = input(ns,3);
        %
        L     = [lap lap.*0;lap.*0 lap];
        if minscale == 0
           A            = [G;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap];
           AA           = [tG;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap];
           D            = [iD;lap(:,1).*0;lap(:,1).*0];
        else
           slips        = G(1,:).*0+1;
           slips        = slips.*minscale;       
           A            = [G;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap;slips];
           AA           = [tG;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap,;slips];
           D            = [iD;lap(:,1).*0;lap(:,1).*0;0];
        end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %aslip        = lsqlin(A,D,[],[],[],[],lb,ub,[],options);
        %aslip        = inv((G'*G+alpha(ni)*(L'*L)))*G'*iD;
        aslip        = inv((G'*G+alpha(ni).*L))*G'*iD;
%%%%%%%%%%%%%%&&&&& CV %%%%%%%%%%%%%%%%%%%%
        eYi          = nG*aslip;
        deYi         = (nD-eYi);
        %roughness    = abs(aslip)'*L*abs(aslip);
        %
       %Hp            = tG*inv(tG'*tG+alpha(ni).*(L'*L))*tG';
       Hp            = tG*inv(tG'*tG+alpha(ni).*L)*tG';
       ithOrth       = zeros(numel(ns),1);
       for inp=1:numel(ns)
           ithOrth(inp) = Hp(ns(inp),ns(inp));
       end
       %
       cvssith   = cvssith+sum(((deYi./(1-ithOrth)).^2));
    end
    abic(ni,2)   = alpha(ni);
    abic(ni,1)   = ndip;
    abic(ni,3)   = cvssith;
    smest(ni,2)  = norm(tG*aslip-input(:,3));
    smest(ni,3)  = aslip'*[lap lap.*0;lap.*0 lap]*aslip;
    dismodel{ni} = aslip;
    osim{ni}     = tG*aslip;
    disp(['The ' num2str(ni) ' Loop has been finished!']);
 end
end
