function [input,cinput] = sim_getinps(inpfiles)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 nf = numel(inpfiles);
 input = [];
 cinput= cell(nf,1);
 for ni=1:nf
     %
     inf  = inpfiles{ni};
     data = load(inf{1});
     input= [input;data];
     cinput{ni} = data;
 end
