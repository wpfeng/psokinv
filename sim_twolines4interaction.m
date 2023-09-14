function outp = sim_twolines4interaction(l1,l2)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Developed by FWP, @BJ, 2010-01-01
%
%
x1   = l1(1,1);
y1   = l1(1,2);
x2   = l1(2,1);
y2   = l1(2,2);
%%%%%%%%%%%%%%%%%%%%%%
kcof1 = (y1-y2)/(x1-x2);
if isinf(kcof1)==0
    c1 = y1-kcof1*x1;
else
    c1 = Inf;
end
%%%%%%%%%%%%%%%%%%%%%%
x1   = l2(1,1);
y1   = l2(1,2);
x2   = l2(2,1);
y2   = l2(2,2);
%%%%%%%%%%%%%%%%%%%%%%
kcof2 = (y1-y2)/(x1-x2);
if isinf(kcof2)==0
    c2 = y1-kcof2*x1;
else
    c2 = Inf;
end
%%%%%%%%%%%%%%%%%%%%%
A = [-1*kcof1 1;...
     -1*kcof2 1];
D    = [c1;c2];
outp = A\D;
