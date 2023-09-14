%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Simulation for Points
%finf = 'brazilV2.inp';
fmat = 'result\Brazil_matfileV5_dip-50.1.mat';
dmat = load(fmat);
inpf = dmat.cinput;
nf   = size(inpf,1);
data = [];
for ni = 1:nf
    tdata = sim_inputdata(inpf{ni}{1});
    data  = [data;tdata];
end
%
fpara = dmat.outfpara{1};
DIST  = multiokadaALP(fpara,data(:,1),data(:,2),0,0.5,0);
OSIM  = DIST.E.*data(:,4)+DIST.N.*data(:,5)+DIST.V.*data(:,6);
plot(data(:,3),'r');
hold on
plot(OSIM,'b');
