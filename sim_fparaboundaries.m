function [fpara,lap] = sim_fparaboundaries(fpara,refdep,mode,innour)
%
%
%
if nargin < 3
    mode = 'xz';
end
if nargin < 4
   nour = 0;
else
   nour = innour;
end
%
fpara(:,8) = 100;
fpara(:,9) = 100;
%
fpara(fpara(:,5)>refdep,8) = 0;
fpara(fpara(:,5)>refdep,9) = 0;
%
% right boundary
if nour == 0
    [x,y,z] = sim_fpara2corners(fpara,'ur');
    vmax    = max(x);
    fpara(x>vmax-0.5,8) = 0;
    fpara(x>vmax-0.5,9) = 0;
end
%
% left boundary
%
[x,y,z] = sim_fpara2corners(fpara,'ul');
vmin = min(x);
fpara(x<vmin+0.5,8) = 0;
fpara(x<vmin+0.5,9) = 0;
%
lap = sim_fpara2lap_bydist(fpara,mode);