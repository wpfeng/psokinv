function [smest disf dismodel cinput isabc abc osim input mabicre,slipuncertainty] = sim_smest(matfile,inf,alpha,px,py,l,w,topdepth,minscale,bdconts,mdip)%
%
%
% Name: sim_smest
% Version: 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -> Modified by Feng W.P,2010/03/16
%   Now the function supports psoksar format.
% -> Modified by Feng W.P,2010/05/02
%   Normalized wegiht of the input data.
%   wanpeng.feng@hotmail.com
% -> Updated by Feng,W.P.,@ UoG, 2012-09-27
%    latest version supports rake change without recomputing green
%    matrix...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global isjoint smoothingfact cfgname dweight xyzindex invmethod vcmtype ...
       rakecons mrakecons Blb Bub utmzone Grakecons listmodel maxvalue mcdir smcfg ...
       isopening
%
%
[t_mp,t_mp,ext] = fileparts(matfile);
info = sim_getsmcfg(smcfg);
%
%
distready = 0;
%
if strcmpi(info.indist,'NULL')
    %
    if strcmpi('.mat',ext)==1
        mat    = load(matfile);
        outstd  = mat.outstd;
        indx   = find(outstd(:,1)==min(outstd(:,1)));
        fpara  = mat.outfpara{indx(1)};
    else
        [fpara,utmzone] = sim_openfault(matfile);
    end
else
    disf = sim_openfault(info.indist);
    %
    fpara = disf(1,:);
    distready = 1;
end
%
mabicre = cell(1);
alpha   = alpha(1):alpha(3):alpha(2);
attris  = {'Xcor','Ycor','Str','Dip','Dep','Wid','Len'};
disp('**************** Least Square Inversion *****************');
%
newinpdir = [];
if exist('inpnewdirection.info','file')
    %
    fidinps = fopen('inpnewdirection.info','r');
    tline = fgetl(fidinps);
    if exist(tline,'dir')
        newinpdir = tline;
    else
        disp('inpnewdirection.info is found, but no valid data is available...');
    end
    %
    fclose(fidinps);
