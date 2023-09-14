function [findex,tfpara] = sim_fpara2index(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% indexing for fpara
% developed by FENG WP, @ IGPP of SIO, UCSD, 2013-10-02
% findex = [n x 7]
%          [index,i,j,up,bottom,left,right]
% A bug was fixed @ NRCan when dip is ~1 or less. Then depth is not
% sensitive...
%
%
format long
%
udepth     = sort(unique(fpara(:,5)));
findex     = zeros(numel(fpara(:,1)),7);
counter    = 0;
tfpara     = [];
%
for ni = 1:numel(udepth)
    %
    cfpara = fpara(fpara(:,5) == udepth(ni),:);
    %
    x0     = cfpara(:,1);
    y0     = cfpara(:,2);
    %
    % One bug was found in Qinghai Case.
    % by fWP, @GU, 2014-05-27
    %
    [cx,cy]     = sim_rotaxs(x0,y0,mean(cfpara(:,3)),90,mean(x0),mean(y0));
    %
    if mod(mean(cfpara(:,3)),90)>40
       cx     = cx-min(cx);
       [t_mp,subindex] = sort(cx);
    else
       cy     = cy-min(cy);
       [t_mp,subindex] = sort(cy);
    end
    %
    cfpara = cfpara(subindex,:);
    %
    %
    for nj = 1:numel(subindex)
        %
        counter           = counter + 1;
        bd                = zeros(1,4);
        %
        if cfpara(nj,5) == min(udepth)
            bd(1) = 1;
        end
        if cfpara(nj,5) == max(udepth) %fix(cfpara(nj,5).*scale)/scale == udepth(end)
            bd(2) = 1;
        end
        if nj == 1
            bd(3) = 1;
        end
        if nj == numel(subindex)
            bd(4) = 1;
        end
        findex(counter,:) = [counter,ni,nj,bd];
        tfpara            = [tfpara;cfpara(nj,:)];
        %
    end
end

