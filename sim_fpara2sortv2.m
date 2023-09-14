function [ilr,mfpara] = sim_fpara2sortv2(testfpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% A new version by FWP, @ GU, 2013-03-26
%
%
[cx,cy] = sim_rotaxs(testfpara(:,1),testfpara(:,2),mean(testfpara(:,3)),mean(testfpara(:,4)),testfpara(1,1),testfpara(1,2));
%
ucx     = sort(unique(fix(cx.*100)./100));
ucy     = sort(unique(fix(cy.*100)./100),'descend');
%
for ni = 1:numel(testfpara(:,1))
    mdis = (ucx-cx(ni)).^2;
    ind = find(mdis == min(mdis));
    testfpara(ni,8) = ind(1);
    %
    mdis = (ucy-cy(ni)).^2;
    ind = find(mdis == min(mdis));
    testfpara(ni,9) = ind(1);
    %
end
%sim_fig3d(testfpara);
ilr    = [testfpara(:,8),testfpara(:,9)];
mx     = ilr(:,1);
my     = ilr(:,2);
mmx    = sort(unique(mx));
mmy    = sort(unique(my));
for ni = 1:numel(mx)
    index1 = find(mmx == mx(ni));
    index2 = find(mmy == my(ni));
    ilr(ni,:) = [index1,index2];
end
mfpara = testfpara;
