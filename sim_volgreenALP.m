function [green,sgreen,dgreen,tgreen] = sim_volgreenALP(fpara,input,thd,alp,meanstrike,meandip,meandepth)

%
% Usage: [green, sgreen, dgreen,tgreen] =
%              sim_okargreenALP(fpara,input,thd,alp)
%
% Created by Feng, Wanpeng, @IGP/CEA,2007
% Modified by Feng, Wanpeng, now support tensile slip.
% ************************************************************************
% Modified by Feng, W.P, 2010-10-13
%      -> add rake angles constraints
%      -> which has been obleted now. A standard GREEM matrix for pure
%      strike-slip and dip-slip should be calculated firstly. Then any
%      green matrix for a given rake angle can be synthesized then.
% Updated by Fwp, @UoG, 2013-03-08
%      -> add new input, rake constraints
% Updated by Feng, W.P., @UoG, 2014-06-07
%      -> Layered Earth Model can be considered in the inversion.
% Improved by Feng, W.P., @NRCan, 2015-10-11
%      -> a few bugs for layered earth model greem matrix calculation were
%      fixed.
% Updated by Feng, W.P., @NRCan, 2015-10-11
%      -> redirect the folder for layered GREEN function calculation...
%      -> to avoid a failur of PSCMP. We may need to consider to make the
%      name shorter than expected...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global earthmodel utmzone globalinfo
%
isoutput = 0;
%
if nargin < 6
    meanstrike = 0;
    meandip    = 0;
    meandepth  = 0;
end
%
if isempty(earthmodel)
    earthmodel = 'ELA';
end
%
if nargin < 3
    thd = 0;
end
if nargin < 4
    alp = 0.5;
