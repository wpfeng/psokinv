function COV = sim_mC2COV(mC)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
ndata  = numel(mC);
COV    = [];
for ni = 1:ndata
    tmpC = mC{ni};
    np   = size(COV,1)+size(tmpC,1);
    cC   = zeros(np);
    cC(1:size(COV,1),1:size(COV,1)) = COV;
    cC(size(COV,1)+1:end,size(COV,1)+1:end) = tmpC;
    COV = cC;
end
