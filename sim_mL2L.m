function L = sim_mL2L(mL)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
np = 0;
L  = [];
iseq = zeros(numel(mL),1);%rakecons(:,2) == rakecons(:,3);
for ni = 1:numel(find(iseq==0))
    tmpG = mL{ni};
    np   = size(L,1)+size(tmpG,1);
    cL   = zeros(np);
    %
    cL(1:size(L,1),1:size(L,1)) = L;
    cL(size(L,1)+1:np,size(L,1)+1:np) = tmpG;
    L  = cL;
end
L = [L L.*0;L.*0 L];
if numel(find(iseq==1))>0
    for ni = numel(find(iseq==0))+1:numel(mL)
        tmpG = mL{ni};
        np   = size(L,1)+size(tmpG,1);
        cL   = zeros(np);
        L    = [L zeros(size(tmpG,1));...
            L.*0 tmpG];
        %
        cL(1:size(L,1),1:size(L,1)) = L;
        cL(size(L,1)+1:np,size(L,1)+1:np) = tmpG;
        L  = cL;
   end
end

