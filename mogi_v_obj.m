function stdv = mogi_v_obj(x)
%
%
%
% input by Wanpeng Feng, @Ottawa, 2016-10-05
%
global input
%
x0 = x(1);
y0 = x(2);
z0 = x(3);
radius = x(4);
%
[dx,dy,dz] = mogi_2d_v(input(:,1),input(:,2),x0,y0,z0,radius);
simv       = dx .* input(:,4) + dy .* input(:,5) + dz .* input(:,6);
stdv       = std(input(:,3) - simv);
