function outdata = sim_elastic2dis(oksar,data,varargin)
%
% Predict surface displacements associated with a fault slip model in a
% half-space earth model
%
% oksar, a slip model in SIMP or OKSAR format
% data,  a N x 7 data matrix which including los change (3rd), e/n/u
% projection vectors, (4th, 5th and 6th)
% Developed by Feng, Wanpeng @ Ottawa, 2015-10-12
%
alpha = 0.5;
%
for ni = 1:2:numel(varargin)
    %
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[t_tmp,t_mp,bext] = fileparts(oksar);
%
switch upper(bext)
    %
    case '.OKSAR'
        fpara = sim_oksar2SIM(oksar);
    case '.SIMP'
        fpara = sim_simp2fpara(oksar);
end
%
dis = multiokadaALP(fpara,data(:,1),data(:,2),0,alpha);
sim = dis.E.*data(:,4) + dis.N.*data(:,5) + dis.V.*data(:,6);
outdata = [data(:,1:2),sim,dis.E,dis.N,dis.V];