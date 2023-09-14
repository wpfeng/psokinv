function [smest disf dismodel cinput isabc abc] = sim_merest(matfile,inf,alpha,px,py,l,w,noise,nrand)%
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
%disfpara,input,G,lap,lb,ub,am,cinput
[disf,input,G,lap,lb,ub,am,cinput] = sim_pre4smest(fpara,inf,px,py,l,w,[],abc,0);
alpha                    = alpha(1):alpha(3):alpha(2);
nalpha                   = numel(alpha);
smest                    = zeros(nrand,nalpha,3);
dismodel                 = cell(nrand,nalpha,1);
isabc                    = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = optimset('LargeScale','on');
disp(['Now the estimation work is beginning.' num2str(nalpha) ' Loops!']);
for nj=1:nrand
    inps = input(:,3);
    inps = inps+(rand(numel(inps),1).*2-1).*noise;
  for ni =1:nalpha
      smest(nj,ni,1)  = alpha(ni);
      A            = [G;alpha(ni).*lap lap.*0;lap.*0 alpha(ni).*lap];
      D            = [inps;lap(:,1).*0;lap(:,1).*0];
      aslip        = lsqlin(A,D,[],[],[],[],lb,ub,[],options);
      smest(nj,ni,2)  = norm(G*aslip-inps);
      smest(nj,ni,3)  = aslip'*[lap lap.*0;lap.*0 lap]*aslip;
      dismodel{nj,ni} = aslip;
      %disp(['The ' num2str(ni) ' Loop has been finished!']);
  end
  disp(['The ' num2str(nj) ' Loop has been finished!']);
end
