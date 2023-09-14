function [fpara,tfpara,mps] = sim_trace2fpara(tra,refp,dip,wid,pw,pl)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% + Purpose:
%     create fault model from surface traces
% + Usage:
%    fpara = sim_trace2fpara(tra,refp,dip,wid,pw,pl);
% + Input:
%     tra, the n*2, trace data
%    refp, the referece points, which is useful when we fix one size of the
%          fault.
%     wid, width in km
%      pw, patch size along dip in km
%      pl, patch size along strike in km
% + Output:
%    fault model with fpara format
% Developed  by Feng, Wanpeng, in Beijing, 2011-03-30
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
x          = tra(:,1);
y          = tra(:,2);
if nargin < 2 || isempty(refp)
   refp = [];
end
if nargin < 3 
   dip = zeros(x) + 80;
end
if nargin < 4
    wid = 50;
end
if nargin < 5
    pw = 4;
end
if nargin < 6
    pl = 4;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(dip) < numel(x)
    dip = zeros(size(x))+dip(1);
end
% it's not right to fix the depth of model... 20110410
% by Feng, Wanpeng, BJ
%
%wid = depth/sind(dip);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outp = [];
mpl  = zeros(numel(x),1);
mpw  = zeros(numel(x),1);
for ni = 1:numel(x)
    if ni == 1
       % if it's the first given point...
       [str,dist] = sim_2points2str([x(ni),y(ni)],[x(ni+1),y(ni+1)],refp);
    else if ni~=1 && ni~=numel(x) && numel(x) >= 3
            % if it's the middle one, that is to say that it's not the
            % first one or last one...
            %
            [str1,dist1] = sim_2points2str([x(ni-1),y(ni-1)],[x(ni),y(ni)],refp);  
            [str2,dist2] = sim_2points2str([x(ni),y(ni)],[x(ni+1),y(ni+1)],refp);  
            % modified by Feng, W.P, @ BJ, 2011-06-13
            % Now strike will be changed due to the distance with 
            str          = (str2-str1)*(dist1/(dist1+dist2)) + str1;
            dist         = dist2;
        else
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           [str,dist] = sim_2points2str([x(ni-1),y(ni-1)],[x(ni),y(ni)],refp);  
        end
    end
    %
    fpara      = [x(ni),y(ni),str,dip(ni),0,wid,dist,0,0];
    [x0,y0,z0] = sim_fpara2corners(fpara,'lc'); 
    outp       = [x(ni),y(ni),0,x0,y0,z0;outp];
    if pl>dist
       cpl = dist;
    else
       cpl = pl;
    end
    if pw>dist
        cpw = dist;
    else
        cpw = pw;
    end
    mpl(ni) = cpl;
    mpw(ni) = cpw;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fpara   = zeros(1,10);
tfpara  = zeros(1,10);
counter = 0;
mps     = cell(1);
for ni = 1:size(outp,1)-1
    %
    ps = [outp(ni,1:3);outp(ni+1,1:3);outp(ni+1,4:6);outp(ni,4:6)];
    nl = fix(ceil((sqrt(sum((ps(1,:)-ps(2,:)).^2))/mpl(ni)).*100)/100);
    nw = fix(ceil((sqrt(sum((ps(2,:)-ps(3,:)).^2))/mpw(ni)).*100)/100);
    nl = (nl < 2) *2 + (nl >=2)*nl;
    nw = (nw < 2) *2 + (nw >=2)*nw;
    if nl > 100
        disp(ps);
    end
    for now = 1:nw-1
        for nol = 1:nl-1
            counter = counter + 1;
            [a,b,pst] = sim_xyz2fpara(ps,nw,nl,now,nol);
            fpara(counter,:)  = a;
            tfpara(counter,:) = b;
            mps{counter}      = pst;
        end
    end
end
