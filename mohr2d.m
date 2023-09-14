function [V,D] = mohr2d(S,angle)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Function to decompose a symmetric tensor, S
% The Function requires the function, tensor_decomp(S)
% INPUT:
%       the tensor, S in the form:
%       | Snn Sne Snd |
%       | Sen See Sed |
%       | Sde Sdn Sdd |
%       where, n = north, e =east, d = down
%  into principle values and principle axes
%  Output:
%        Matrices V ( columns are eigenvector)
%                 D ( diagonal with principal values)
%  Example:
%     >> S     = [100,-50,0; -50,-150,-35;0,-35;30];
%     >> [V,D] = eigs(S);
% Call eigs to decompose the stress tensor
% 
% [V, D] = eigs(S);
[V, D] = eigs(S);
V      = V.* -1;
D      = D.* -1;
%
%
% Draw the Mohr Circle
%
mean_normal = 0.5 * (D(1,1) + D(3,3));
max_shear   = 0.5 * (D(1,1) - D(3,3));
%
theta       = (0:0.01:180) * pi /180;
ns          = mean_normal + max_shear * cos(2 * theta);
ss          = max_shear * sin(2 * theta);
%
hm          = gca;
% plot the circle
h1 = plot(ns,ss,'k-','Color',[0.25,0.25,0.25],'LineWidth',1.5);
%
% Plot the center of the circle and the origin
%
hold on
plot(mean_normal, 0,'k.','MarkerSize',18,'Color',[.25,.25,.25]);
plot(0,0,'k.','MarkerSize',24,'Color',[.25,.25,.25]);
grid on
%
% plot the line (if an angle is given);
% go from the origin to one other point
%    that with a normal stress equal to the maxium
%
if nargin > 1
   hold on
   xl(1) = mean_normal;
   yl(1) = 0;
   mylength = 1.1 * max_shear;
   xl(2)    = xl(1) + mylength * cos(2 * angle * pi/180);
   yl(2)    = yl(1) + mylength * sin(2 * angle * pi/180);
   plot(xl, yl,'k-','LineWidth',1.25);
   plot(xl,-yl,'k-','LineWidth',1.25);
   mytitle = sprintf('Angle = %.1f Degree', angle);
   title(mytitle);
   %
end
% Plot a coulomb Envelope (mu = 0.85);
%
hold on
mu = 0.85;
xl(1) = 0;
yl(1) = 0;
mylength = 1.5 * max_shear;
xl(2) = xl(1) + mylength;
yl(2) = yl(1) + mylength * mu;
%
plot(xl, yl, 'k-','LineWidth',1.25);
plot(xl,-yl, 'k-','LineWidth',1.25);

%
% add some labels
%
set(hm,'FontName','Helvetica','FontSize',12);
xlabel('Normal Stress');
ylabel('Shear Stress');
axis square; axis equal
hold off;
%

