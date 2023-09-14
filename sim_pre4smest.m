function [disfpara,input,G,lap,lb,ub,am,cinput,vcm] = sim_pre4smest(fpara,inf,...
                                                      dx,dy,L,W,topdepth,whichnon,abc,isabc,alpha)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************

%
% Create by Feng,W.P., @BJ, 2009/10/01
% Updated by W.P. Feng, @GU, 2012/09/27
%
global dweight vcmtype earthmodel mrakecons rakecons
vcmtype = 'NULL';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin <3 || isempty(dx)==1
    dx = 1;
end
if nargin <4 || isempty(dy)==1
    dy = 1;
end
if nargin <5 || isempty(L)==1
    L = fix(fpara(7)*1.5);
end
if nargin <6 || isempty(W)==1
    W = fix(fpara(6)*1.5);
end
if nargin <7 || isempty(whichnon)==1
    whichnon = [];
end
if nargin <9 || isempty(isabc)==1
    isabc = 0;
end
if isempty(abc)==1
    abc = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[psoPS,cinput,symbols,outoksar,abccof,outmatf,tfpara,...
    lamda,myu,aa,aa,aa,aa,weighs,vcms,a,a,a,a,a,a,a,a,a,a,a,a,isvcm] = sim_readconfig(inf);
%
weighs  = weighs./sum(weighs);
dweight = [];
%
for ni=1:size(cinput,1)
    %
    % Modified by Wanpeng Feng, now the height variation at reference
    % points can be considered...
    % @NRCan, 2016-04-21
    %
    if ~exist(cinput{ni}{1},'file')
        disp(cinput{ni}{1})
    end
    TMP_data = load(cinput{ni}{1});
    tmp_weig = zeros(size(TMP_data,1),1)+weighs(ni);
    dweight  = [dweight;tmp_weig];
    %
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% alpha              = lamda/(lamda+myu);
% elastic property alpha will be given directly from inputs
%
[am,cyeind,cnoind] = sim_mergin(cinput,abccof);
nset               = numel(cyeind);
input              = [];
%
if nset > 0
    for ni=1:nset
        inf  = cinput{cyeind(ni)};
        data = load(inf{1});
        if isabc==0 && numel(abc) > 1
            noise= data(:,1).*abc((ni-1)*3+1)+...
                data(:,2).*abc((ni-1)*3+2)+...
                abc((ni-1)*3+3);
        else
            noise = 0;
        end
        data(:,3) = data(:,3)-noise;
        input= [input;data];
    end
end
if numel(cnoind)>0
    for ni=1:numel(cnoind)
        %
        inf  = cinput{cnoind(ni)};
        data = load(inf{1});
        input= [input;data];
        %
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For structure the weight column matrix
%
cindex = [cyeind;cnoind];
ndata  = numel(cindex);
cnum   = zeros(ndata,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wmatrix = [];
if isvcm == 1
    dig_1   = ones(size(input,1),1);
    mvcm    = diag(dig_1);
    novcm   = 0;
    for ni=1:ndata
        %
        % 
        [data,np] = sim_inputdata(cinput{ni}{1});
        cnum(ni)  = np;
        tmp       = (zeros(cnum(ni),1)+1).*weighs(cindex(ni));
        wmatrix   = [wmatrix;tmp];
        start     = novcm+1;
        novcm     = novcm+np;
        %
        if strcmpi(vcms{cindex(ni)},'NULL')==0
            %
            disp([vcms{cindex(ni)}{1} ' is loading...']);
            [t_mp,nboot]    = fileparts(vcms{cindex(ni)}{1});
            [t_mp,t_mp,ext] = fileparts(nboot);
            vcmtype  = ext(2:end);
            vcm      = load(vcms{cindex(ni)}{1});
            if isfield(vcm,'vcm')
                vcm = vcm.vcm;
                vcmtype = 'vcm';
            else
                vcmtype = 'cov';
                vcm = vcm.cov;
            end
            %
            mvcm(start:novcm,start:novcm) = vcm;
        end
    end
    vcm = mvcm;
else
    vcm = 1;
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~ischar(fpara)
    %
    [disfpara,G,lap,lb,ub] = sim_pre4smestGRN(fpara,input,dx,dy,...
        L,W,topdepth,whichnon,alpha);
    %
else
    [disfpara,G,lap,lb,ub,mrakecons] = sim_dist4inv(fpara, input, alpha,rakecons,whichnon);
end

%
if strcmpi(earthmodel,'ELA')
    disp('sim_smest:    -> sim_pre4smest has been calculated GREEN matrix by Okada(85) successfully!');
    %
else
    disp('sim_smest:    -> sim_pre4smest has been calculated GREEN matrix by Wang(06) successfully!');
    %
end
