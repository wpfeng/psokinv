function [outfpara,outre] = ps_nz_bestmodel(nof,nop,minp,maxp,numstep,alphas,bname,jointindex)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
if nargin < 1
    nof = 1;
end
if nargin < 2 || isempty(nop)
    nop = 3;
end
if nargin < 3 || isempty(minp)
    minp = 0.5;
end
if nargin < 4 || isempty(maxp)
    maxp = 180;
end
if nargin < 5 || isempty(numstep)
    numstep = 2;
end
if nargin < 6 || isempty(alphas)
    alphas = 10:10:10;
end
%
if nargin < 7 || isempty(bname)
   bname   = 'CON_NZ_6faults';
end
if nargin < 8 || isempty(jointindex)
    jointindex = [];
end
nump    = 3;  % number of patches
counter = 0;
inpfile   = {'inp/geo_100813-100928_P337A_UTM59S_roi_roiv2_UNIFORM_PHASE.inp',...
             'inp/T631D_roi_roiv2_UNIFORM_PHASE.inp'};
cfpara    = cell(nump,1);
mPS       = cell(nump,1);
whichbnds = cell(nump,1);
mC        = cell(numel(inpfile),1);
%
prange    = linspace(minp,maxp,numstep);
outfpara  = cell(numel(prange),1);
outre     = zeros(numel(outfpara),3);
typenames = {'X','Y','Str','Dip','Wid','Len'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for noprang = prange
    outmat  = ['fixmodel/',bname,'_No',num2str(nof),'Fault_',typenames{nop},num2str(noprang),'.mat'];
    counter = counter + 1;
    if exist(outmat,'file')==0
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        input   = [];
        for ninp = 1:numel(inpfile)
            tmpinput = sim_inputdata(inpfile{ninp});
            mC{ninp} = diag(ones(numel(tmpinput(:,1)),1));
            input    = [input;tmpinput];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fpara          = sim_oksar2SIM('oksar/NZ10_2obs_6faults_unif.oksar');
        fpara(nof,nop) = noprang;
        if isempty(jointindex) == 0
            rfpara              = sim_fpara2cross(fpara(jointindex,:));
            fpara(jointindex,:) = rfpara;
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % global parameters
        wid     = 20;
        pw      = 1;
        pl      = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % segement-1
        %
        fpara(1,7) = 12;
        [x1,y1] = sim_fpara2corners(fpara(1,:),'ul');
        [x2,y2] = sim_fpara2corners(fpara(1,:),'ur');
        t1      = [x1,y1;x2,y2];
        [fpara1,tf1,mps1] = sim_trace2fpara(t1,[],fpara(1,4),wid,pw,pl);
        %
        % segement-2
        %
        fpara(2,7) = 12;
        [x1,y1] = sim_fpara2corners(fpara(2,:),'ul');
        [x2,y2] = sim_fpara2corners(fpara(2,:),'ur');
        t1      = [x1,y1;x2,y2];
        [fpara2,tf2,mps2] = sim_trace2fpara(t1,[],fpara(2,4),wid,pw,pl);
        %
        % segment-3
        rfpara = sim_fpara2cross(fpara(3:6,:));
        ps = [];
        dips = [];
        for ni=1:4
            [x1,y1] = sim_fpara2corners(rfpara(ni,:),'ul');
            [x2,y2] = sim_fpara2corners(rfpara(ni,:),'ur');
            if ni == 1
                ps = [ps;x1,y1;x2,y2];
                dips= [dips;rfpara(ni,4);rfpara(ni,4)];
            else
                ps = [ps;x2,y2];
                dips=[dips;rfpara(ni,4)];
            end
        end
        [fpara3,tf3,mps3] = sim_trace2fpara(ps,[],dips,wid,pw,pl);
        fpara3 = sim_fpara2azi(fpara3);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cfpara{1}      = fpara1;
        cfpara{2}      = fpara2;
        cfpara{3}      = fpara3;
        rakecons       = [1,45,135;...
            1,45,135;...
            1,90,180];
        whichbnds{1}   = {'R','L','B'};
        whichbnds{2}   = {'R','L','B'};
        whichbnds{3}   = {'R','L','B'};
        mPS{1}         = mps1;
        mPS{2}         = mps2;
        mPS{3}         = mps3;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        cfpara   = [];
        input    = [];
        rakecons = [];
        mC       = [];
        mPS      = [];
        whichbnds= [];
    end
    [mfpara,outres]= sim_fpara2distmodel(cfpara,input,rakecons,mC,mPS,alphas,0,'cgls',whichbnds,outmat);
    outfpara{counter} = mfpara;
    %whos outres
    minres           = min(outres(:,2));
    [~,~,mw]         = sim_fpara2moment(mfpara{outres(:,2)==minres});
    outre(counter,:) = [noprang,minres,mw];
    %plot(outres(:,3),outres(:,2),'o-r');
end
