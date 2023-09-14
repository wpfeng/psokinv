function outsimI = psokinv_simglobal(cfgfile,varargin)
%
%
% Developed by FWP, @ Institute of Geophysics and Planetary Physics
%                     Scripps institution of Oceanography, UCSD
% 2013-10-05
%
% A stress tensor in 3D using half-space elastic dislocation can be
% generated, by FWP, @ UoG. New parameter for media_model is "stress"
% 2014-03-23
%
if nargin < 1
    %
    disp('psokinv_simglobal(cfgfile,varargin)');
    disp('******************************************');
    disp('cfgfile, a configure file working for ps_sim');
    disp('varargin allows a few parameters including: ');
    disp('   ispara       -  flag for parallel computation, 0 in default')
    disp('   media_model  -  half-space/elastic (ELA) or layered elastic (lay)')
    disp('   greedir      -  a folder for saving green functions used for a layered elatic earth model');
    disp('   days         -  working for postseismic viscoelastic deformation  calculation');
    disp('   depth        -  viscoelastic depth')
    disp('   outpixelsize -  given pixel sizes or determined from input interferograms')
    disp('   simulation   -  lbl for line by line, or mo for matrix once');
    disp('Developed by Feng, W.P., @ UoG, 2013-09-09');
    disp('Updated by Feng, W.P., @ YJ, 2015-05-05');
    disp('Updated by Wanpeng Feng, @NRCan, 2016-05-05. Now Okada3D will be allowed. A depth data should be provided as well.');
    disp('wanpeng.feng@hotmail.com for any error report');
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initite parameters for simulation
%
ispara       = 0;
media_model  = 'ELA';
greendir     = 'psgrn';
days         = 0;
depth        = 10;
isgravity    = 0;
outpixelsize = [];
simulation   = 'lbl'; %
jumpline     = 1;
%
for ni = 1:2:numel(varargin)
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'= val;']);
end
%
if strcmpi(media_model,'lay') && strcmpi(simulation,'mo')
    disp(' Simulation mode will be forcely converted to LBL for LAY');
    simulation = 'LBL';
end
%
if strcmpi(media_model,'E3D') && strcmpi(simulation,'mo')
    disp(' Simulation mode will be forcely converted to LBL for E3D');
    simulation = 'LBL';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if ispara == 1
    sar_matlabparallel;
end
%
if isempty(outpixelsize)==0 && numel(outpixelsize)==1
    outpixelsize = [outpixelsize,outpixelsize];
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
siminfo = sim_getsimcfg(cfgfile);
%
unwf    = siminfo.unwf;
%
% Updated by Feng, W.P., @ YJ, 2015-05-05
% Calculate simulation using a large region
rscs = cell(numel(unwf),1);
dems = rscs;
for ni = 1:numel(unwf)
    %
    rscs{ni} = [unwf{ni},'.rsc'];
    %
    % Updated by Wanpeng Feng, @NRCan, 2016-05-5
    % A depth data, with extension of dem may be available for 3D
    % application.
    %
    dems{ni} = [unwf{ni},'.dem'];
end
%
%
[roi,t_mp,pixelsize]   = sar_rscs2roi(rscs,'out',0);
unwinfo             = sim_roirsc();
if isempty(outpixelsize)
    minx = max(pixelsize(1,:));
    miny = max(abs(pixelsize(2,:)));
else
    minx = outpixelsize(1);
    miny = outpixelsize(2);
end
unwinfo.x_first     = roi(1) - minx;
unwinfo.y_first     = roi(4) + miny;
unwinfo.width       = floor((roi(2)-roi(1))/minx) + 5;
unwinfo.file_length = floor((roi(4)-roi(3))/miny) + 5;
unwinfo.x_step      = minx;
unwinfo.y_step      = miny*(-1);
%
oksar   = MCM_rmspace(siminfo.oksarfile);
% updated by Feng, W.P., @ Yj, 2015-05-20
% .simp is avaialbe in current version...
%
[t_mp,t_mp,postfix] = fileparts(oksar);
switch upper(postfix)
    case '.SIMP'
        [fpara,zone] = sim_simp2fpara(oksar);
    otherwise
        [fpara,zone]   = sim_oksar2SIM(oksar);
        %zone    = sim_oksar2utm(oksar);
end
%
% Define the output direcotry and fullpath filenames...
%
if ~exist(siminfo.savedir,'dir')
    mkdir(siminfo.savedir);
end
%
[t_mp,bname] = fileparts(cfgfile);
%
outsim = fullfile(siminfo.savedir,...
    [siminfo.simpref,bname,siminfo.postfix]);
