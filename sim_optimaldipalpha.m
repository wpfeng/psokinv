function outabic = sim_optimaldipalpha(matfile,outfile,thresh,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% ABIC estimation
%
% Created by Feng,W.P.,@ GU, 2012-09-27
%
%
if nargin < 3
    thresh = [];
end
isplot = 0;
if nargin>=4
    isplot=1;
end
%
matdir  = fileparts(matfile);
if nargin < 2 || isempty(outfile)
    outfile = 'tradeoff_alphadip.inp';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
binfo   = load(matfile);
mabic   = binfo.mabicre;
mdip    = binfo.mdip;
fpara   = binfo.fpara;
sarea   = mean(fpara(:,6))*mean(fpara(:,7));
mdip    = mdip(:,3);
mG      = cell(numel(mdip),2);
input   = binfo.input;
%
%
for ni = 1:numel(mdip)
    %
    mats     = ['*',num2str(mdip(ni)),'.mat'];
    cmat     = dir(fullfile(matdir,mats));
    fullmat  = fullfile(matdir,cmat(1).name);
    gmatrix  = load(fullmat);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mG{ni,1} = gmatrix.G;
    mG{ni,2} = gmatrix.lap;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%
clap = gmatrix.lap;
if iscell(clap)
    L = clap{1};
else
    L = clap;
end

%
P    = rank(L);
N    = numel(input(:,1));
cg   = mG{ni,1};
M    = numel(cg(1,:));
%
counter = 0;
outabic = zeros(1,5);
stds    = [];
for ni = 1:numel(mdip)
    %
    cre   = mabic{ni};
    smest = cre.smest;
    %
    if isempty(thresh)==0
        smest = smest(smest(:,1)<=thresh,:);
    end
    %
    smest(:,3) = smest(:,3);%sarea;
    stds       = [stds;smest(:,2)];
    %
    if ni == 1
        minrough = min(smest(:,3));
        maxrough = max(smest(:,3));
        minstd   = min(smest(:,2));
        maxstd   = max(smest(:,2));
        %
    else
        %
        if minrough > min(smest(:,3))
            minrough = min(smest(:,3));
        end
        if minstd > min(smest(:,2))
            minstd = min(smest(:,2));
        end
        if maxrough < max(smest(:,3))
            maxrough = max(smest(:,3));
        end
        if maxstd < max(smest(:,2))
            maxstd = max(smest(:,2));
        end
        %
    end
end
%
counter = 0;
outabic = [];
rabic   = [];
%
for ni = 1:numel(mdip)
    %
    dip        = mdip(ni);
    cre        = mabic{ni};
    smest      = cre.smest;
    smest(:,3) = smest(:,3);%./sarea;
    alpha      = smest(:,1);
    %
    if isempty(thresh)==0
        alpha = alpha(alpha<=thresh);
    end
    %
    for nj = 1:numel(alpha)
        %
        calpha     = alpha(nj);
        mterm1(nj) = (smest(nj,2)-minstd)/(maxstd-minstd);
        mterm4(nj) = (smest(nj,3)-minrough)/(maxrough-minrough);
        %
    end
    mterm11 = mterm1/max(mterm1);
    mterm44 = mterm4/max(mterm4);
    %
    flags  = log(mterm11(:)+mterm44(:));
    %cflags = mterm1(flags==min(flags(:)));
    %
    cdips   = repmat(dip,numel(alpha),1);
    cabic   = [cdips,alpha(:),flags,mterm1(:),mterm4(:)];
    outabic = [outabic;cabic];
    %rabic   = [rabic;[cdips,alpha(:),(2575-2)*log(smest(:,2)+smest(:,3))-(600-2)*log(alpha(:)),smest(:,2),smest(:,3)]];
end
%
fid = fopen(outfile,'w');
fprintf(fid,'%f %f %f %f %f\n',outabic(:,:)');
fclose(fid);
%
if isplot>0
    x = outabic(:,1);
    y = outabic(:,2);
    z = outabic(:,3);
    num = numel(x)*4;
    [X,Y,Z] = griddata(x,y,z,linspace(min(x),max(x),num)',...
        linspace(min(y),max(y),num));
    %
    disp([min(y),max(y)]);
    contourf(X,Y,Z);
    hold on
    %
    minx = x(z==min(z));
    miny = y(z==min(z));
    minz = z(z==min(z));
    %
    plot(minx,miny,'sr');
    text(minx(1),miny(1),['(',num2str(minx(1)),',',num2str(miny(1)),')']);
    %
    xlabel('Dip(deg)');
    ylabel('Smoothing parameters(alpha)');
    colorbar();
end