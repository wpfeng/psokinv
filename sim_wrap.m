function output = sim_wrap(data,vmin,vmax)
%
%************** FWP Work ************************
%Developed by FWP, @UoG/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% to re-wrap data by vmin and vmax
% For example,
%   outdata = sim_wrap(indata,-3.14159265,3.14159265);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modification history,
% Created by Feng,W.P., @ BJ, 2009/01/01
% Add some help information by W.P. Feng, @ UoG, 2011/11/25
%
PI = 3.14159265;
%
if nargin < 3
   vmax =  PI;
end
if nargin < 2
   vmin = -PI;
end
indnan          = isnan(data);
data(indnan==1) = 0;
min_index       = find(data <= vmin) ;   
output          = data;
%
while isempty(min_index) ~= 1 
    %
    output(min_index)  = output(min_index) + (vmax-vmin);   
    min_index          = find(output <= vmin) ;            
end   
max_index = find(data > vmax) ;        
%
while isempty(max_index)~= 1   
    %
    output(max_index)  = output(max_index) - (vmax-vmin);   
    max_index          = find(output > vmax) ;            
end
%
output(indnan==1) = NaN;
output            = output.*(data~=0);
%
