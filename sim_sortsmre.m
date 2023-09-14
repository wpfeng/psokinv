function outputdata = sim_sortsmre(matfile,isplot,newweights)
%
%
% +Name:
%  sim_sortsmre
%  by Feng, W.P., @ Yj, 2015-05-29
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 2
    isplot = 0;
end
if nargin < 3
    newweights = [];
end
%
matre = load(MCM_rmspace(matfile));
dips  = matre.mdip;
dips  = dips(:,3);
input = matre.input;
%
outputdata = [];
for ni = 1:numel(dips)
    %
    cres  = matre.mabicre{ni};
    osim  = cres.osim;
    smest = cres.smest;
    outdata= zeros(numel(osim),2);
    %
    weights = sim_readweights(newweights);
    for nk = 1:numel(osim)
        vstd          = sim_rms((input(:,3)-osim{nk}).*weights);
        outdata(nk,2) = vstd;
    end
    %
    outdata(:,1) = smest(:,3);
    roughness    = smest(:,3);
    %
    fid = fopen([num2str(dips(ni)),'.inp'],'w');
    fprintf(fid,'%f %f\n',outdata');
    fclose(fid);
    %
    outdata(:,1) = smest(:,1);
    fid = fopen([num2str(dips(ni)),'.scf'],'w');
    fprintf(fid,'%f %f\n',outdata');
    fclose(fid);
    if isplot > 0
        plot(outdata(:,1),outdata(:,2),'-or');
        hold on
        text(outdata(end,1)+0.001,outdata(end,2)+0.0005,['Dip:',num2str(dips(ni))]);
        %
    end
    %
    outdata    = [outdata(:,1).*0+dips(ni),outdata,roughness];
    outputdata = [outputdata;outdata];
    %
    
end