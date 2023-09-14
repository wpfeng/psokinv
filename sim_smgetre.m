function [fpara,smcof,corcof,stdv,mabcco,cinput,outvar,unfpara] = sim_smgetre(matfile,cdip,isplot,thd,isshowinfo)
%
%
% +Name:
%      sim_smgetre
% Input:
%       matfile, the result by ps_smest
%       cdip,    the best choice
%       isplot,  e.g,1:plot;0,don't plot...
%       thd,     the threshold of the roughness
% Output:
%       fpara, the SIM format
%       smcof, the smooth coefficient as you need.
%      corcof, the correlation of best-fit result
%        stdv, the standard deviation of best-fit result
%      mabcco, the abc result
%      cinput, infomation of input
% Created by Feng Wanpeng, IGP-CEA, 2009/10
% Modified by Feng, W.P, 2010/09/28.
%        -> fixed some bugs for output. Now the code should more concise.
%        -> if isplot == 6, don't plot any data ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Feng, W.P, 2010/10/14
%        -> add smcof output
%
if nargin < 1 || exist(MCM_rmspace(matfile),'file')==0
    disp('fpara = sim_smgetre(matfile,cdip,isplot,thd)');
    fpara  = [];
    mabcco = [];
    cinput = [];
    return
end
if nargin < 5
    isshowinfo = 1;
end
%
re     = load(MCM_rmspace(matfile));
inmat  = MCM_rmspace(matfile);
%
[matdir,matname,matext] = fileparts(inmat);
mcmat = [matdir,'/',matname,'_MC',matext];
if exist(mcmat,'file')
    inmatdb = load(mcmat);
    slipuncertainty = inmatdb.slipuncertainty;
else
    slipuncertainty = [];
end
%
%
mabic  = re.mabicre;
mdip   = re.mdip;
cinput = re.cinput;
lamda  = re.lamda;
mdip = re.mdip;
%
xlabels = {'x(km)','y(km)','strike(degree)','dip(degree)','dep(km)'};

%
% Updated by FWP,@UoG,2014-09-09
% A quick slip uncertainty can be provided by sim_smest...
%
if isfield(re,'slipuncertainty')
    slipuncertainty = re.slipuncertainty;
else
    slipuncertainty = [];
end

%
if nargin<3 || isempty(isplot)
    isplot = 3;
end
if nargin<4 || isempty(thd)
    thd    = 0.12;
end
if numel(thd)==1
    % Force to point this value for standard deviatoin
    thd = [thd,2];
end
if thd(2)~=3 && thd(2) ~= 2
   %
   disp(' *** thd only permits 2 or 3 for std and roughness ***');
   return
end
%
%
% number of iterations
ndip    = numel(mabic);
dipre   = zeros(ndip,4);
stddips = zeros(ndip,3);
%
if isplot<2 || isplot > 10
    %fig1    = figure('tag','mw','Name','MW&&Rought');
    fig2    = figure('tag','std','Name','Roughness&&std');
    fig3    = figure('tag','std&&mw','Name','STD&&MW');
end

for ni = 1:ndip
    %
    smest  = mabic{ni}.smest;
    %disp(smest)
    %whos smest
    roug   = smest(:,3);                                % Roughness
    stdd   = smest(:,2);                                % STD
    % smest
    cindex = find(abs(smest(:,thd(2))-thd(1)) == min(abs(smest(:,thd(2))-thd(1)))); % find minimum
    cindex = cindex(1);                                 % return only one
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    smre     = mabic{ni};                               % Result to per flag
    xslip    = smre.dismodel;                           % Distributed Model
    mwsmooth = zeros(1,3);
    fpara    = smre.disf;
    %
    for nmodel = 1:size(xslip,1)
      %
      cxslip        = xslip{nmodel};
      fpara(:,8)    = cxslip(1:end/3);
      fpara(:,9)    = cxslip(end/3+1:end/3*2);
      fpara(:,10)   = cxslip(end/3*2+1:end);
      [t_mp,m2,m3]  = sim_fpara2moment(fpara);
      %
      mwsmooth(nmodel,1) = smest(nmodel,1);            % Smooth Coefficience
      mwsmooth(nmodel,2) = m2;                         % MW
      mwsmooth(nmodel,3) = m3;                         % M0
      %
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %mwdist = mwsmooth(:,3).*exp(stdd-min(stdd));
    %%cindex = find(mwdist == min(mwdist));
    stddips(ni,1) = mdip(ni,3);                      % dip, flag dimension
    stddips(ni,2) = mwsmooth(cindex,3);              % MAX magnititude of EQ
    stddips(ni,3) = mwsmooth(cindex,2);              % MAX moment sclae of EQ
    stddips(ni,4) = cindex;
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isplot<2 || isplot> 10
        %
        figure(fig2);
        hold on
        plot(roug,stdd,'*-k');
        %%%%%%%%%%%%%%%%%%%%%%%%
        %
        %save test.mat roug stdd
        plot(roug(cindex),stdd(cindex),'dr','Markersize',6);
        text(roug(1),stdd(1),num2str(mdip(ni,3)));
        outrstd = [roug(:),stdd(:)];
        %
        outnames = [num2str(fpara(1,4)),'_DIP_Opt.inp'];
        outrstd  = [outrstd, smest(:,1)];
        eval(['save ',outnames,' outrstd -ascii']);
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(fig3);
        %
        plot(stdd,mwsmooth(:,2),'o-b','MarkerFaceColor',[1,1,1]);
        plot(stdd(cindex),mwsmooth(cindex,2),'o-b','MarkerFaceColor',[1,0,0]);
        text(stdd(1),mwsmooth(1,2),num2str(mdip(ni,3)));
        hold on
        %
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    dipre(ni,1) = mdip(ni,3);
    dipre(ni,2) = stdd(cindex);
    dipre(ni,3) = roug(cindex);
    dipre(ni,4) = cindex;
    %disp(['Optimal SM para: ' num2str(re.lamda(cindex))]);
