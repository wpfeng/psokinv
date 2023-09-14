function [p1,p2] = sim_fpara2cc4tri(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng W.P, the code will return the center of the fault plane.
%
p1      = [];
p2      = [];
dipstr  = fix(fpara(:,3).*100)+fix(fpara(:,4).*100);
udipstr = unique(dipstr);
indexes = [(1:1:size(fpara,1))' dipstr];
tfpara  = fpara;
for nj  = 1:numel(udipstr)
    cindex = indexes(:,2) == udipstr(nj);
    fpara  = tfpara(cindex==1,:);
    ilr    = sim_fpara2sort(fpara);
    
    for ni = 1:size(fpara,1)
       
        vmod    = mod((ilr(ni,1)-1)*max(ilr(:,2))+ilr(ni,2),2);
        maxidex = max(ilr(:,1));
        if vmod == 0 && ilr(ni,1) ~= maxidex && ilr(ni,1) ~= 1
           fpara(ni,7) = fpara(ni,7) + fpara(ni,7)/2;
        end
        %disp(fpara(ni,7))
        [x1,y1,z1] = sim_fpara2corners(fpara(ni,:),'ul');
        [x2,y2,z2] = sim_fpara2corners(fpara(ni,:),'ur');
        %[x3,y3,z3] = sim_fpara2corners(fpara(ni,:),'lc');
        %
        p1     = [p1;x1,y1,z1];
        p2     = [p2;x2,y2,z2];
        
    end
end
%plot(p1(:,1),p1(:,3),'or');
