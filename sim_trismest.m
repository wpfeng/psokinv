function [msmest trif input info rfpara] = sim_trismest(matfile,inf,alpha,px,py,l,w,minscale,bdconts,mdip)%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Name: sim_smest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Feng W.P, 2010/03/16
% Now the function supports psoksar format.
% Modified by Feng W.P, 2010/05/02
% Normalized wegiht of the input data.
% fengwp@cea-igp.ac.cn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modification history:
% FWP, 2010/11/16, now support to given rake angle
%
global cfgname dweight invmethod rakecons isjoint

[~,~,ext] = fileparts(matfile);
%
% bug fixed by Feng, W.P, 21/10/2011
% Current version, We have permitted to give oksar file so...
%
% if strcmpi('.mat',ext) == 1
switch ext
    case '.mat'
        mat   = load(matfile);
        std   = mat.outstd;
        indx  = find(std(:,1)==min(std(:,1)));
        fpara = mat.outfpara{indx(1)};
    case '.psoksar'
        fpara  = sim_psoksar2SIM(matfile);
    case '.oksar'
        fpara  = sim_oksar2SIM(matfile);
end
%
alpha   =  alpha(1):alpha(3):alpha(2);
attris  = {'Xcor','Ycor','Str','Dip','Dep','Wid','Len'};
disp('**************** Least Square Inversion *****************');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input observation data
[~,~,~,~,abccof]      = sim_readconfig(inf);
[input,am,cinput,vcm] = sim_sminpudata(inf);
W                     = chol(inv(vcm)).*repmat(dweight,1,size(vcm,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,basen] = fileparts(cfgname);
savedir   = [basen,'_TRIF'];
%
if exist(savedir,'dir')==0
   mkdir(savedir);
end
flag = 0;
for ni =1:numel(bdconts)
    flag = sum(sum(strcmpi(bdconts{1,ni},'u')))+flag;
end
if flag < 1 
   topdepth = 0.0001;
else
   topdepth = 4;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msmest  = cell(1,4);
for nag = 1:numel(mdip(:,1))
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('PS_SMEST(trif)-> Now created the triangular structure model. This work will take several minutes...');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check mat file...
    outmat = [basen,'DIP_',num2str(mdip(nag,3))];
    cpx = px;
    cpy = py;
    cl  = l;
    cw  = w;
    topinfo = [cpx,cpy,cl,cw];
    if exist(savedir,'dir') ~= 0 && exist([savedir,'/',outmat,'.mat'],'file') ~=0
        disp(['PS_SMEST(trif)-> The mat (' attris{mdip(nag,2)} ':'  num2str(mdip(nag,3)) ') has been found. Loading now...']);
        order = ['load ' savedir '/' outmat '.mat'];
        eval(order);
        cinfo = [px,py,cl,cw];
        % Modified by Feng,W.P, adapt the fault have multiple segments.
        % 2010-11-19
        %
        sumflag = 0;
        for nflag = 1:size(topinfo,1)
            sumflag = (sum(topinfo(nflag,:)==cinfo(nflag,:)) >=4) * 4 + ...
                      (sum(topinfo(nflag,:)==cinfo(nflag,:)) < 4) * 0+sumflag;
        end
        %
        if sumflag < 4
           disp('PS_SMEST(trif)-> Parameters have been changed. G will be reestimated now...(Model reference from BSSA,2007)');
        end
    else
        sumflag = 0;
        cinfo   = zeros(size(topinfo));
        for nflag = 1:size(topinfo,1)
            sumflag = (sum(topinfo(nflag,:)==cinfo(nflag,:)) >=4) * 4 + ...
                      (sum(topinfo(nflag,:)==cinfo(nflag,:)) < 4) * 0+sumflag;
        end
    end
    %
    if exist(savedir,'dir') == 0 || exist([savedir,'/',outmat,'.mat'],'file') ==0 || ...
       sumflag < 4
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       px = cpx;
       py = cpy;
       l  = cl;
       w  = cw;
       % Update the fault parameters by keywords constraints
       % FWP, 2010/11/16,adding some describing of functions
       fpara(mdip(nag,1),mdip(nag,2)) = mdip(nag,3);
       [trif,Lapm,lbs,lbd,ubs,...
            ubd,info,rfpara] = sim_pre4triest_isjoint(fpara,l,w,px,py,px(1)*py(1)*0.25,topdepth,isjoint);
       % whos trif
       lb = [lbs;lbd];
       ub = [ubs;ubd];
       L  = [Lapm Lapm.*0;Lapm.*0 Lapm];
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       disp('PS_SMEST(trif)-> Now create G matrix for slip inversion.(Model reference from BSSA,2007)');
       [~,~,~,G]  = sim_trif2G(trif,input,0.25);
       order      = ['save ' savedir '/' outmat '.mat input G L ub lb lbs lbd ubs ubd trif Lapm info rfpara px py l w'];
       eval(order);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    disp(['PS_SMEST(trif)-> The LSQ working now (' attris{mdip(nag,2)} ':' num2str(mdip(nag,3)) ') by ' upper(invmethod) ' (Total: ' num2str(numel(alpha)) ')']);
    smest  = zeros(numel(alpha),5);
    mslip  = cell(1,1);
    osim   = cell(1,1);
    mabc   = cell(1,3);
    %
    for nal = 1:numel(alpha)
        calpha = alpha(nal);
        %
        if size(W,2)==1
           W = diag(W);
        end
        A = [W*G;L./400.*calpha];
        if numel(am) > 0
           nam = size(am,1);
           nG  = size(A,1);
           Mam = zeros(nG,size(am,2));
           Mam(1:nam,:) = am;
           AA           = [A Mam];
        else
           AA  = A;
        end
        D      = [W*input(:,3);Lapm(:,1).*0;Lapm(:,1).*0];
        if numel(am) > 0
           nabc   = size(am,2);
           minabc = zeros(nabc,1)-100000;
           maxabc = zeros(nabc,1)+100000;
           LB     = [lb;minabc];
           UB     = [ub;maxabc];
        else
           LB     = lb;
           UB     = ub;
        end
        % If there is the constraint of minimum moment scale, formular will
        % be modified.
        ntrif = size(trif,2);
        if minscale ~=0
           %
           strZERO = AA(1,1:ntrif).*0;
           dipZERO = AA(1,ntrif+1:ntrif*2).*0;
           if size(AA,2) > ntrif*2
              others = AA(1,ntrif*2+1:end).*0;
           else
              others = [];
           end
           AA      = [AA;     minscale.*(strZERO + 1) dipZERO others;...
                      strZERO minscale.*(dipZERO + 1) others];
           D       = [D;0;0];
        end
        
        switch invmethod
            case 'lsqlin'
                options = optimset('LargeScale','on','display','off');
                aslipABC = lsqlin(AA,D,[],[],[],[],LB,UB,[],options);
            case 'bvls'
                aslipABC = bvls(AA,D,LB,UB);
            otherwise
                aslipABC = cgls_bvls(AA,D,LB,UB);
        end
        if numel(am) > 0
           aslip  = aslipABC(1:end-nabc);
           outabc = aslipABC(end-nabc+1:end);
        else
           aslip  = aslipABC;
           outabc = [];
           if rakecons(1)~=0
              slip1  = aslip(1:end/2);
              slip2  = aslip(end/2+1:end);
              s_slip = slip1 .* cosd(rakecons(1,2)) + ...
                       slip2 .* cosd(rakecons(1,3));
              d_slip = slip1 .* sind(rakecons(1,2)) + ...
                       slip2 .* sind(rakecons(1,3));
              Taslip  = [s_slip(:) ; d_slip(:)]; 
           end
        end
        smest(nal,1) = calpha;
        if numel(am) < 1
          smest(nal,2) = norm(W*(G*aslip-input(:,3)));
        else
          smest(nal,2) = norm(W*(G*aslip-input(:,3))-am*outabc);
        end
        smest(nal,3) = sum(abs(L*aslip))/numel(aslip);
        smest(nal,4) = 0;
        smest(nal,5) = mdip(nag,3);
        %%%%% add new function, permit rake constraints...
        %-----> Feng, W.P, modified at 15 Nov, 2010.
        %
        if rakecons(1)~=0
           mslip{nal} = Taslip;
        else
           mslip{nal} = aslip;
        end
        if numel(am)< 1
          osim{nal} = G*aslip;
        else
          osim{nal} = G*aslip+am*outabc;
        end
        mabc{nal,1}  = outabc;
        mabc{nal,2}  = cinput;
        mabc{nal,3}  = abccof;
        fprintf('%22s%3.0f%10s%6.4f%20s\n','PS_SMEST(trif)-> NO:', nal,'(ALPHA: ',alpha(nal),') has been finished!');
    end
    msmest{nag,1} = smest;
    msmest{nag,2} = mslip;
    msmest{nag,3} = osim;
    msmest{nag,4} = mabc;
    msmest{nag,5} = trif;
    %msmest{nag,5} = alpha;
end