end
%
if isplot==2
    %
    %
    if isempty(findobj('tag','hdipid'))==1
        %
       hdipid = figure('tag','hdipid','Name','Models && Parameters');
    else
        hdipid = findobj('tag','hdipid');
    end
    %
    figure(hdipid);
    hold on
    for ni = 1:numel(dipre(:,1))
        hid = plot(dipre(ni,1),dipre(ni,thd(2)),'o-b','MarkerFaceColor',[1,1,1],'MarkerSize',10);
        text(dipre(ni,1),dipre(ni,2)+0.0001,['P:' num2str(dipre(ni,1))]);
        hcmenu = uicontextmenu;
        %
        % Define the context menu items and install their callbacks
        %
        item1 = uimenu(hcmenu, 'Label', '3Dmodel', 'Callback', ['sim_smgetre(', '''' matfile, '''' ',',num2str(dipre(ni,1)), ',6,0.1);']);
        %item1 = uimenu(hcmenu, 'Label', '2Dmodel', 'Callback', ['sim_smgetre(', '''' matfile, '''' ',',num2str(dipre(ni,1)), ',7,0.1);']);
        %['sim_smgetre(', '''' matfile, '''' ',',num2str(dipre(ni,1)), ',6,0.1);']
        set(hid,'uicontextmenu',hcmenu);
        %
        hold on
    end
    %
    %
    index = find(dipre(:,thd(2))==min(dipre(:,thd(2))));
    %
    plot(dipre(index(1),1),...
         dipre(index(1),thd(2)),'*r','MarkerSize',8);
    %
    % replaced below line by FWP, 2021/12/24
    % xlabel('dip');
    xlabel(xlabels{mdip(1,2)});
    %
    if (thd(2) == 2)
        %
        ystring = 'STD';
    else
        ystring = 'Roughness';
    end
    ylabel(ystring);
    %
    %
    outdata = dipre(:,[1,thd(2)]);%[dipre(:,1), dipre(dipre(:,2)==min(dipre(:,2)),2)];
    eval(['save ',num2str(thd(1)),'.inp', ' outdata -ascii']);
    %
    outdata = [dipre(dipre(:,2)==min(dipre(:,2)),1), dipre(dipre(:,2)==min(dipre(:,2)),2)];
    eval(['save Optimal_',num2str(thd(1)),'.inp', ' outdata -ascii']);
    box on
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%% Min value
cflags = dipre(:,2);%.^(stddips(:,2));
if nargin < 2 || isempty(cdip) == 1
    cdip = mdip(cflags==min(cflags(:)),3);
end
iindex = find(mdip(:,3)==cdip);
%
if isempty(iindex) == 1
    disp( 'Warning: value you give did not appear in the result. Now Just use end of ones...');
    tcdip = mdip(stddips(:,2)==min(stddips(:,2)),3);
    disp(['         ' num2str(cdip) ' -> ' num2str(tcdip)]);
    cdip = tcdip;
    iindex = find(mdip(:,3)==cdip);
else
    cdip = mdip(iindex(1),3);
end
% disp(cdip);
smre  = mabic{iindex};
xslip = smre.dismodel;
xslip = xslip{stddips(iindex,4)};
fpara = smre.disf;
isabc = isfield(smre,'mabc');
if isabc~=0
   mabc  = smre.mabc;
end
cindex= stddips(iindex,4);
if isabc~=0
  abc   = mabc{cindex,1};
  abccof= mabc{cindex,3};
  mabcco= abccof(:,2:4);
else
  abc   = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% structure a abc coef
if isempty(abc)~=1
   counter = 0;
   for ni =1:size(abccof,1)
       if mabcco(ni,1) == 0
          mabcco(ni,:) = 0;
          index        = [];
       else
         % modified by Feng, Based the result of Li's testing...
         index = [];  
         if mabcco(ni,2) ==1
            index = [1,2];
         end
         if mabcco(ni,3)==1
            index = [index,3];
         end
         mabcco(ni,index) = abc(counter+1:counter+numel(index));
         if index == 3
            mabcco(ni,1) = 0;
         end
       end
       counter = counter + numel(index);
       index   = [];
   end
else
   mabcco = zeros(size(cinput,1),3);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%mwindex    = find(stddips(:,2)==min(stddips(:,2)));
fpara(:,8) = xslip(1:end/3);
fpara(:,9) = xslip(end/3+1:end/3*2);
fpara(:,10)= xslip(end/3*2+1:end);
%%%%% define what is the standard for the minimum
%newcol = stddips(:,2);%.*exp(dipre(:,3)./max(dipre(:,3)));
%index  = find(newcol == min(newcol));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isplot==5 || isplot > 10
    figure('Name','OBS-SIM');
    plot(re.input(:,3),'LineWidth',2.5);
    hold on;
    plot(smre.osim{1},'-r');
    %
    legend('OBS','SIM');
    ndata = numel(cinput);
    
    for nf = 1:ndata
        input = sim_inputdata(cinput{nf}{1});
        if numel(input) > 0
            [t_mp,fname] = fileparts(cinput{nf}{1});
            disv         = multiokadaALP(fpara,input(:,1),input(:,2));
            simo         = disv.E.*input(:,4)+...
                           disv.N.*input(:,5)+...
                           disv.V.*input(:,6)+...
                           input(:,1).*mabcco(nf,1)+...
                           input(:,2).*mabcco(nf,2)+...
                           (input(:,2).*0+1).*mabcco(nf,3);
            disp([corr(simo,input(:,3)),numel(input(:,1))]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            res     = simo-input(:,3);
            x       = input(:,1);
            y       = input(:,2);
            mindist = sim_mindistv2([x(:) y(:)]);
            np      = size(x(:),1);
            XI      = zeros(np,5);
            YI      = zeros(np,5);
            XI(:,1) = x-mindist/2;
            XI(:,2) = x+mindist/2;
            XI(:,3) = x+mindist/2;
            XI(:,4) = x-mindist/2;
            XI(:,5) = x-mindist/2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            YI(:,1) = y-mindist/2;
            YI(:,2) = y-mindist/2;
            YI(:,3) = y+mindist/2;
            YI(:,4) = y+mindist/2;
            YI(:,5) = y-mindist/2;
            %disp('FENG W.P...');
            hold on
            %sim_fig3d(fpara);
            figure();
            %subplot(ndata,1,nf);
            patch(XI',YI',res');
            title(fname);
            colorbar;
            caxis([min(res),max(res)]);
            xlim = get(gca,'XLim');
            ylim = get(gca,'YLim');
            axis equal;
            set(gca,'XLim',xlim);
            set(gca,'YLim',ylim);
            box on;
            %disp('FENG W.P...');
        end
    end
    %
end
%
if isplot == 6 
    figure('Name','Model in 3D');
    sim_fig3d(fpara);
end
if isplot == 7 
    %
    sim_fixmodelview2D(fpara,mean(fpara(:,3)),0.1:0.2:10.0,10);
end
%
osim    = mabic{iindex(1)}.osim;
osim    = osim{stddips(iindex,4)};
corcof  = corr2(re.input(:,3),osim);
stdv    = sim_rms(re.input(:,3)-osim);
smcof   = lamda(stddips(iindex,4));
outvar = mdip(iindex(1),3);
%
if isshowinfo == 1
    %
    disp('*****************************************************');
    %
    %disp(['DIP_BUSER - DIP_BPROG: [' ,num2str(mdip(iindex(1),3)),' , ',num2str(mdip(bindex(1),3)),']']);
    disp(['Correlation   Coef:    ' ,num2str(corcof)]);
    disp(['Residuals RMS:    ' ,num2str(stdv)]);
    disp(['Smooth Coefficient:    ' ,num2str(smcof(1))]);
    disp(['Best-fit(dip dege):    ' ,num2str(mdip(iindex(1),3))]);
end
%
unfpara = fpara;
unfpara(:,8) = 0;
unfpara(:,9) = 0;
if ~isempty(slipuncertainty)
    %
    disp(' sim_smgetre: reading the uncertainties...')
    unfpara(:,8)  = slipuncertainty(1:end/3) .* 10000;
    unfpara(:,9)  = slipuncertainty(end/3+1:end/3*2) .* 10000;
    unfpara(:,10) = slipuncertainty(end/3*2+1:end) .* 10000;
end

