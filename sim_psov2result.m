function [objv,osim,input,fcounter,fnames,fpoints] = sim_psov2result(fpara,abc,invf)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %
 %
 [psoPS,cinput,symbols,outoksar,abccof,outmatf,tfpara,...
                             lamda,myu]= sim_readconfig(invf);
                                          
          %scamin,scamax,Inv,locals,weighs,vcms] = ...
%
alpha = lamda/(lamda+myu);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[am,cyeind,cnoind] = sim_mergin(cinput,abccof);
nset        = numel(cyeind);
input       = [];
fcounter    = 0;
fpoints     = cell(1);
fnames      = cell(1);
if nset > 0
  for ni=1:nset
      inf  = cinput{cyeind(ni)};
      data = load(inf{1});
      input= [input;data];
      fcounter = fcounter+1;
      fpoints{fcounter} = numel(data(:,1));
      fnames{fcounter}  = inf{1};
      
  end
end
if numel(cnoind)>0
   for ni=1:numel(cnoind)
      inf  = cinput{cnoind(ni)};
      %disp(inf);
      data = load(inf{1});
      input= [input;data];
      fcounter = fcounter+1;
      fpoints{fcounter} = numel(data(:,1));
      fnames{fcounter}  = inf{1};
   end
end
%
green  = sim_oksargreenALP(fpara,input,0,alpha);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[n,m]   = size(green);
[dn,dm] = size(am);
A       = zeros(n,m+dm);
A(1:n,1:m)       = green;
A(1:dn,m+1:m+dm) = am;
D       = input(:,3);
slip    = [fpara(:,8);fpara(:,9);abc];
osim    = A*slip;
objv    = sqrt(sum((osim-D).^2)/numel(osim));
