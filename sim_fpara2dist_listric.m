function mfpara = sim_fpara2dist_listric(fpara,fwidth,fdip,flength,fdl,fdw,par,lmodel)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Listric fault modeling
% Author: Wanpeng Feng
%         Developed @ GU, 2013-02-15
%
%
% Updated by FWP, @ GU, 2014-3-13
%   add a new model for a increasing dip angle model which is designed for
%   subduction zone earthquakes.
%   'LIDD', lnearly Increasing Dip with Depths model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 7
    par = 2;
end
if nargin < 8
    lmodel = 'linear';
end
fa = par;

%

mfpara = [];
%
for ni = 1:numel(fpara(:,1))
    %
    nfpara = sim_fpara2rand_UP(fpara(ni,:));
    nfpara(4) = fdip(ni);
    %
    %
    rdepth = 0;
    %
    ifpara = nfpara;
    acwid  = 0;
    while acwid <= fwidth
        %
        ifpara(6)  = fdw(ni);
        cfpara     = sim_fpara2dist(ifpara,flength(ni),fdw(ni),fdl(ni),fdw(ni),'w',rdepth);
        [ix,iy,iz] = sim_fpara2corners(ifpara,'dc');
        %
        % Check the new depth for new model
        % Queried by FWP, @ GU, 2013-02-15
        % disp([ifpara(5),iz]);
        
        %
        switch upper(lmodel)
            case 'LINEAR'
                idip = -1 * fa(1) * iz + nfpara(4);
            case 'EXP'
                idip = -1 * fa(1) * exp(iz) + nfpara(4);
            case 'POWER'
                if numel(fa) < 2
                    fa = [fa(1),fa(1)];
                end
                idip = -1 * fa(1) * iz^ fa(2) + nfpara(4);
            case 'LIDD'
                idip = fa(1)*iz + nfpara(4);
        end
        
        %
        %disp([idip,fa,nfpara(4)]);
        %
        % rdepth     = iz;
        if idip >= 0
            ifpara(4)  = idip;
        else
            ifpara(4) = 0;
        end
        ifpara(1:2)= [ix,iy];
        ifpara(5)  = iz;
        rdepth     = iz;
        mfpara     = [mfpara;cfpara];
        acwid      = acwid + fdw;
    end
end
