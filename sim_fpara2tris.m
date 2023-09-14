function [tri,trix,triy,triz,triss,trids,trits] = sim_fpara2tris(fpara)
%
%
% Create triangular elements of faults from rectangular fault patches...
%
% Developed by Feng, W.P., @ YJ, 2015-07-12
%
tri  = struct();
ntri = 0;
trix = [];
triy = [];
triz = [];
triss= [];
trids= [];
trits= [];
%
%
%
for ni = 1:numel(fpara(:,1))
    %
    cfpara = fpara(ni,:);
    allp   = sim_fpara2allcors(cfpara);
    ntri   = ntri+1;
    tri(ntri).x  = allp([1,2,4],1);
    tri(ntri).y  = allp([1,2,4],2);
    tri(ntri).z  = allp([1,2,4],3).*-1;
    tri(ntri).ss = cfpara(8);
    tri(ntri).ds = cfpara(9);
    tri(ntri).ts = cfpara(10);
    tri(ntri).numneig = ntri;
    trix = [trix;tri(ntri).x(:)'];
    triy = [triy;tri(ntri).y(:)'];
    triz = [triz;tri(ntri).z(:)'];
    triss= [triss;tri(ntri).ss];
    trids= [trids;tri(ntri).ds];
    trits= [trits;tri(ntri).ts];
    
    %
    ntri         = ntri+1;
    tri(ntri).x  = allp([2,3,4],1);
    tri(ntri).y  = allp([2,3,4],2);
    tri(ntri).z  = allp([2,3,4],3).*-1;
    tri(ntri).ss = cfpara(8);
    tri(ntri).ds = cfpara(9);
    tri(ntri).ts = cfpara(10);
    tri(ntri).numneig = ntri;
    trix = [trix;tri(ntri).x(:)'];
    triy = [triy;tri(ntri).y(:)'];
    triz = [triz;tri(ntri).z(:)'];
    triss= [triss;tri(ntri).ss];
    trids= [trids;tri(ntri).ds];
    trits= [trits;tri(ntri).ts];
    %
end