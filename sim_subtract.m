function cdata = sim_subtract(rawfile,x,y)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
  %
  %
  %
  [indata,cx,cy,info] = sim_readroi(rawfile);
  if isempty(findstr(lower(info.x_unit),'k'))==1
     cx = cx./1000;
  end
  if isempty(findstr(lower(info.y_unit),'k'))==1
     cy = cy./1000;
  end
  ind1 = (cx-x(1))==min((cx(:)-x(1)));
  ind2 = (cy-y(2))==min((cy(:)-y(2)));
  ind  = ind1.*ind2;
  [r1,c1] = find(ind==1);
  ind1 = (cx-x(2))==min((cx(:)-x(2)));
  ind2 = (cy-y(1))==min((cy(:)-y(1)));
  ind  = ind1.*ind2;
  [r2,c2] = find(ind==1);
  minr    = (r1>=r2)*r2+(r1<r2)*r1;
  maxr    = (r1>=r2)*r1+(r1<r2)*r2;
  minc    = (c1>=c2)*c2+(c1<c2)*c1;
  maxc    = (c1>=c2)*c1+(c1<c2)*c2;
  cdata   = indata(minr:maxr,minc:maxc);
  %find(ind==1)
