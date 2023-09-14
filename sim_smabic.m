function [smest disf dismodel G isabc abc osim input abic L] = sim_smabic(matfile,inf,alpha,px,py,l,w,minscale,bdconts)%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Name: sim_smest
%
format long eng
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
dips = 45:2:60;
dips = 50;
abic = zeros(1,5);
counter = 0;
for ndip = 1:numel(dips);
 fpara(4) = dips(ndip);
 [disf,input,G,lap,lb,ub,am,cinput] = sim_pre4smest(fpara,inf,px,py,l,w,bdconts,abc,0);
 %
 disp(['No DIP: ' num2str(dips(ndip)) ' Models!']);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 options = optimset('LargeScale','on');
 disp(['Now the estimation work is beginning.' num2str(nalpha) ' Loops!']);
 obv  = input(:,3);
for ni =1:nalpha
    counter      = counter+1;
    smest(ni,1)  = alpha(ni);
    if minscale == 0
       A            = [G;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap];
       D            = [obv;lap(:,1).*0;lap(:,1).*0];
    else
       slips        = G(1,:).*0+1;
       slips        = slips.*minscale;       
       A            = [G;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap;slips];
       D            = [obv;lap(:,1).*0;lap(:,1).*0;0];
    end
    %
    
    L     = [lap lap.*0;lap.*0 lap];
    %aslip        = lsqlin(A,D,[],[],[],[],lb,ub,[],options);
    aslip        = (G'*G+alpha(ni).*L)\G'*obv;
    %%%%%%%%%%%%%%&&&&& ABIC %%%%%%%%%%%%%%%%%%%%
    pi    = 3.14159265;
    [N,M] = size(G);

%%%%% Tim J. Wright 2008, GJI %%%%%%
%%%%%
    fs    =((obv-G*aslip)'*(obv-G*aslip))+...
            alpha(ni)*(abs(aslip)'*L*abs(aslip));
    P     = rank(L);
    term_1            = eig(alpha(ni).*(L'*L));
    term_1(term_1==0) = [];
    term_2            = eig(G'*G+alpha(ni).*(L'*L));
    term_2(term_2==0) = [];
    abicv             = (N+P-M)*log(fs)-P*log(alpha(ni))-log(norm(term_1))+log(norm(term_2));
    %-P*log(alpha(ni))
    %
    %abicv = N*log(fs)-log(abs(det(alpha(ni).*(L'*L))))+log(abs(det(G'*G+alpha(ni).*(L'*L))));
    %abicv = N*log(fs)-log(abs(trace(alpha(ni).*L)))+log(abs(trace(G'*G+alpha(ni).*L)));

    abic(counter,3) = abicv;%-2*log(pdf);
    abic(counter,1) = fpara(4);
    abic(counter,2) = alpha(ni);
    abic(counter,4) = ((obv-G*aslip)'*(obv-G*aslip));
    abic(counter,5) = abs(aslip)'*L*abs(aslip);%((L*abs(aslip))'*(L*abs(aslip)));
%%%% Funning Thesis %%%%
% sa = (obv-G*aslip)'*(obv-G*aslip)+alpha(ni)*(aslip'*(L'*L)*aslip);
% abic(ni) = N*log(sa)-log(abs(det(alpha(ni)*(L'*L))))+log(abs(det((G'*G+alpha(ni)*(L'*L)))));
%%%%%%%%%%%%%%%%%%%%%%%%
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    smest(counter,2)  = norm(G*aslip-obv);
    smest(counter,3)  = aslip'*[lap lap.*0;lap.*0 lap]*aslip;
    dismodel{counter} = aslip;
    osim{counter}     = G*aslip;
    disp(['The ' num2str(ni) ' Loop has been finished!']);
 end
end
