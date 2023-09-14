function rms = sim_inputrms(fpara,input)
%
%
%
% Developed by Feng, W.P., @ EOS of NTU, Singapore, 2015-06-15
%
dis  = multiokadaALP(fpara,input(:,1),input(:,2));
osim = dis.E.*input(:,4) + dis.N.*input(:,5) + dis.V.*input(:,6);
%stdv = std(input(:,3)-osim); 
rms  = sim_rms(input(:,3),osim);