end
%
if strcmpi(earthmodel,'lay')
    %utmzone
    [lat,lon]   = utm2deg(input(:,1).*1000,input(:,2).*1000,utmzone);
    cinput      = input;
    cinput(:,1) = lon;
    cinput(:,2) = lat;

    psgrndir  = globalinfo.layeredfold;
    [bdir,broot] = fileparts(psgrndir);
    if isempty(bdir)
        bdir = pwd;
    end
    %
    if isfield(globalinfo,'bname') && ~isempty(globalinfo.bname)
        pscmpdir  = [globalinfo.bname,'/','psCMP_',date];
    else
        pscmpdir  = ['psCMP_',date];
    end
    %
    %
    % PSGRN now is stongly suggested to be completed before linear
    % inveraion... Updated by Feng, W.P., @ NRCan, 2015-10-10
    %
    if ~exist(pscmpdir,'dir')
        %
        mkdir(pscmpdir);
    end
    %
    inpoutname  = [pscmpdir,'/pscmp_segmentdata.inp'];
    %
    [outpscmpinp,nfile] = sim_inpoutput(cinput,inpoutname);
    %
    if ~exist(psgrndir,'dir')
        %
        disp('*************** Warning ******************');
        disp([psgrncfg,' & ',psgrninfo,' are both not found !']);
        disp('The inversion procedure could be quited soon...');
        %
        disp('*************** Failed ********************');
        return
    end
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x      = input(:,1);
y      = input(:,2);
ndim   = size(fpara,1);
nraw   = size(x,1);
%
sgreen = zeros(nraw,ndim);
dgreen = sgreen;
tgreen = sgreen;
%
for nd = 1:ndim
    %
    fpara(nd,8)  = cosd(rakes(nd,1));
    fpara(nd,9)  = sind(rakes(nd,1));
    fpara(nd,10) = 0;
    %
    % Calculate the green matrix for strike slip...
    % Update by Feng,W.P., @ GU, 2012-09-26
    % Updated by FWP,      @ GU, 2013-05-14
    %
    if strcmpi(earthmodel,'ELA')
        dis     = multiokadaALP(fpara(nd,:),x,y,0,alp,thd);
    else
        %
        % updated by FWP, using pscmp to replace edcmp...
        % 2013-05-22
        %
        mdata = [];
        disp(['PS_SMEST: Making the Green Matrix (Str) by PSCMP. Now working on NO: ',num2str(nd,'%5.0f'),' fault...']);
        %
        for pscmpni = 1:nfile
            %
            cfpara = fpara(nd,:);
            cfpara(cfpara(:,4)>90,3) = cfpara(cfpara(:,4)>90,3)+180;
            cfpara(cfpara(:,4)>90,4) = 180 - cfpara(cfpara(:,4)>90,4);
            % cfpara                   = sim_fpara2oversamplebyscale(cfpara,[1,1]);
            %
            % disp([meanstrike,meandip,meandepth]);
            outinp= [pscmpdir,'/p',num2str(pscmpni),'_n',num2str(nd),'_s',num2str(meanstrike),...
                '_d',num2str(meandip),'_de',num2str(meandepth),'_s.cfg'];
            %
            %
            if isoutput == 1
                sim_fpara2oksar(cfpara,[pscmpdir,'/p',num2str(pscmpni),'_n',num2str(nd),'_s',num2str(meanstrike),...
                    '_d',num2str(meandip),'_de',num2str(meandepth),'_s.oksar'],utmzone);
            end
            %
            %
            [topdir,outfilenames] = sim_pscmpcfg(cfpara,outpscmpinp{pscmpni},...
                'greendir',psgrndir,....
                'outinp',  outinp,...
                'isove',   0,...
                'utmproj', utmzone);
            %
            datacell = sim_pscmp(outinp,outfilenames,[topdir,'/']);
            mdata    = [mdata;datacell{1}];
            %
        end
        %
        dis.E   = mdata(:,4);
        dis.N   = mdata(:,3);
        dis.V   = mdata(:,5).*-1;
        %
    end
    %
    sim          = dis.E.*input(:,4)+dis.N.*input(:,5)+dis.V.*input(:,6);
    sgreen(:,nd) = sim;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fpara(nd,8)  = cosd(rakes(nd,2));
    fpara(nd,9)  = sind(rakes(nd,2));
    %
    % Calculate the green matrix for dip slip...
    % Update by Feng,W.P., @ GU, 2012-09-26
    %
    if strcmpi(earthmodel,'ELA')
        dis     = multiokadaALP(fpara(nd,:),x,y,0,alp,thd);
    else
        %
        % updated by FWP, using pscmp to replace edcmp...
        % 2013-05-22
        mdata = [];
        disp(['PS_SMEST: Making the Green Matrix (Dip) by PSCMP. Now working on NO: ',num2str(nd,'%5.0f'),' fault...']);
        %
        for pscmpni = 1:nfile
            %
            cfpara = fpara(nd,:);
            cfpara(cfpara(:,4)>90,3) = cfpara(cfpara(:,4)>90,3)+180;
            cfpara(cfpara(:,4)>90,4) = 180 - cfpara(cfpara(:,4)>90,4);
            %
            %cfpara                   = sim_fpara2oversamplebyscale(cfpara,[1,1]);
            %
            outinp= [pscmpdir,'/p',num2str(pscmpni),'_n',num2str(nd),'_s',num2str(meanstrike),...
                '_d',num2str(meandip),'_de',num2str(meandepth),'_d.cfg'];
            %
            if isoutput == 1
                %
                sim_fpara2oksar(cfpara,[pscmpdir,'/p',num2str(pscmpni),'_n',num2str(nd),'_s',num2str(meanstrike),...
                    '_d',num2str(meandip),'_de',num2str(meandepth),'_d.oksar'],utmzone);
            end

            %
            [topdir,outfilenames] = sim_pscmpcfg(cfpara,outpscmpinp{pscmpni},...
                'greendir',psgrndir,....
                'isove',   0,...
                'outinp',  outinp,...
                'utmproj', utmzone);
            datacell = sim_pscmp(outinp,outfilenames,[topdir,'/']);
            mdata    = [mdata;datacell{1}];
        end
        %
        dis.E   = mdata(:,4);
        dis.N   = mdata(:,3);
        dis.V   = mdata(:,5).*-1;
        %
    end
    %
    sim          = dis.E.*input(:,4)+dis.N.*input(:,5)+dis.V.*input(:,6);
    dgreen(:,nd) = sim;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargout == 4
        %
        fpara(nd,8)  = 0;
        fpara(nd,9)  = 0;
        fpara(nd,10) = 1;
        dis          = multiokadaALP(fpara(nd,:),x,y,0,alp,thd);
        sim          = dis.E.*input(:,4)+dis.N.*input(:,5)+dis.V.*input(:,6);
        tgreen(:,nd) = sim;
    end
end
%
green = [sgreen,dgreen];


