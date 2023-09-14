function psokinv_psokinv_create_cfg(psokinv)
%
%
% Part of UI version for PSOKINV
% Created by Feng,W.P.,@ BJ, 2010
% 
confname = psokinv.cfg;
nfaults  = size(psokinv.faultintpara,1);
clocal   = psokinv.locals;
isinv    = psokinv.isinv;
% disp(psokinv.inpids)
inpfile  = psokinv.inps(psokinv.inpids);
parts    = psokinv.particles;
lamda    = psokinv.lambda;
myu      = psokinv.mu;
oksarout = psokinv.outoksar;
matfile  = psokinv.outmat;
iterations = psokinv.psoiteration;
dispSIM    = psokinv.sampleinfoshow;
itersSIM   = psokinv.simpleiteration;
ntimes     = psokinv.restartnum;
ismc       = psokinv.inpmc;
mcloops    = psokinv.mcinversionloop;
mcdir      = psokinv.mcinpdir;
mindist    = psokinv.convermindis;
if iscell(mcdir)
    mcdir = mcdir{1};
end
mcsave     = psokinv.outdir;
%whos mcsave
if iscell(mcsave)
    mcsave = mcsave{1}{1};
end
%
intpara    = psokinv.faultintpara;
intabc     = psokinv.inpabc(psokinv.inpids,:);
isvcm      = psokinv.isvcm;
rake       = psokinv.rakes;
%abcs       = psokinv.inpabc;
inpmc         = intabc(:,end);
%psokinv.inpabc
weights       = psokinv.weight(psokinv.inpids);
intabc(:,4)   = weights(:);

for ni =1:size(intabc,1)
    if intabc(ni,2)+intabc(ni,3) == 0 
        intabc(ni,1) = 0;
    else
        intabc(ni,1) = 1;
    end
end
if ischar(inpfile)
    inpfile = {'NULL'};
    vcms    = {'NULL'};
else
    vcms = inpfile;
    for ni = 1:numel(inpfile)
        %
        [bpath,bname,cext] = fileparts(inpfile{ni});
        vcms{ni}      = fullfile(bpath,[bname,'.vcm.mat']);
        %
        if exist(vcms{ni},'file')==0
           vcms{ni} = 'NULL';
        end
    end
end
%
% whos intpara
%    
% whos intpara
sim_invconfig(confname,nfaults,clocal,isinv,...
                       inpfile,parts,lamda,myu,oksarout,...
                       matfile,iterations,dispSIM,itersSIM,...
                       ntimes,ismc,mcloops,mcdir,mcsave,intpara,...
                       intabc,isvcm,rake,vcms,inpmc,mindist);