function outfpara = sim_mkdist_model(fpara,inrake,nx,ny)
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 3
    nx = 4;
    ny = 6;
end
%
index = sim_fpara2index_dep(fpara);
%
%
nxmax = max(index(:,1));
nymax = max(index(:,2));
%
outfpara = fpara;
outfpara(:,8) = 0;
outfpara(:,9) = 0;
%
for ni = 2:nx:nxmax-1
    %
    for nj = 2:ny:nymax-1
        %
        %
        xind = [ni-1,ni,ni+1];
        yind = [nj-1,nj,nj+1];
        %
        for nk = 1:numel(xind)
            for np = 1:numel(yind)
                %
                xind1 = index(:,1)==xind(nk);
                yind1 = index(:,2)==yind(np);
                ind   = xind1 .* yind1;
                outfpara(ind==1,8) = cosd(inrake);
                outfpara(ind==1,9) = sind(inrake);
                
            end
        end
        
    end
end
    