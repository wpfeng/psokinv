function [smest disf dismodel cinput isabc abc osim input mabicre] = sim_smest_mc(matfile,inf,alpha,px,py,l,w,minscale,bdconts,mdip)%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Name: sim_smest
% Version: 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -> Modified by Feng W.P,2010/03/16
%   Now the function supports psoksar format.
% -> Modified by Feng W.P,2010/05/02
%   Normalized wegiht of the input data.
%   fengwp@cea-igp.ac.cn
% -> Updated by Feng,W.P.,@ GU, 2012-09-27
%    latest version supports rake change withoud recomputing green
%    matrix...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global isjoint smoothingfact cfgname dweight xyzindex invmethod vcmtype ...
       rakecons mrakecons Blb Bub utmzone Grakecons listmodel maxvalue mcdir
%
%
[~,~,ext] = fileparts(matfile);
%
if strcmpi('.mat',ext)==1
    mat    = load(matfile); 
    std    = mat.outstd;
    indx   = find(std(:,1)==min(std(:,1)));
    fpara  = mat.outfpara{indx(1)};
else
    if strcmpi(ext,'.OKSAR')==1
       fpara = sim_oksar2SIM(matfile);
    else
       fpara = sim_psoksar2SIM(matfile);
    end
end
%
mabicre = cell(1);
alpha   = alpha(1):alpha(3):alpha(2);
attris  = {'Xcor','Ycor','Str','Dip','Dep','Wid','Len'};
disp('**************** Least Square Inversion *****************');
%%
for nag=1:numel(mdip(:,1))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if mdip(nag,1)> size(fpara,1)
       disp('You set a big ABIC coefficent...');
       disp('Now all dips will set same value...');
       %return
    end
    if mdip(nag,1) > size(fpara,1)
       fpara(:,mdip(nag,2))           = mdip(nag,3);
    else
       fpara(mdip(nag,1),mdip(nag,2)) = mdip(nag,3);
    end
    %
    if exist(cfgname,'dir')~=0
        disp( 'PS_SMEST-> We have found folders we need...');
    else
        disp( 'PS_SMEST-> the folders we need is not found in current directory...');
        disp(['PS_SMEST-> Now create the folder:' cfgname]);
        mkdir(cfgname);
    end
    %
    matname = [cfgname,'/',[cfgname,'_No',num2str(mdip(nag,1)),'Fault_' attris{mdip(nag,2)},num2str(mdip(nag,3))],'.mat'];
    disp(['PS_SMEST-> Check MAT file: ' matname]);
    %
    if exist(matname,'file') == 0
        disp('PS_SMEST-> The Green Matix is no found. Calculate it now...');
        if rakecons(1) ~=0 
            disp('PS_SMEST-> THE GREEN MATRIX will be calculated due to given rakes.');
        else
            disp('PS_SMEST-> THE GREEN MATRIX will be calculated due to 0 and 90');
        end
        [disf,input,G,lap,lb,...
            ub,am,cinput,vcm] = sim_pre4smest(fpara,inf,px,py,l,w,bdconts,[],0);
        %
        if exist('abccof','var') == 0
            [~,~,~,~,abccof,~,~,...
            ~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = sim_readconfig(inf);
        end
        %
        if isjoint >= 1
            % updated by FWP, @ GU, 2013-06-17
            [~,~,lap] = sim_fpara2lap_2d(disf,xyzindex);
            %lap = sim_fpara2lapv4(fpara,isjoint,l,w,px,py);
        end
        %
        eval(['save ' matname ' listmodel Blb Bub abccof disf utmzone input dweight G lap lb ub am cinput vcm l w px py rakecons mrakecons']);
    %    
    else
        disp('PS_SMEST-> The Green Matix has been found!');
        [~,~,~,~,abccof,~,~,...
         ~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = sim_readconfig(inf);
        ipx = px;
        il  = l;
        iw  = w;
        ipy = py;
        chdata = [ipx(:)',ipy(:)',il(:)',iw(:)'];
        eval(['load ' matname]);
        %
        [input,am,cinput,vcm] = sim_sminpudata(inf);
        %
        chktype               = chdata==[px(:)',py(:)',l(:)',w(:)'];
        if sum(chktype) < numel(chdata)
            disp('PS_SMEST-> Parameters have been changed. Recalculate now...');
            if rakecons(1) ~=0
                disp('PS_SMEST-> THE GREEN MATRIX will be calculated due to given rakes.');
            else
                disp('PS_SMEST-> THE GREEN MATRIX will be calculated due to 0 and 90');
            end
            l  = il;
            w  = iw;
            px = ipx;
            py = ipy;
            %
            [disf,input,G,lap,lb,...
                ub,am,cinput,vcm] = sim_pre4smest(fpara,inf,px,py,l,w,bdconts,[],0);
            %
            if isjoint >= 1
                % update by FWP, @ GU, 2013-06-17
                %
                [~,~,lap] = sim_fpara2lap_2d(disf,xyzindex);
                %lap = sim_fpara2lapv4(fpara,isjoint,l,w,px,py);
            end
            eval(['save ' matname 'listmodel Blb Bub disf utmzone input G abccof lap lb ub am cinput vcm l w px py rakecons']);
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % modified by Feng W.P, rakecons is changed
    %
    sG         = G(:,1:end/2);
    dG         = G(:,end/2+1:end);
    %%%%
    % quick test for bounded ...
    % by FWP, @ GU, 20130627
    %%%%
    rakecons         = Grakecons;
    [~,~,mrakecons]  = sim_fpara4auxi(fpara,px,py,l,w,Grakecons);
    %
    r1G = sG.*0;
    r2G = sG.*0;
    %
    for nrg = 1:numel(sG(:,1))
      r1G(nrg,:)  = sG(nrg,:) .* cosd(mrakecons(:,2))' + ...
                    dG(nrg,:) .* sind(mrakecons(:,2))';
      r2G(nrg,:)  = sG(nrg,:) .* cosd(mrakecons(:,3))' + ...
                    dG(nrg,:) .* sind(mrakecons(:,3))';
    end
    %
    %%
    tbrakecons = mrakecons;
    tbrakecons(mrakecons(:,2)==mrakecons(:,3),1) = 0;
    %
    % Updated by FWP, @ GU, 20130629
    % the maxima slip boundary has been parameterized in configure file.
    % 
    if numel(maxvalue) == 0
        maxvalue = 100000;
    end
    %
    ub(ub > maxvalue)   = maxvalue;
    tlb       = lb(end/2+1:end);
    tub       = ub(end/2+1:end);
    lb        = [lb(1:end/2);tlb(tbrakecons(:,1)== 1)];
    ub        = [ub(1:end/2);tub(tbrakecons(:,1)== 1)];
    G         = [r1G r2G(:,tbrakecons(:,1)==1)];
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nalpha   = numel(alpha);
    smest    = zeros(nalpha,5);
    dismodel = cell(nalpha,1);
    osim     = dismodel;
    mabc     = cell(nalpha,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['Now the estimation work is beginning.' num2str(nalpha) ' Loops!']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Based on the Wright's paper,2004
    %
    switch vcmtype
        case 'vcm'
            disp('SIM_SMEST: Working with chol(inv(vcm))) ...');
            W  = chol(inv(vcm)).*repmat(dweight,1,size(vcm,2));
            %W  = chol(inv(vcm)).*repmat(dweight,1,size(vcm,2));
        case 'cov'
            W = vcm.*repmat(dweight,1,size(vcm,2));
        otherwise
            disp('SIM_SMEST: Working with vcm ...');
            W  = vcm.*repmat(dweight,1,size(vcm,2));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    npara = size(G,2);
    % Modified by Feng, Wanpeng, 2011-01-28
    % now support isjoint working for given segments
    L = [];
    if iscell(lap)
        for nii=1:numel(lap)
            %
            tlap = lap{nii};
            ndim = size(tlap,1);
            L(size(L,1)+1:size(L,1)+ndim,...
                size(L,1)+1:size(L,1)+ndim) = tlap;
        end
        L  = [L    L.*0;
              L.*0 L];
    else
        L = lap;
    end
    %
    upL = L(1:end/2,1:end/2);
    loL = L(end/2+1:end,end/2+1:end);
    bL  = L;
    %   %
    tbrakecons(tbrakecons(:,2)==tbrakecons(:,3),1) = 0;
    indexnonzero = find(tbrakecons(:,1)~=0);
    %
    loL = loL(indexnonzero,indexnonzero);
    %
    L                                      = zeros(size(upL,1)+size(loL,1));
    L(1:size(upL,1),1:size(upL,1))         = upL;
    L(size(upL,1)+1:end,size(upL,1)+1:end) = loL;
    %
    % Now the weight is valid to distributed model inversion...
    % Update by Feng W.P, 2010-05-02
    % 
    if smoothingfact ~=0
       %tfpara  = sim_senstivityfrominp(disf,input,mrakecons);
       lapw  = sim_green4lapweight(G,input(:,3));
    else
       lapw  = 1;
    end
    %
    L   = L.*lapw;
    %
    cL  = L./400;
    %
    for ni =1:nalpha
        smest(ni,1)  = alpha(ni);
        if size(W,2) == 1
            W = diag(W);
        end
        A  = [W*G;alpha(ni).*cL];
        if numel(am) ~= 0
            nG   = size(A,1);
            nABC = size(am,2);
            Mabc = zeros(nG,nABC);
            Mabc(1:size(am,1),:) = am;
            AA  = [A Mabc];
        else
            AA  = A;
        end
        np  = size(A,1);
        rp  = size(input,1);
        %
        %
        if np > rp
           D = [W*input(:,3);zeros(np-rp,1)];
        else
           D = W*input(:,3);
        end
        % disp(minscale);
        if minscale ~= 0
            % enlarge the coff
            sflag  = zeros(1,size(upL,2))+1./smoothscaleup(:)';
            dflag  = zeros(1,size(upL(indexnonzero,indexnonzero),2))+1./smoothscaledo(:)';
            %
            ssflag = sflag./max([sflag(:);dflag(:)]);
            sdflag = dflag./max([sflag(:);dflag(:)]);
            %
            % save test.mat sflag dflag smoothscaleup smoothscaledo
            szero = minscale.*[ssflag      sdflag.*0];
            dzero = minscale.*[ssflag.*0   sdflag   ];
            m     = size(szero,2);
            n     = size(AA,2);
            %
            if n>m
                endpatch = zeros(1,n-m);
            else
                endpatch = [];
            end
            ms = [szero endpatch];
            ds = [dzero endpatch];
            %
            AA  = [AA;ms;...
                      ds];
            D   = [D;0;0];
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if numel(am) > 0
           minabc = zeros(size(am,2),1)-10000;
           maxabc = zeros(size(am,2),1)+10000;
           LB     = [lb;minabc];
           UB     = [ub;maxabc];
        else
           LB     = lb;
           UB     = ub;
        end
        %
        %
        %
        switch lower(invmethod)
            case 'nnls'
                Maslip = sim_nnls(AA,D);
            case 'simple'
                Maslip = AA\D;
            case 'bvls'
                 Maslip  = sim_bvls(AA,D,LB,UB);
            case 'lsqlin'
                 options = optimset('LargeScale','on','display','off');
                 Maslip  = lsqlin(AA,D,[],[],[],[],LB,UB,[],options);
            otherwise
                 Maslip  = cgls_bvls(AA,D,LB,UB);
        end
        if numel(am)>0
           aslip  = Maslip(1:end-size(am,2));
           outabc = Maslip(end-size(am,2)+1:end);
        else
           aslip  = Maslip;
           outabc = [];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        abic         = 0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        upSlip       = Maslip(1:size(upL,1));
        slip_str     = upSlip .* cosd(mrakecons(:,2));
        slip_dip     = upSlip .* sind(mrakecons(:,2));
        %
        if isempty(indexnonzero)==0
            lwSlip                 = Maslip(size(upL,1)+1:size(upL,1)+numel(indexnonzero));
            slip_str(indexnonzero) = lwSlip .*cosd(mrakecons(indexnonzero,3)) + slip_str(indexnonzero);
            slip_dip(indexnonzero) = lwSlip .*sind(mrakecons(indexnonzero,3)) + slip_dip(indexnonzero);
        end
        %
        Rakeaslip = [slip_str;slip_dip];
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if numel(am) < 1
           smest(ni,2)  = sim_rms(W*(G*aslip-input(:,3)));
        else
           smest(ni,2)  = sim_rms(W*(G*aslip-input(:,3))-am*outabc);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % We just concern with parts of the big slip value...
        % Add codes by Feng, W.P, 2010-10-15.
        %
        roug         = abs(bL*Rakeaslip);
        roug         = sort(roug,'descend');
        smest(ni,3)  = sum(roug)/numel(roug);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        smest(ni,4)  = abic;
        smest(ni,5)  = mdip(nag,2);
        dismodel{ni} = Rakeaslip;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if numel(am)<1
          osim{ni}   = G*aslip;
        else
          osim{ni}   = G*aslip+am*outabc;
        end
        mabc{ni,1}   = outabc;
        mabc{ni,2}   = cinput;
        mabc{ni,3}   = abccof;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('%15s%3.0d%9s%8.4f%28s%4s%1s%5.2f%1s%4s\n','  PS_SMEST-> The No:', ni ,' (alpha:' ,alpha(ni) ,') Loop has been finished!(' ,attris{mdip(nag,2)} ,':' ,mdip(nag,3),') by ',upper(invmethod));
    end
    out.dismodel = dismodel;
    out.smest    = smest;
    out.osim     = osim;
    out.disf     = disf;
    out.mabc     = mabc;
    mabicre{nag} = out;
end
if numel(am) > 0
   isabc = 1;
   abc   = outabc;
else
   isabc = 0;
   abc   = [];
end
