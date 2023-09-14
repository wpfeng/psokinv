function outfpara = sim_fpara2oversamplebyscale(fpara,thre)
%
% +Input:
%   fpara,     fault data in rectangular shapes in [n,10], where n is the number of faults.
%   thre,      the threshold,[wthre,lthre]...
%
% Developed by FWP, @ Vienna, 2013/04/09
% Re-sort it for fpara format by FWP, @ IGPP, SIO, UCSD, 2013-10-05
%
if nargin < 1
   disp('outfpara = sim_fpara2oversamplebyscale(fpara,thre)');
   outfpara = [];
   return
end
%
if numel(thre)==1
    thre = [thre,thre];
end
flag = sum(fpara(:,6)>thre(1)) + sum(fpara(:,7)>thre(2));
%
iter = 0;
while flag > 0
    %
    iter = iter + 1;
    mfpara   = [];
    outindex = [];
    for ni = 1:numel(fpara(:,1))
        cfpara = fpara(ni,:);
        %
        if cfpara(7) > thre(2) || cfpara(6) > thre(1)
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
                mdist = sqrt((fpara(:,1)-dfpara(nj,1)).^2 ...
                          +  (fpara(:,2)-dfpara(nj,2)).^2 ...
                          +  (fpara(:,5)-dfpara(nj,5)).^2);
                %
                [tmp_a,ttoutindex] = sort(mdist);
                if numel(ttoutindex)>=4
                    wdist = 1./mdist(ttoutindex(1:4));
                    sslip          = fpara(ttoutindex(1:4),8);
                    dslip          = fpara(ttoutindex(1:4),9);
                    dfpara(nj,8)   = sum(wdist.*sslip./sum(wdist));
                    dfpara(nj,9)   = sum(wdist.*dslip./sum(wdist));
                else
                    dfpara(nj,8)   = fpara(ttoutindex(1),8);
                    dfpara(nj,9)   = fpara(ttoutindex(1),9);
                end
                %
            end
            mfpara = [mfpara;dfpara];
        end
    end
    %
    if isempty(outindex)==0
        fpara(outindex,:) = [];
        fpara = [fpara;mfpara];
    end
    %
    flag = sum(fpara(:,6)>thre(1)) + sum(fpara(:,7)>thre(2));
end
%
outfpara = fpara;
