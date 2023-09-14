function vobj = sim_obj_conrake(x)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Purpose:
%        the function to estimate objective values of the object functions
% Input:
%        x, n*1
%        global variables
%           input, the insar or other geodesy observation data (m*6)
%                  x(km) y(km) insar(cm) k-e k-n k-v
%           fpara, the m*10 matrix, m is the fault number.
%           Inv  , the m*10 matrix, which the variable will need to invert
%                  will be set 1. Others are set to 0.
% Output:
%        vobj, object function value
% Writed by Feng W.P(skyflow2008@126.com), 10/04/2009
% Modified by Feng W.P,03/06/2009(skyflow2008@126.com), @ GU
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global input fpara index symbols locals alpha mwconinfo...
    am wVCM rake_isinv rake_value inv_VCM wmatrix rakeinfo ...
    rakecons mrakecons obsunit mwall
%
% try to use minimum moment scale constraint to the nonlinear inversion...
%
lamda2 = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f            = fpara;
f(index(:))  = x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
for ni = 1:numel(index)
    sym = symbols{index(ni)};
    f(index(ni)) = eval(sym{1});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nmodel = size(f,1);
for ni = 1:nmodel
    f(ni,:) = sim_fparaconv(f(ni,:),locals(ni,1),0);
end
tfpara  = f;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified by Feng, W.P, add rake constraints
% 2011-01-03
green    = [];
rakecons = zeros(size(f,1),2);        %zeros(size(f,1),3);
%
for ni = 1:size(f,1)
    % 
    % Updated by Wanpeng Feng, @CCRS/NRCan, 2017-09-20
    % flag of 2 means no boundary constraints...
    %
    if rakeinfo(ni,4) == 0
        rakecons(ni,:) = [rakeinfo(ni,1),rakeinfo(ni,1)];
    else
        rakecons(ni,:) = [rakeinfo(ni,2),rakeinfo(ni,3)];
    end
    %
end
%
[t_mp,r1green,r2green] = sim_oksargreenALP(tfpara,input,0,alpha,rakecons);
green                  = [r1green r2green(:, rakecons(:,1)~=rakecons(:,2))];
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[n,m]   = size(green);
[dn,dm] = size(am);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if isempty(am)==0
    A                = zeros(n,m+dm);
    A(1:n,1:m)       = green;
    A(1:dn,m+1:m+dm) = am;
    %
else
    A                = green;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D       = input(:,3);
counter = isnan(A);
cunter2 = isinf(A);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed nan problem, by Feng W.P, 2011-01-3
if sum(counter(:)) > 0 || sum(cunter2(:))>0
    %
    input(:,1) = input(:,1)+0.0001;
    vobj       = sim_obj_conrake(x);
    return
end
%
grank = rank(A);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if grank >= m
    lbm      = zeros(m,1);          %-20;
    ubm      = zeros(m,1) + 10000;
    %
    % Boundaries for ABC
    % by FWP, @UoG, 2014-02-01
    %
    lbn      = zeros(dm,1);
    ubn      = zeros(dm,1) + 10000;
    lb       = [lbm;lbn];
    ub       = [ubm;ubn];
    %
    %
    AA      = inv_VCM*A;
    DD      = inv_VCM*D;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add a new constraint, minimum moment scale
    if lamda2 ~=0
        MINSCALE  = AA(1,:).*0+lamda2;
        D0 = 0;
    else
        % change LS method to cgls_bvls, Feng, W.P, 2011-01-03,change back
        MINSCALE = [];
        D0 = [];
    end
    %
    if rake_isinv(1,1)>1
        %
        xslip = [AA;MINSCALE]\[DD;D0];
        %
    else
        xslip = cgls_bvls([AA;MINSCALE],[DD;D0],lb,ub);
    end
    %
    % added by fengwp,2013-06-14
    %
    mwflag = 1;
    %
    if sum(mwconinfo(:,4))>0
        %
        cslip       = xslip(1:size(tfpara,1));
        tfpara(:,8) = cslip(:).*cosd(rakecons(:,1)); %  + cslip(2)*cosd(crakecons(ni,3));
        tfpara(:,9) = cslip(:).*sind(rakecons(:,1)); %  + cslip(2)*sind(crakecons(ni,3));
        %
        valindex = rakecons(:,1) ~= rakecons(:,2);
        validind = find(valindex ~= 0);
        %
        for ni = 1:numel(validind)
            cslip                  = xslip(size(tfpara,1)+ni);
            tfpara(validind(ni),8) =  tfpara(validind(ni),8)  + cslip *  cosd(rakecons(validind(ni),2));
            tfpara(validind(ni),9) =  tfpara(validind(ni),9)  + cslip *  sind(rakecons(validind(ni),2));
        end
        %
        if strcmpi(obsunit,'m')
            factor = 1;
        elseif strcmpi(obsunit,'cm')
            factor = 0.01;
        else
            factor = 0.001;
        end
        %
        mst    = sim_fpara2moment(tfpara,3.23e10,0,factor);
        %
        if mwall ~= 1
            mw     = mean(mwconinfo(:,2:3),2);
            flag1  = mst(:,4) >= mwconinfo(:,2);
            flag2  = mst(:,4) <= mwconinfo(:,3);
            flag   = 1-flag1.*flag2;
            dmw    = abs(mst(:,4)-mw(:));
            mwflag = exp(sum(dmw(mwconinfo(:,4)==1)).*1.5);
            %
        else
            %
            % In this case, we expect identical boundary magnitudes for all
            % individual fault segments...
            % 
            allmoment = sum(mst(:,3));
            cmw = (2/3)*log10(allmoment)-6.033;
            flag1  = cmw >= mean(mwconinfo(:,2));
            flag2  = cmw <= mean(mwconinfo(:,3));
            flag   = 1-flag1.*flag2;
            %
            mw     = mean([mean(mwconinfo(:,2)),mean(mwconinfo(:,3))]);
            dmw    = abs(cmw-mw);
            mwflag = exp(dmw*flag*100);
            % disp([factor]);%,cmw,mw,flag,mwflag])
        end
        %
        %
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add following 6 lines for magnititude constraints
    %
    vobj    = norm((wVCM*((D-A*xslip))).*wmatrix).*mwflag;%.   *cof;%.^(1-dcor);%
    %
    %
    if isinf(vobj)
        vobj = 10^200;
    end
else
    vobj = 10^200;
end
%
