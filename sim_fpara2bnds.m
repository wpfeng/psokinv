function mBND = sim_fpara2bnds(mfpara,mPS)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% +Purpose:
%
%   determine which patch is the boudary
%
%   Created by Feng, W.P., 2011/11/15, @ GU
%

mBND = cell(1);
for ni = 1:numel(mfpara)
    bnd = mfpara{ni};
    bnd(:,8:9) = 0;
    mps   = mPS{ni};
    %
    for njj=1:size(bnd,1)
        cps = mps{njj};
        figs1 = 0;
        figs2 = 0;
        figs3 = 0;
        figs4 = 0;
        % up-left point
        for nk = 1:numel(bnd(:,1))
            tps  = mps{nk};
            re1  = zeros(4,1);
            re2  = zeros(4,1);
            re3  = zeros(4,1);
            re4  = zeros(4,1);
            for nm = 1:4
                re1(nm)  =  sqrt(sum((tps(nm,:) - cps(1,:)).^2));
                re2(nm)  =  sqrt(sum((tps(nm,:) - cps(2,:)).^2));
                re3(nm)  =  sqrt(sum((tps(nm,:) - cps(3,:)).^2));
                re4(nm)  =  sqrt(sum((tps(nm,:) - cps(4,:)).^2));
            end
            if min(re1)< 0.01
                figs1 = figs1 + 1;
            end
            if min(re2) < 0.01
                figs2 = figs2 + 1;
            end
            if min(re3) < 0.01
                figs3 = figs3 + 1;
            end
            if min(re4) < 0.01
                figs4 = figs4 + 1;
            end
        end
        %[re1,re2,re3,re4]
        %[figs1,figs2,figs3,figs4]
        if figs1+figs2 <= 4
            bnd(njj,8) = 1;
        end
        if figs1+figs4 <=4
            bnd(njj,8) = 2;
        end
        if figs2+figs3 <=4
            bnd(njj,8) = -2;
        end
        if figs3+figs4 <=4
            %[figs1,figs2,figs3,figs4]
            bnd(njj,8) = -1;
        end
    end
    mBND{ni} = bnd;
end
