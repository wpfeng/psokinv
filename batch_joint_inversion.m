%
% Developed by Wanpeng Feng, @NRCan, 2016-09-27
% Joint inversion for both water level changing and shallow slip
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
mat1 = 'pSM_rate_creep/pSM_rate_creep_No1Fault_Dip89.mat';
mat2 = 'pSM_rate_waterextraction/pSM_rate_waterextraction_No1Fault_Dip2.mat';
%
zone   = '11S';
%
dbmat1 = load(mat1);
dbmat2 = load(mat2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Water extraction
wfpara = dbmat2.disf;
wf_ub  = dbmat2.ub;
wG     = dbmat2.G;
wlap   = dbmat2.lap{1};
wfnum  = numel(wfpara(:,1));
wf_ub  = wf_ub(1:end/2);
wG     = wG.*-1;
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fault creep
%
r1     = -135;
r2     =  135;
sfpara = dbmat1.disf;
sf_ub  = dbmat1.ub;
sG     = dbmat1.G;
slap   = dbmat1.lap{1};
slap   = [slap slap.*0; slap.*0 slap];
sfnum  = numel(sfpara(:,1));
%
ub     = [wf_ub;sf_ub];
lb     = ub.*0;
%
strG      = sG(:,1:end/2);
dipG      = sG(:,end/2+1:end);
[soG,doG] = sim_greentransform(strG,dipG,r1,r2);
sG        = [soG doG];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
G             = [wG sG];
[sizea,sizeb] = size(G);
L             = zeros(sizeb,sizeb);
L(1:numel(wlap(:,1)),1:numel(wlap(:,1))) = wlap;
L(numel(wlap(:,1))+1:end,numel(wlap(:,1))+1:end) = slap;
L             = L./400;
%
%
input = dbmat1.input;
D = [input(:,3);L(:,1).*0];
%
for alpha = 20
    %
    A            = [G;alpha.*L];
    %
    %A            = [wG;alpha.*wlap];
    %D            = [input(:,3);wlap(:,1).*0];
    %ub           = wf_ub;
    %lb           = ub.*0;
    %
    Maslip       = cgls_bvls(A,D,lb,ub);
    vstd         = std(input(:,3)-G*Maslip);
    closingv     = Maslip(1:wfnum);
    wfpara(:,10) = closingv.*-1;
    %
    vslip        = Maslip(wfnum+1:end);
    s_slip       = vslip(1:end/2);
    d_slip       = vslip(end/2+1:end);
    %
    soslip       = s_slip.*cosd(r1) + d_slip.*cosd(r2);
    doslip       = s_slip.*sind(r1) + d_slip.*sind(r2);
    sfpara(:,8)  = soslip;
    sfpara(:,9)  = doslip;
    %
end
%
sim_fpara2simp(wfpara,'oksar/Joint_waterlevel_change.simp',zone);
sim_fpara2simp(sfpara,'oksar/Joint_afterslip.simp',zone);
sim_fpara2simp([wfpara;sfpara],'oksar/Joint_dist.simp',zone);
%