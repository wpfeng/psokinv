function [los,e,n,u] = sim_fpara4los(fpara,input)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
% Developed by FWP, @ IGPP of SIO, UCSD, 2013-10-04
%
x    = input(:,1);
y    = input(:,2);
disp = 0;
dis  = multiokadaALP(fpara,x,y,disp);
%
e    = dis.E;
n    = dis.N;
u    = dis.V;
%
los  = dis.E.*input(:,4) + ...
       dis.N.*input(:,5) + ...
       dis.V.*input(:,6);
