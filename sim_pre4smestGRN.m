function [disfpara,G,lap,lb,ub] = sim_pre4smestGRN(fpara,input,dx,dy,...
                                                   L,W,topdepth,whichnon,alp)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
                                     
% 
% Purpose:
%      Inversion distributed slip model using LS Algorithm with boudary
%      constraints.
% Input:
%      fpara, the uniform fault model
%      input, the input data
%      dx,dy,L,W, the sub-patch fault size and whole fault scale size
%      lamd,  the control factor for smooth constraints
%      lb,ub, the boudary constraints bottom and up boudary.
%      wpara, the value of weight parameters,1 for
% Output:
%   fpara, the distributed slip model
%   osim, the simulation result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate the G
%
thd                    = 0;
[G,disfpara,lap,lb,ub] = sim_fpara4G(fpara,dx,dy,L,W,topdepth,input,thd,alp,whichnon);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

