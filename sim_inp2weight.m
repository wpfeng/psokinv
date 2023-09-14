function sim_inp2weight(inp,model)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created by FWP, 2012-10-09
%
if nargin < 2
    model = 'bin';
end
%
[bdir,bname] = fileparts(inp);
tmp          = textscan(bname,'%s','delimiter','UTM');
flag         = textscan(bname,'%s','delimiter','_');
%
%
switch flag{1}{end-3}
    case 'RBASED'
        cflag = 'rb';
    case 'UNIFORM'
        cflag = 'quad';
    case 'QUAD'
        cflag = 'quad';
end
llinp        = fullfile(bdir,[tmp{1}{1},'LL.inp']);
xy           = fullfile(bdir,[tmp{1}{1},'LL.',cflag,'.box.xy']);
%
outname      = fullfile(bdir,[bname,'.cov.mat']);
%
switch model
    case 'bin'
       inpsize = sim_inp2size(xy,llinp);
       weig    = sqrt(inpsize)./sum(sqrt(inpsize));
    case 'std'
end
vcm  = diag(weig);
save(outname,'vcm');