end
%
for nag=1:numel(mdip(:,1))
    %
    if mdip(nag,1)> size(fpara,1)
       disp('You set a big ABIC coefficent...');
       %
       return
    end
    %
    % Updated by Feng, W.P., @Yj, 2015-05-14
    % "foc" available for fault sampling
    %
    if strcmpi(info.extendingtype,'foc')
       %
       disp(' sim_smest: redefine the fault dip with given dip information');
       cfpara               = fpara(mdip(nag,1),:);
       cfpara               = sim_fparaconv(cfpara,0,3);
       cfpara(mdip(nag,2))  = mdip(nag,3);
       fpara(mdip(nag,1),:) = sim_fparaconv(cfpara,3,0);
       %
    else
       fpara(mdip(nag,1),mdip(nag,2)) = mdip(nag,3);
    end
    %
    if exist(cfgname,'dir')~=0
        disp( 'PS_SMEST-> We have found folders we need...');
    else
        disp( 'PS_SMEST-> The folder we need is not found in current directory...');
        disp(['PS_SMEST-> Now create the folder:' cfgname]);
        mkdir(cfgname);
    end
    %
    matname = [cfgname,'/',[cfgname,'_No',num2str(mdip(nag,1)),'Fault_' attris{mdip(nag,2)},num2str(mdip(nag,3))],'.mat'];
    disp(['PS_SMEST-> Check MAT file: ' matname]);
    %
    if exist(matname,'file') == 0
        disp('PS_SMEST-> The Green Matix is not found. Calculate it now...');
        %
        if rakecons(1) ~=0 
            disp('PS_SMEST-> THE GREEN MATRIX will be calculated due to given rakes.');
        else
            disp('PS_SMEST-> THE GREEN MATRIX will be calculated due to 0 and 90');
        end
        %
        if distready == 1
            infpara = info.indist;
        else
            infpara = fpara;
        end
        %
        if distready == 1
            disp(['PS_SMEST-> A discretized fault model is given: ',infpara]);
        end
        %
        disp(['PS_SMEST-> Elatic Property ALPHA: ',num2str(info.elasticALP)]);
        %
        [disf,input,G,lap,lb,...
            ub,am,cinput,vcm] = sim_pre4smest(infpara,inf,px,py,l,w,topdepth,bdconts,[],0,info.elasticALP);
        %
        if exist('abccof','var') == 0
            %
            [t_mp,t_mp,t_mp,t_mp,abccof] = sim_readconfig(inf);
        end
        %
        % Obsolted by Feng W.P., @ IGPP of SIO, UCSD, 2013-10-16
        %
        if isjoint >= 1
            %
            % updated by FWP, @ UoG, 2013-06-17
            % [~,~,lap] = sim_fpara2lap_2d(disf,xyzindex);
            %lap = sim_fpara2lapv4(fpara,isjoint,l,w,px,py);
            %
        end
        %
        % [input,am,cinput,vcm] = sim_sminpudata(inf);
        %
        [input,am,cinput,vcm,abccof,weighs,dweight] = sim_sminpudata(inf,newinpdir);
        eval(['save ' matname ' listmodel Blb Bub abccof disf utmzone input topdepth dweight G lap lb ub am cinput vcm l w px py rakecons mrakecons']);
        %    
    else
        disp('PS_SMEST-> The Green Matix has been found!');
        %
        [t_mp,t_mp,t_mp,t_mp,abccof] = sim_readconfig(inf);
        %
        ipx = px;
        il  = l;
        iw  = w;
        ipy = py;
        chdata = [ipx(:)',ipy(:)',il(:)',iw(:)'];
        eval(['load ' matname]);
        %
        [input,am,cinput,vcm,abccof,weighs,dweight] = sim_sminpudata(inf,newinpdir);
        % 
        % Updated by Wanpeng Feng, @Ottawa, 2017-04-16
        rawdata = [px(:)',py(:)',l(:)',w(:)'];
        flagdim = size(chdata)==size(rawdata);
        if sum(flagdim) == 2
            chktype = chdata==rawdata;
        else
            chktype = 0;
        end
        %
        if sum(chktype) < numel(chdata)
            %
            disp('PS_SMEST-> Parameters have been changed. Recalculate now...');
            %
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
                ub,am,cinput,vcm] = sim_pre4smest(fpara,inf,px,py,l,w,topdepth,bdconts,[],0,0.5);
            %
        end
    end
    %
    % Updated by Feng, W.P., @NRCan, 2015-10-16
    % the data file will be saved to local folder. Then in future we can
    % change data weights as we want, whilst the raw configure file for
    % psokinv will not be affected...
    %
    subfault_num = numel(disf(:,1));
    workingdir = fileparts(matname);
    if ~isempty(workingdir)
        %
        weigfile = 'weight.info';
        %
        disp(['SIM_SESMT: Checking weight.info in ', [workingdir,'/',weigfile]])
        if ~exist([workingdir,'/',weigfile],'file')
            %
            disp(' SIM_SMEST: Found weight.info')
            fidweights = fopen([workingdir,'/',weigfile],'w');
            for ninputs = 1:numel(cinput)
               cinp = cinput{ninputs}{1};
               if ~isempty(newinpdir)
                   [t_mp,bname,bext] = fileparts(cinp);
                   cinp = [newinpdir,bname,bext];
               end
               %
               fprintf(fidweights,'%s %10.3f\n',cinp,weighs(ninputs));
            end
            fclose(fidweights);
        end
    else
        disp('why is the workingdir empty?');
        return
    end
    % Updated dweights for each observations...
    %
    dweight = sim_updatedweight(workingdir);
    % disp(['SIM_SEMST: new weights->',num2str(dweight')])
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isopening == 0
       % 
       % modified by Feng W.P, rakecons is changed
       sG         = G(:,1:end/2);
       dG         = G(:,end/2+1:end);
    end
    if abs(isopening) == 1
        oG         = G;
    end
    if isopening == 2
        sG         = G(:,1:end/3);
        dG         = G(:,end/3+1:end/3*2);
        oG         = G(:,end/3*2+1:end);
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % quick test for bounded ...
    % by FWP, @ UoG, 20130627
    %
    rakecons = Grakecons;
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Provide an additional fault model for defining afterslip slip bounds
    % by FWP,@UoG, 2014-08-14
    % a new parameter for the configure file of slip inversion package,
    % sim_smcfg...
    %
    refoksar  = info.refoksar;
    if ~strcmpi(refoksar,'null')
        %
        if exist(refoksar,'file')
           %
           disp('PS_SMEST-> Updating the slip bounds...');
           %
           infpara  = sim_infpara(refoksar);
           %outfpara = sim_compfpara2single(infpara,disf);
           tub      = [infpara(:,8);infpara(:,8)];
           %
           % keep the zero slip constraints on the edge...
           %
           ub = tub;
           disp('PS_SMEST-> Updating the slip bounds. Done!');
        end
    end
    %return
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    crakecons = info.rakecons;
    for nkkkk = 1:numel(crakecons(:,1))
        mrakecons(mrakecons(:,4)==nkkkk,2) = crakecons(nkkkk,2);
        mrakecons(mrakecons(:,4)==nkkkk,3) = crakecons(nkkkk,3);
    end
    %
    if abs(isopening) ~= 1
       r1G = sG.*0;
       r2G = dG.*0;
       for nrg = 1:numel(sG(:,1))
          %
          r1G(nrg,:)  = sG(nrg,:) .* cosd(mrakecons(:,2))' + ...
                        dG(nrg,:) .* sind(mrakecons(:,2))';
          r2G(nrg,:)  = sG(nrg,:) .* cosd(mrakecons(:,3))' + ...
                        dG(nrg,:) .* sind(mrakecons(:,3))';
       end
    end
    %
    %%
    tbrakecons = mrakecons;
    tbrakecons(mrakecons(:,2)==mrakecons(:,3),1) = 0;
    %
    % Updated by FWP, @ UoG, 20130629
    % the maxima slip boundary has been parameterized in configure file.
    % 
    ub(ub~=0) = info.maxvalue;
    % disp([info.maxvalue,max(ub)])
    %
    % The special treat for YS case has been switched off
    % by fWP, @UoG, 2014-03-15, later than below
    %%
    %tlb      = lb(end/2+1:end);
    tlb      = ub(end/2+1:end);
    % boundary for opening
    tlbo     = tlb.*0;
    tubo     = tlb.*0 + info.maxvalue;
    tubsize  = size(tubo);
    tubo(ub(1:tubsize(1))==0) = 0;
    %
    tub      = ub(end/2+1:end);
    lb       = [lb(1:end/2);tlb(tbrakecons(:,1)== 1)];
    ub       = [ub(1:end/2);tub(tbrakecons(:,1)== 1)];
    lb       = ub.*0;
    if isopening == 2
        lb = [lb;tlbo];
        ub = [ub;tubo];
    end
    if abs(isopening) == 1
        lb = tlbo;
        ub = tubo;
    end
    %
    %
    disp(['SIM_SMEST: isopening-> ' num2str(isopening)]);
    if isopening == 0
        G  = [r1G r2G(:,tbrakecons(:,1)==1)];
    else
        if isopening == 2
           G = [r1G r2G(:,tbrakecons(:,1)==1) oG];
        else
           G = oG;
        end
    end
    if isopening == -1
        G = G.*-1;
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nalpha   = numel(alpha);
    smest    = zeros(nalpha,5);
    dismodel = cell(nalpha,1);
    osim     = dismodel;
    mabc     = cell(nalpha,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['SIM_SMEST: Solving the linear problem at ' num2str(nalpha) ' loop.']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Based on the Dr. Tim Wright's paper,2004
    %
    switch vcmtype
        case 'vcm'
            disp('SIM_SMEST: Working with chol(inv(vcm))) ...');
            W  = chol(inv(vcm)).*repmat(dweight,1,size(vcm,2));
        case 'cov'
            disp('SIM_SMEST: Working with COV model ...');
            
            W = vcm.*repmat(dweight,1,size(vcm,2));
        otherwise
            disp('SIM_SMEST: Working with vcm ...');
            W  = vcm.*repmat(dweight,1,size(vcm,2));
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Modified by Feng, Wanpeng, 2011-01-28
    % now support isjoint working for given segments
    % lap = lap{1};
    %  
    if isopening == 0 && strcmpi(info.indist,'NULL')
       %
       %disp('SIM_SMEST: Laplacian Matrix is re-estimated...');
       %[t_mp,t_mp,tlap] = sim_fpara2lap_updated(disf,xyzindex,mrakecons(:,4));
       %L = tlap;
       %
    end
    %
    tbrakecons(tbrakecons(:,2)==tbrakecons(:,3),1) = 0;
    indexnonzero = find(tbrakecons(:,1)~=0);
    % info.indist
    lapmat = [info.indist,'.lap.mat'];
    %
    if exist(lapmat,'file')
        %
        disp([' sim_smest: LAP is being updated with an external input, ',lapmat]);
        lap = load(lapmat);
        lap = lap.lap;
    end
    %
    if iscell(lap)
        tlap = lap{1};
        %
        if isopening == 2
            L = [tlap    tlap.*0 tlap.*0;
                tlap.*0 tlap    tlap.*0;
                tlap.*0 tlap.*0 tlap];
            upL = tlap;
        else
            L = [tlap    tlap.*0 tlap.*0;
                tlap.*0 tlap    tlap.*0;
                tlap.*0 tlap.*0 tlap];
            %
            %
            upL = L(1:end/3,1:end/3);
            loL = L(end/3+1:end/3*2,end/3+1:end/3*2);
            bL  = L;
            %
            loL = loL(indexnonzero,indexnonzero);
            %
            L                                      = zeros(size(upL,1)+size(loL,1));
            L(1:size(upL,1),1:size(upL,1))         = upL;
            L(size(upL,1)+1:end,size(upL,1)+1:end) = loL;
            %
        end

    else
        L = [lap lap.*0;
             lap.*0 lap ];
    end
    %
    % Now the weight is valid to distributed model inversion...
    % Update by Feng W.P, 2010-05-02
    % 
    if smoothingfact ~= 0
       %
       % Updated by Feng, W.P., @ EOS of NTU, Singapore
       % 2015-06-23
       %
       disp(['SIM_SMEST: Weighting Smoothing factor -> ',num2str(smoothingfact)]);
       lapw  = sim_green4lapweight(G,input(:,3),smoothingfact);%,dweight);
       %
    else
       lapw  = 1;
    end
    %
    gSize = size(G);
    %
    L = L(1:gSize(2),1:gSize(2));
    %
    L   = L.*lapw; 
    cL  = L./400;
    %
    if size(W,2) == 1
        W = diag(W);
    end
    %
    if alpha(1) < 0 
       disp(' sim_smest: laplacian smoothing constraints are removed.')
       nalpha = 1;
    end
    for ni = 1 : nalpha
        %
        disp([' sim_smest: Current Smoothing strength: ',num2str(alpha(ni))]);
        %
        smest(ni,1)  = alpha(ni);
        %
        if alpha(ni) < 0
            A = W*G;
        else
            A  = [W*G;alpha(ni).*cL];
        end
        %
        if numel(am) ~= 0
            nG   = size(A,1);
            nABC = size(am,2);
            Mabc = zeros(nG,nABC);
            Mabc(1:size(am,1),:) = am;
            AA                   = [A Mabc];
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
        % 
        if minscale ~= 0
            %
            % enlarge the coff
            sflag  = zeros(1,size(upL,2))+1;%./smoothscaleup(:)';
            dflag  = zeros(1,size(upL(indexnonzero,indexnonzero),2))+1;%./smoothscaledo(:)';
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
            if n > m
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
           % disp(info.maxvalue)
           minabc = zeros(size(am,2),1)-info.maxvalue;
           maxabc = zeros(size(am,2),1)+info.maxvalue;
           LB     = [lb;minabc];
           UB     = [ub;maxabc];
        else
           LB     = lb;
           UB     = ub;
        end
        %
        % save Dike_opt_v160531.mat G AA D LB UB lap input disf indexnonzero subfault_num
        %
        switch lower(invmethod)
            case 'nnls'
                Maslip   = sim_nnls(AA,D);
            case 'simple'
                Maslip   = AA\D;
            case 'bvls'
                aslip   = sim_nnls(AA,D);
                opt.x0  = aslip;
                Maslip  = sim_bvls(AA,D,LB,UB,opt);
            case 'lsqlin'
                options = optimset('LargeScale','on','display','off');
                flag        = LB==UB;
                UB(flag==1) = UB(flag==1) +0.000001;
                aslip   = sim_nnls(AA,D);
                Maslip  = lsqlin(AA,D,[],[],[],[],LB,UB,aslip,options);
            case 'iteration'
                %
                aslip   = sim_nnls(AA,D);
                %
                [Maslip,rsq]  = cgls_bvls(AA,D,LB,UB,[],[],[],aslip);
                disp('  SIM_SMEST: Iterating by using the residuls...');
                wres  = sqrt(1./sqrt((D-AA*Maslip).^2));
                wM    = diag(wres);
                wM(wM==0) = 1;
                wM(isnan(wM)) = 1;
                wM(isinf(wM)) = 1;
                Maslip = cgls_bvls(wM*AA,wM*D,LB,UB,[],[],[],Maslip);
            otherwise
                %
                disp(['PS_SMEST: the dimension of AA are in [', num2str(size(AA,1)),',',...
                       num2str(size(AA,2)),']']);
                aslip   = sim_nnls(AA,D);
                %
                [Maslip,rsq]  = cgls_bvls(AA,D,LB,UB,[],[],[],aslip);
                %disp(rsq)
                %
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
        % Maslip, all slip components, including, probably some offsets of
        % the data if "am" is not empty.
        %
        num_offsets = size(am,2);
        upSlip       = Maslip(end - subfault_num - num_offsets +1 : end-num_offsets);
        %
        if isopening == 0
            upSlip = upSlip .* 0;
        end
        if isopening == -1
            upSlip = upSlip .* -1;
        end
        %
        slip_str     = upSlip.*0;
        slip_dip     = upSlip.*0;
        %
        if abs(isopening) ~= 1
          %
          luSlip       = Maslip(1:subfault_num);
          slip_str     = luSlip .* cosd(mrakecons(:,2));
          slip_dip     = luSlip .* sind(mrakecons(:,2));
          %
          if isempty(indexnonzero)==0
              % 
              % Note that the information of mrakecons won't be updated
              % automatically...
              % by Wanpeng Feng, @CCRS/NRCan, 2017-09-25
              %
              lwSlip                 = Maslip(subfault_num+1:subfault_num+numel(indexnonzero));
              slip_str(indexnonzero) = lwSlip .*cosd(mrakecons(indexnonzero,3)) + slip_str(indexnonzero);
              slip_dip(indexnonzero) = lwSlip .*sind(mrakecons(indexnonzero,3)) + slip_dip(indexnonzero);
          end
        end
        % 
        Rakeaslip = [slip_str slip_dip upSlip]; 
        %
        % Updated by FWP,@UoG, 2014-09-09
        %
        mcslip = [];
        if info.isuncertainty > 0
            %
            disp('SIM_SMEST: Estimating slip uncertainty by Simple Monte-carlo method...');
            if info.isuncertainty == 1
                mcnum = 100;
            else
                mcnum = info.isuncertainty;
            end
            %
            % ndim     = size(AA);
            %
            obssim   = G*aslip;
            obserror = input(:,3) - obssim;
            maxerr   = max(abs(obserror));
            %
            % check the result...
            % 
            tempsim = (rand(numel(input(:,3)),mcnum)-0.5).*2;
            %
            mslip   = zeros(numel(disf(:,1))*3,mcnum);
            cDD     = D;
            %
            for nmc = 1:mcnum
                %
                disp([' MC: ',num2str(nmc)]);
                %
                simdata  = W*(input(:,3) + tempsim(:,nmc).*maxerr);
                %
                cDD(1:numel(input(:,3))) = simdata;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                switch lower(invmethod)
                    case 'nnls'
                        aslip   = sim_nnls(AA,cDD);
                    case 'simple'
                        aslip   = AA\cDD;
                    case 'bvls'
                        aslip  = sim_bvls(AA,cDD,LB,UB);
                    case 'lsqlin'
                        options     = optimset('LargeScale','on','display','off');
                        flag        = LB==UB;
                        UB(flag==1) = UB(flag==1) +0.000001;
                        aslip  = lsqlin(AA,cDD,[],[],[],[],LB,UB,[],options);
                    otherwise
                        aslip   = sim_nnls(AA,cDD);
                        opt.x0  = aslip;
                        aslip   = cgls_bvls(AA,cDD,LB,UB,opt);
                        %
                        
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                upSlip       = Maslip(end-subfault_num+1 : end);
                % min(upSlip)
                % max(upSlip)
                %
                if isopening == 0
                    upSlip = upSlip .* 0;
                end
                if isopening == -1
                    upSlip = upSlip .* -1;
                end
                %
                slip_str     = upSlip.*0;
                slip_dip     = upSlip.*0;
                %
                if abs(isopening) ~= 1
                    luSlip       = Maslip(1:subfault_num);
                    slip_str     = luSlip .* cosd(mrakecons(:,2));
                    slip_dip     = luSlip .* sind(mrakecons(:,2));
                    %
                    if isempty(indexnonzero)==0
                        lwSlip                 = Maslip(subfault_num+1:subfault_num+numel(indexnonzero));
                        slip_str(indexnonzero) = lwSlip .*cosd(mrakecons(indexnonzero,3)) + slip_str(indexnonzero);
                        slip_dip(indexnonzero) = lwSlip .*sind(mrakecons(indexnonzero,3)) + slip_dip(indexnonzero);
                    end
                end
                %
                Rakeaslip = [slip_str;slip_dip; upSlip];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                mslip(:,nmc) = Rakeaslip;
            end
            %
            slipuncertainty = std(mslip');
            mcslip          = mslip;
            %
        else
            slipuncertainty = [];
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if numel(am) < 1
           smest(ni,2)  = sim_rms(W*(G*aslip-input(:,3)));
        else
           %
           offsets = am*outabc;
           simoffs = input(:,3)*0.0;
           simoffs(1:numel(offsets)) = offsets;
           smest(ni,2)  = sim_rms(W*(G*aslip-input(:,3))-simoffs);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % We just concern with parts of the big slip value...
        % Add codes by Feng, W.P, 2010-10-15.
        %
        slip_on_faults = Maslip(1:end-num_offsets);
        roug         = abs(L * slip_on_faults);
        roug         = sort(roug,'descend');
        smest(ni,3)  = sum(roug)/numel(roug);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        smest(ni,4)  = abic;
        smest(ni,5)  = mdip(nag,2);
        dismodel{ni} = Rakeaslip;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if numel(am)<1
          %
          osim{ni}   = G*aslip;
        else
          % updated by Wanpeng feng,
          simoffsets = input(:,3)*0;
          simoffsets(1:size(am,1)) = am*outabc;
          osim{ni}   = G*aslip+simoffsets;
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
    out.mcslip   = mcslip;
    mabicre{nag} = out;
end
if numel(am) > 0
   isabc = 1;
   abc   = outabc;
else
   isabc = 0;
   abc   = [];
end
