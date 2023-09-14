function weights = sim_readweights(newweights)
%
%
%
%
weights = 1;
%
if nargin < 1 
    newweights = [];
end
%
if exist('weight.info','file')
   fid = fopen('weight.info','r');
   tline = textscan(fid,'%s %f\n');
   %
   if isempty(newweights)
       newweights = tline{2};
   end
   %
   weights = [];
   for ni = 1:numel(tline{2})
       %
       file    = tline{1}{ni};
       input   = load(file);
       weights = [weights;input(:,1).*0+newweights(ni)];
       %
   end
   fclose(fid);
end
