function [osim,objv,input,inpfile] = sim_psov2dataset(fpara,dataset,alpha)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
  %
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  inpfile  = dataset.fname;
  input    = load(inpfile);
  if nargin<3 || isempty(alpha)==1
     alpha = 0.5;
  end
  green   = sim_oksargreenALP(fpara,input,0,alpha);
  am      = input(:,1:3);
  am(:,3) = 1;
  abc     = [dataset.a;dataset.b;dataset.c];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [n,m]   = size(green);
  [dn,dm] = size(am);
  A       = zeros(n,m+dm);
  A(1:n,1:m)       = green;
  A(1:dn,m+1:m+dm) = am;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  osim = A*[fpara(:,8);fpara(:,9);abc];
  objv = aqrt(sum((osim-input(:,3)).^2)/numel(input(:,3)));
