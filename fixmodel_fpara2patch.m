function outpolym = fixmodel_fpara2patch(rfpara,maxdepth)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
% Created by Feng, W.P., 2011/0/01, @ BJ
% Updated by FWP, @ BJ, 2013-10-10
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 2
    maxdepth = 20;
end
%
ps   = [];
dips = [];
strs = [];
rfpara = sim_fpara2cross(rfpara,[],maxdepth);
%
rfpara(:,8) = 10;
%
% whos rfpara
outpolym = cell(1);
for nj = 1 : size(rfpara,1)-1
    %
    [x1,y1,z1] = sim_fpara2corners(rfpara(nj,:),'ul');
    [x2,y2,z2] = sim_fpara2corners(rfpara(nj,:),'ur');
    %
    dip1 = rfpara(nj,4);
    len1 = rfpara(nj,7);
    dip2 = rfpara(nj+1,4);
    str1 = rfpara(nj,3);
    str2 = rfpara(nj+1,3);
    len2 = rfpara(nj,7);
    cdip = (dip1+dip2)/2;%dip1 + (dip2-dip1)*(len1/2)./((len1+len2)/2);
    cstr = str1 + (str2-str1)*(len1/2)./((len1+len2)/2);
    tfpara = [x2,y2,cstr,cdip,0,rfpara(nj,6)*sind(rfpara(nj,4))/sind(cdip),1,0,0];
    [x3,y3,z3] = sim_fpara2corners(tfpara,'dc');
    [x4,y4,z4] = sim_fpara2corners(rfpara(nj,:),'ll');
    %
    if nj==1
        poly3dgon = [x1,y1,z1;x2,y2,z2;x3,y3,z3;x4,y4,z4;x1,y1,z1];
    else
        poly3dgon = [poly3dgon(2,:);x2,y2,z2;x3,y3,z3;poly3dgon(3,:);poly3dgon(2,:)];
    end
    outpolym{nj} = poly3dgon;
end
%
%
[x2,y2,z2] = sim_fpara2corners(rfpara(end,:),'ur');
[x3,y3,z3] = sim_fpara2corners(rfpara(end,:),'lr');
%
poly3dgon = [poly3dgon(2,:);x2,y2,z2;x3,y3,z3;poly3dgon(3,:);poly3dgon(2,:)];
outpolym{nj+1} = poly3dgon;
