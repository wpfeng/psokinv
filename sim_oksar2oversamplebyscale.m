function fpara = sim_oksar2oversamplebyscale(oksar,outoksar,iteration,thre)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Developed by FWP, @ Vienna, 20130409
%
if nargin < 1
   disp('sim_oksar2oversamplebyscale(oksar,outoksar,iteration,thre)');
   return
end

%
if nargin < 3
    iteration = 100;
end
%
[fpara,zone] = sim_openfault(oksar);
if nargin < 4
    thre = min(fpara(:,7));
end

%
iter = 0;
while iter < iteration
    iter = iter + 1;
    mfpara   = [];
    outindex = [];
    for ni = 1:numel(fpara(:,1))
        cfpara = fpara(ni,:);
        %
        if cfpara(7) > thre
            %
            outindex    = [outindex;ni];
            dl          = cfpara(7)/2;
            dw          = cfpara(6)/2;
            dfpara      = sim_fpara2dist(cfpara,cfpara(7),cfpara(6),dl,dw,'w',cfpara(5));
            dfpara(:,8) = 0;
            dfpara(:,9) = 0;
            %
            for nj = 1 : 4
                %
                if fpara(ni,8)~=0
                    dfpara(nj,8) = fpara(ni,8);%sum((fpara(indx,8).*(1./dist)) ./ sum(1./dist));
                end
                if fpara(ni,9)~=0
                    dfpara(nj,9) = fpara(ni,9);%sum((fpara(indx,9).*(1./dist)) ./ sum(1./dist));
                end
            end
            mfpara = [mfpara;dfpara];
        end
    end
    %
    if isempty(outindex)==0
        fpara(outindex,:) = [];
        fpara = [fpara;mfpara];
    end
end
%
sim_fpara2simp(fpara,outoksar,zone);
