function [slap,dlap,lap] = sim_fpara2lap_updated(fpara,xyzindex,msegments)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng, Wanpeng, skyflow2008@126.com, 2010-05
% + Input:
%    fpara,     discretized fault models n x 10
%    xyzindex,  flag for smoothing control, n x 3
%    msegments, a flag recording the index of each small slip patch...
% + Log:
%  Updated by fWP, @ IGPP of SIO, UCSD, 2013-10-16
%  Updated by FWP, @ Glasgow University, 2014-02-24
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numf = size(fpara,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slap  = zeros(numf);
mflag = slap(1,:);
%
for ni=1:numf
    %
    [cx,cy]     = sim_rotaxs(fpara(:,1),fpara(:,2),fpara(ni,3)-90,0,fpara(ni,1),fpara(ni,2));
    adist       = sqrt((cx(:)-cx(ni)).^2+(cy(:)-cy(ni)).^2+(fpara(:,5)-fpara(ni,5)).^2);
    %
    nseg         = msegments(ni);
    cflag        = xyzindex{nseg};
    mflag        = mflag.*0;
    %
    if cflag(1)==0
        mflag(msegments==nseg) = 1;
    else
        for nk=2:numel(cflag)
            mflag(msegments==cflag(nk)) = 1;
        end
        %
    end
    adist(mflag(:)==0) = max(adist(:)).*2;
    [t_mp,nindex]      = sort(adist);
    %
    if numel(nindex) >= 16
        outindex = nindex(1:16);
    else
        outindex = nindex;
    end
    outindex(outindex==ni)   = [];
    slap(ni,outindex(2:end)) = -1./(adist(outindex(2:end)));
    slap(ni,ni)              = sum(1./(adist(outindex(2:end))));
end
%
dlap =  slap;
lap  = [slap    slap.*0; ...
        slap.*0 dlap];

%