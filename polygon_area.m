function p_area = polygon_area(x,y)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% Get the number of vertices
n = length(x);

% Initialize the area
p_area = 0;

% Apply the formula
for i = 1 : n-1
    p_area = p_area + (x(i) + x(i+1)) * (y(i) - y(i+1));
end
p_area = abs(p_area)/2;

