%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% From Trace to create a continuous curve fault plane...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tra = load('data/faultTrace.inp');
%
mv  = mean(tra);
%
[~,~,zone]     = deg2utm(mv(2),mv(1));
%
[x,y]          = deg2utm(tra(:,2),tra(:,1),'53 S');
x              = x./1000;
y              = y./1000;
rep            = mean([x,y]);
rep(1)         = rep(1) - 100;
dip            = zeros(size(x))+14;
wid            = 240;
pw             = 15;
pl             = 15;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fpara,tf,mps] = sim_trace2fpara([x,y],rep,dip,wid,pw,pl);
input_1        = sim_inputdata('inp/E.inp');
input_2        = sim_inputdata('inp/N.inp');
input_3        = sim_inputdata('inp/U.inp');
input          = [input_1;input_2;input_3];
%input          = input_3;
cfpara{1}      = fpara;
rakecons       = [1,45,135];
whichbnds{1}   = {'R','L','B'};
mC{1}          = diag(ones(numel(input(:,1)),1));
mPS{1}         = mps;
mfpara         = sim_fpara2distmodel(cfpara,input,rakecons,mC,mPS,0.001,0,'cgls',whichbnds,'Japan_save_dip14.mat');
