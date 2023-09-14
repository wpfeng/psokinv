function [area] = triangle_area(P,method)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% This function gives the area of a triangle
%
% [area] = triangle_area(Points, Method)
%
% Points: The Points should be a numeric array, of size 3xn, 
%         thus the points can be 2D, 3D... nD
% Method: Can be 'h' area calculation with Heron's formula 
%         or can be 'q' Orthogonal-triangular decomposition (default)
%
% Example: 
% P1=[0 0]; P2=[1 0.5]; P3=[0.5 1];
% area = triangle_area([P1;P2;P3])
%
% Version 1.1 updated on 2007-09-21 
% Added 'Orthogonal-triangular decomposition' after a usefull review of John D'Errico 

% Default output format
if(exist('method','var')==0), method='q'; end

% Check input
if((method ~= 'h') && (method ~= 'q')), error('Unknown area calculation method'); end
[k,m] = size(P); if(k~=3), error('Points are not a 3xn array'); end

if(method=='h')
    % Length of edges
    L    = [sqrt(sum((P(1,:)-P(2,:)).^2)) ...
            sqrt(sum((P(2,:)-P(3,:)).^2)) ...
            sqrt(sum((P(3,:)-P(1,:)).^2))];
    % Area calculation with Heron's formula
    s    = ((L(1)+L(2)+L(3))/2); 
    area = sqrt(s*(s-L(1))*(s-L(2))*(s-L(3)));
else
    % Area calculation with Orthogonal-triangular decomposition
    [q,r] = qr((P(2:3,:) - repmat(P(1,:),2,1))');
    area  = abs(prod(diag(r)))/2;
end
    

