function mlaps = sim_fpara2lapv4(fpara,isjoint,l,w,pl,pw)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created by FWP, @ BJ, 2013-06-17
%
%
if isjoint == 0
   isjoint = numel(fpara(:,1));
end
distfpara = cell(numel(fpara(:,1)),1);
%
for ni=1:numel(fpara(:,1))
    cfpara    = sim_fpara2dist(fpara(ni,:),l(ni),w(ni),pl(ni),pw(ni));
    distfpara{ni} = cfpara;
end
%
mlaps = cell(isjoint,1);
%
for ni = 1:isjoint-1
    mlaps{ni} = sim_fpara2lap(distfpara{ni});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% working for isjoint
tilr = [];
tind = [];
for nj = isjoint:numel(fpara(:,1))
    cfpara = distfpara{nj};
    ilr    = sim_fpara2sort(cfpara);
    if isempty(tilr)==0
       ilr(:,1) = ilr(:,1) + max(tilr(:,1));
    end
    %
    tilr   = [tilr;ilr];
    %
    if nj ~= numel(fpara(:,1))
        tind   = [tind;max(tilr(:,1));max(tilr(:,1))+1];
    end
       
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imaxi    = max(tilr);
n        = imaxi(1);
m        = imaxi(2);
tnum     = m*n;
jointlap = zeros(tnum);
%
tmpv = [];
for ni = 1:numel(tilr(:,1))
    enlargcof = 0;
    %     if sum(tind==tilr(ni,1))>0
    %         enlargcof = 0.5;
    %     end
    nol = tilr(ni,1);
    nor = tilr(ni,2);
    %
    %
    % up
    if nor~=1
        cnol = nol;
        cnor = nor - 1;
        cni  = (cnol-1)*m+cnor;
        jointlap(cni,(nol-1)*m+nor) = -1+enlargcof*-1;
        tmpv = [tmpv;jointlap(cni,(nol-1)*m+nor)];
    end
    % left
    if nol~=1
        cnol = nol-1;
        cnor = nor;
        cni  = (cnol-1)*m+cnor;
        jointlap(cni,(nol-1)*m+nor) = -1+enlargcof*-1;
        tmpv = [tmpv;jointlap(cni,(nol-1)*m+nor)];
    end
    %
    % right
    if nol ~= n
        cnol = nol+1;
        cnor = nor;
        cni  = (cnol-1)*m+cnor;
        jointlap(cni,(nol-1)*m+nor) = -1+enlargcof*-1;
        tmpv = [tmpv;jointlap(cni,(nol-1)*m+nor)];
    end
    % bottom
    if nor~=m
        cnol = nol;
        cnor = nor+1;
        cni  = (cnol-1)*m+cnor;
        jointlap(cni,(nol-1)*m+nor) = -1+enlargcof*-1;
        tmpv = [tmpv;jointlap(cni,(nol-1)*m+nor)];
    end
    jointlap((nol-1)*m+nor,(nol-1)*m+nor) = sum(abs(tmpv));
    tmpv = [];
end
% for nor=1:n
%     enlargcof = 1;
%     if sum(tind==nor) > 0
%        enlargcof = 0.1;
%     end
%      for noj=1:m
%          nol = (nor-1)*m+noj;
%          if nor ==1
%             jointlap(nor*m+noj,nol)       = jointlap(nor*m+noj,nol)+(-1*enlargcof);
%             jointlap((nor-1)*m+noj,nol)   = jointlap((nor-1)*m+noj,nol)+(1*enlargcof);
%          end
%          if nor ==n
%             jointlap((nor-2)*m+noj,nol)   = jointlap((nor-2)*m+noj,nol)+(-1*enlargcof);
%             jointlap((nor-1)*m+noj,nol)   = jointlap((nor-1)*m+noj,nol)+1*enlargcof;
%          end
%          if nor~=n && nor ~=1
%             jointlap(nor*m+noj,nol)       = jointlap(nor*m+noj,nol)+(-1*enlargcof);
%             jointlap((nor-2)*m+noj,nol)   = jointlap((nor-2)*m+noj,nol)+(-1*enlargcof);
%             jointlap((nor-1)*m+noj,nol)   = jointlap((nor-1)*m+noj,nol)+2*enlargcof;
%          end
%          %%%
%          if noj ==1
%             jointlap((nor-1)*m+noj+1,nol) = jointlap((nor-1)*m+noj+1,nol)+(-1*enlargcof);
%             jointlap((nor-1)*m+noj,nol)   = jointlap((nor-1)*m+noj,nol)+1*enlargcof;
%          end
%          if noj ==m
%             jointlap((nor-1)*m+noj-1,nol) = jointlap((nor-1)*m+noj-1,nol)+(-1*enlargcof);
%             jointlap((nor-1)*m+noj,nol)   = jointlap((nor-1)*m+noj,nol)+1*enlargcof;
%          end
%          if noj~=m && noj ~=1
%             jointlap((nor-1)*m+noj+1,nol) = jointlap((nor-1)*m+noj+1,nol)+(-1*enlargcof);
%             jointlap((nor-1)*m+noj-1,nol) = jointlap((nor-1)*m+noj-1,nol)+(-1*enlargcof);
%             jointlap((nor-1)*m+noj,nol)   = jointlap((nor-1)*m+noj,nol)+2*enlargcof;
%          end
%      end
% end
%save test_lap.mat jointlap tilr
mlaps{isjoint} = jointlap;
