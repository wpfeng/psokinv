function roughness = sim_fpara2roughness(fpara)
%
%
%
%
% Developed by Feng, W.P.,@ EOS of NTU, Singapore, 2015-06-15
%
nf        = numel(fpara(:,1));
[~,L]     = sim_fpara2lap(fpara);
slip      = [fpara(:,8);fpara(:,9)];
roughness = norm(L*slip);
%
roughness = sqrt(roughness./(nf*2));