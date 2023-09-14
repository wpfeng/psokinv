function sim_xyz2input(xyz,outinput,vec)
%
%
%
% Created by Wanpeng Feng, @NRCan, 2017-01-23
%
if nargin < 3
   %
   disp('sim_xyz2input(xyz,outinput,vec)');
   return
   %
end
%
data    = load(xyz);
ndim    = numel(data(:,1));
outdata = zeros(ndim,8);
%
outdata(:,1:3) = data;
outdata(:,4)   = vec(1);
outdata(:,5)   = vec(2);
outdata(:,6)   = vec(3);
outdata(:,8)   = 1;
%
% sim_input2outfile(outdata,outinput);
save(outinput,'outdata','-ASCII');
%