%
if strcmpi(media_model,'stress')==0
    outsimI{1} = [outsim,'_E.los']; % E
    outsimI{2} = [outsim,'_N.los']; % N
    outsimI{3} = [outsim,'_U.los']; % U
    outsimI{4} = [outsim,'_GR.los']; % U
else
    post = num2str(depth);
    outsimI{1} = [outsim,'_D',post,'_xx.str']; % E
    outsimI{2} = [outsim,'_D',post,'_yy.str']; % N
    outsimI{3} = [outsim,'_D',post,'_zz.str']; % U
    outsimI{4} = [outsim,'_D',post,'_xz.str']; % E
    outsimI{5} = [outsim,'_D',post,'_yz.str']; % N
    outsimI{6} = [outsim,'_D',post,'_xy.str']; % U
end
%
info = dir(outsimI{1});
if ~isempty(info) && info.bytes > 0
    %disp(' Simulation has been finished previously! Check manually!');
    return
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
mfid    = zeros(3,1);
for ni = 1:numel(outsimI)
    sim_croirsc([outsimI{ni},'.rsc'],unwinfo);
    mfid(ni) = fopen(outsimI{ni},'w');
end
%
xrange = [unwinfo.x_first,unwinfo.x_first+(unwinfo.width-1)*unwinfo.x_step];
x      = xrange(1):unwinfo.x_step:xrange(2);
cmx    = zeros(unwinfo.file_length,unwinfo.width);
lmx    = cmx;
lmy    = cmx;
%
for ni = 1:unwinfo.file_length
    %
    y = x.*0 + unwinfo.y_first+(ni-1)*unwinfo.y_step;
    %
    lmx(ni,:) = x;
    lmy(ni,:) = y;
end
%
[mx,my] = ll2utm(lmy,lmx,zone);
cmx     = mx./1000;
cmy     = my./1000;
%
disp(['PSOKINV_GLOBAL_SIMULATION: Start simulation by ',media_model,' Earth Model in mode of ',simulation]);

disp(['  -> Output simulated Interferograms will have a size by ',num2str(unwinfo.width),' X ',num2str(unwinfo.file_length),' ']);
if strcmpi(media_model,'E3D')
    disp(['     Extrating Depth data from',dems{1}]);
end
%
tic;
% Force the simualtion method to line by line...
% by Feng, W.P., @NRcan, 2015-10-14
%
if strcmpi(media_model,'lay')
    simulation = 'LBL';
