%
% sim_passingparameters.m
% New version for passing parameters for a m-function
%
%************** FWP Work ************************
%Developed by FWP, @UoG/CEA, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%% ge_parse_pairs
%   helper function allowing named generic name value parameter passing
if rem(numel(varargin),2)~=0
    disp(' Please check Input parameters. Current input is not in a good shape!!!');
    return
end
%
for ni = 1:2:numel(varargin)
    mypara = varargin{ni};
    myval  = varargin{ni+1};
    eval([mypara,'=myval;']);
end
