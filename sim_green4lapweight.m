function w = sim_green4lapweight(green,obs,amfactor)
%,weights)
%
%
%
% 
% Created by Feng, WP, @ Gu, 2013-04-17
%
if nargin < 3
    amfactor = 3;
end
% 
% obsoleted by Feng, W.P., @ EOS of NTU, Singapore, 2015-06-24
% if nargin < 4
%     weights = 1;
% end
%
dims = size(green);
w    = zeros(dims(2));
%
for ni = 1:dims(2)
    %
    cgreen = green(:,ni);
    x      = sim_bvls(cgreen,obs,0,200);
    res    = std((obs-cgreen*x));%.*weights);
    %
    w(ni,:)= res;
    %
end
w = (exp(w))./mean(exp(w(:)));%.*amfactor;
%
minv = min(w(:));
maxv = max(w(:));
%
if amfactor <= 0.95
   %
   amfactor = 1;
end
%
rng = [0.95,amfactor];
w   = (w-minv)./(maxv-minv).*(rng(2)-rng(1))+rng(1);
%