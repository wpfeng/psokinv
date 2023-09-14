function [fpara,outps] = sim_fixfpara(infpara,subx,suby,dampingfactor)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Developed by FWP, @ IGPP of SIO, UCSD, 2013-10-10
%
%
if nargin < 5
    % Fixed for the 2016 Kumamoto earthquake 
    % by FWP, @Ottawa, 2017-04-12
    drange = 0;
end
if numel(infpara(:,1))==1
    outps = [];
    [tmp_a,tmp_b,refdepth] = sim_fpara2corners(infpara,'dc');
    rdepth   = 0;
    %
    subflength = infpara(7);
    xsize      = subx;
    ysize      = suby;
    tmpfpara   = [];
    %
    while rdepth < refdepth
        %
        npatch     = fix(subflength/xsize);
        if npatch == 0
            npatch = 1;
        end
        %
        xsize      = subflength/npatch;
        tempfpara  = sim_fpara2dist(infpara,infpara(:,7),ysize,xsize,ysize,'d',rdepth);
        if numel(tempfpara(:,1))==0
            disp([ysize,xsize]);
        end
        %
        [tmp_a,tmp_b,iz]   = sim_fpara2corners(tempfpara(1,:),'dc');
        rdepth     = iz;
        subflength = sum(tempfpara(:,7));
        tmpfpara   = [tmpfpara;tempfpara];
        xsize      = xsize*dampingfactor;
        ysize      = ysize*dampingfactor;
        %
    end
    fpara = tmpfpara;
else
    %
    [tmp_a,tmp_b,refdepth] = sim_fpara2corners(infpara,'dc');
    %
    %
    % Updated by Wanpeng Feng, @Ottawa, 2017-04-13
    infpara(:,6) = max(refdepth) / sind(infpara(:,4));
    %
    [fpara,outps] = sim_fpara2seamlesspoly(infpara,max(refdepth),subx(1),dampingfactor,0);
    %
end
