function powDEN = sim_swarmDEN(swarm)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 %npart = size(swarm,1);
 ndim   = size(swarm,3);
 powDEN = zeros(ndim,1);
 for nd = 1:ndim
     powDEN(nd) =cov(swarm(:,1,nd));
 end
