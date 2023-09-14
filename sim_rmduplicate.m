function outfpara  = sim_rmduplicate(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
typefpara = fpara(:,1).*0.15 + ...
         fpara(:,2).*0.15 + ...
         fpara(:,3).*0.15 + ...
         fpara(:,4).*0.15 + ...
         fpara(:,5).*0.15 + ...
         fpara(:,6).*0.15 + ...
         fpara(:,7).*0.15 + ...
         fpara(:,8).*0.15 + ...
         fpara(:,9).*0.15;
%
outtype = unique(typefpara);
if numel(outtype)==numel(typefpara)
    outfpara = fpara;
    return
else
    outfpara = zeros(numel(outtype),10);
    for ni = 1:numel(outtype);
        index = find(typefpara == outtype(ni));
        outfpara(ni,:) = fpara(index(1),:);
    end
end

        