end
%
switch upper(simulation)
    case 'LBL'
        for ni = 1:jumpline:unwinfo.file_length
            %
            if ni+jumpline-1 < unwinfo.file_length
                endind = ni+jumpline-1;
            else
                endind = unwinfo.file_length;
            end
            %
            lcmx = cmx(ni:endind,:);
            lcmy = cmy(ni:endind,:);
            %
            lonx = lmx(ni:endind,:);
            laty = lmy(ni:endind,:);
            lz   = lonx.*0;
            %
            switch upper(media_model)
                %
                case 'E3D'
                    %
                    if ~exist(dems{1},'file')
                       disp(' ERROR: depth data cannot be found!');
                       return
                    end
                    %
                    %
                    depth = sim_roi2profile(dems{1},'float',lonx,laty,1,1);
                    %
                    dis = multiokada3D(fpara,lcmx(:),lcmy(:),depth);
                    %
                    % Add coseismic gravity change calculation in default
                    % by FWP, @GU, 2014-06-26
                    
                    if isgravity == 1
                        dG  = sim_elagravitychng(lcmx,lcmy,fpara);
                        fwrite(mfid(4),reshape(dG(:),endind-ni+1,unwinfo.width)','float32');  % U
                    end
                    %
                    fwrite(mfid(1),reshape(dis.E,endind-ni+1,unwinfo.width)','float32');  % E
                    fwrite(mfid(2),reshape(dis.N,endind-ni+1,unwinfo.width)','float32');  % N
                    fwrite(mfid(3),reshape(dis.V,endind-ni+1,unwinfo.width)','float32');  % U
                    %
                case 'ELA'
                    dis = multiokadaALP(fpara,lcmx,lcmy);
                    % Add coseismic gravity change calculation in default
                    % by FWP, @GU, 2014-06-26
                    if isgravity == 1
                        dG  = sim_elagravitychng(lcmx,lcmy,fpara);
                        fwrite(mfid(4),reshape(dG(:),endind-ni+1,unwinfo.width)','float32');  % U
                    end
                    %
                    fwrite(mfid(1),reshape(dis.E,endind-ni+1,unwinfo.width)','float32');  % E
                    fwrite(mfid(2),reshape(dis.N,endind-ni+1,unwinfo.width)','float32');  % N
                    fwrite(mfid(3),reshape(dis.V,endind-ni+1,unwinfo.width)','float32');  % U
                    %
                case 'STRESS'
                    %
                    dis = multiokada3Dstress(fpara,lcmx,lcmy,lcmx.*0+depth,0,0,0,0,...
                        0,0,[],[],0.0001,1);
                    %
                    fwrite(mfid(1),reshape(dis.sxx,endind-ni+1,unwinfo.width)','float32');  % E
                    fwrite(mfid(2),reshape(dis.syy,endind-ni+1,unwinfo.width)','float32');  % N
                    fwrite(mfid(3),reshape(dis.szz,endind-ni+1,unwinfo.width)','float32');  % U
                    fwrite(mfid(4),reshape(dis.sxz,endind-ni+1,unwinfo.width)','float32');  % E
                    fwrite(mfid(5),reshape(dis.syz,endind-ni+1,unwinfo.width)','float32');  % N
                    fwrite(mfid(6),reshape(dis.sxy,endind-ni+1,unwinfo.width)','float32');  % U
                    %
                case 'LAY'
                    %
                    %
                    [t_mp,pscmpsavedir] = fileparts(cfgfile);
                    %
                    [t_mp,greendirtxt]  = fileparts(greendir);
                    cx = lmx(ni:endind,:);
                    cy = lmy(ni:endind,:);
                    outpscmpcfg = ['PSCMP_',greendirtxt,'_',num2str(ni),'.cfg'];
                    [topdir,outfilenames] = sim_pscmpcfg(oksar,[cx(:),cy(:)],....
                        'greendir',greendir,...
                        'outinp',outpscmpcfg,...
                        'isove',0,...
                        'days',days);
                    %
                    data = sim_pscmp(outpscmpcfg,outfilenames,topdir);
                    %
                    if iscell(data)
                        data = data{1};
                    end
                    %
                    e  = data(:,4)';
                    n  = data(:,3)';
                    u  = data(:,5)'.*-1;
                    gr = data(:,16)';
                    %
                    fwrite(mfid(1),reshape(e,endind-ni+1,unwinfo.width)','float32');  % E
                    fwrite(mfid(2),reshape(n,endind-ni+1,unwinfo.width)','float32');  % N
                    fwrite(mfid(3),reshape(u,endind-ni+1,unwinfo.width)','float32');  % U
                    %
                    fwrite(mfid(4),reshape(gr,endind-ni+1,unwinfo.width)','float32');  % U
                    %
            end
            %
            if mod(ni,100)==0
                ratio = (unwinfo.file_length-ni)./unwinfo.file_length;
                disp(['PSOKINV_GLOBAL_SIMULATION: Only ',num2str(ratio.*100,'%4.2f'),'% left...']);
            end
            %
        end
    case 'MO'
        %
        switch upper(media_model)
            case 'ELA'
                dis = multiokadaALP(fpara,cmx,cmy);
                % add coseismic gravity change calculation in default
                % by FWP, @GU, 2014-06-26
                if isgravity == 1
                    dG  = sim_elagravitychng(cmx,cmy,fpara);
                    fwrite(mfid(4),dG','float32');  % U
                end
                %
                fwrite(mfid(1),dis.E','float32');  % E
                fwrite(mfid(2),dis.N','float32');  % N
                fwrite(mfid(3),dis.V','float32');  % U
                %
            case 'STRESS'
                %
                dis = multiokada3Dstress(fpara,cmx,cmy,cmx.*0+depth,0,0,0,0,...
                    0,0,[],[],0.0001,1);
                %
                fwrite(mfid(1),dis.sxx','float32');  % E
                fwrite(mfid(2),dis.syy','float32');  % N
                fwrite(mfid(3),dis.szz','float32');  % U
                fwrite(mfid(4),dis.sxz','float32');  % E
                fwrite(mfid(5),dis.syz','float32');  % N
                fwrite(mfid(6),dis.sxy','float32');  % U
        end
        %
    otherwise
        %
        disp(' You do not provide correct simulation mode. Please check again!!!');
        %
end
toc;
%
for ni = 1:numel(mfid)
    fclose(mfid(ni));
end
disp('PSOKINV_GLOBAL_SIMULATION: Congradulations! The simulated displacement is done!');
disp('******************************************************************************');
%
fid = fopen([siminfo.savedir,'/SIM.log'],'a');
%
fprintf(fid','%s %s %s\n','>>>>>>>>>> On ',date,', one job is done!!! >>>>>>>>>>>>>>');
fprintf(fid,'%s %s\n','  OKSARFILE   - ',  siminfo.oksarfile);
fprintf(fid,'%s %s\n','  Simulated_E - ',  outsimI{1});
fprintf(fid,'%s %s\n','  Simulated_N - ',  outsimI{2});
fprintf(fid,'%s %s\n','  Simulated_U - ',  outsimI{3});
fclose(fid);
%
return
%
