function fpara = sim_oksar2oversample(oksar,outoksar,iteration)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Developed by FWP, @ Vienna, 20130409
%
%
if nargin < 3
    iteration = 2;
end
%
[fpara,zone] = sim_openfault(oksar);

iter = 0;
while iter < iteration
    iter = iter + 1;
    mfpara = [];
    for ni = 1:numel(fpara(:,1))
        cfpara = fpara(ni,:);
        dfpara = sim_fpara2dist(cfpara,cfpara(6),cfpara(7),cfpara(6)/2,cfpara(7)/2,'w',cfpara(5));
        dfpara(:,8) = 0;
        dfpara(:,9) = 0;
        %
        for nj = 1 : 4
            dist         = sqrt((dfpara(nj,1)-fpara(:,1)).^2+ (dfpara(nj,2)-fpara(:,2)).^2);
            [dist,indx]  = sort(dist,'ascend');
            dist         = dist(1:10);
            indx         = indx(1:10);
            %
            %
            %
            if fpara(ni,8)~=0
                dfpara(nj,8) = sum((fpara(indx,8).*(1./dist)) ./ sum(1./dist));
            end
            if fpara(ni,9)~=0
                dfpara(nj,9) = sum((fpara(indx,9).*(1./dist)) ./ sum(1./dist));
            end
        end
        mfpara = [mfpara;dfpara];
    end
    fpara = mfpara;
end
%
sim_fpara2simp(fpara,outoksar,zone);
