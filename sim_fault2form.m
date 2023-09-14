function cofs = sim_fault2form(infault,type)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% +Purpose:
%     calculate the plane formular due to input fault parameter
% +Input:
%     infault, the fault data
%     type,  fpara or TRIF
% +Output:
%   a,b,c, ax + by + cz = 1;
%
% Created by Feng, Wanpeng, email: wanpeng.feng@hotmail.com
% 2011-03-16, in Beijing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% format long
% pi = 3.141592653589793238;
%
if nargin < 2
   type = 'fpara';
end
cofs = [];
switch lower(type)
    case 'fpara'
        points = sim_fpara2allcors(infault);
        points(:,3) = points(:,3).*(-1);
    case 'trif'
        cx = infault.x;
        cy = infault.y;
        cz = infault.z;
        points = [cx(:),cy(:),cz(:)];
    otherwise
        display(['The format of fault,' ' ' lower(format) ', can not be recognized. Please check it...']);
        return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a*x + b*y + c*z = 1;
D    = points(:,1).*0 + 1;
cofs = points\D;


   
