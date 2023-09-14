function lap = sim_laps2lap(laps)
%
%
%
% Combine laps
% by Wanpeng Feng, @CCRS/NRCan, 2017-09-25
%
nlap = numel(laps);
lapsize = 0;
%
for ni = 1:nlap
    clap = laps{ni};
    dims = size(clap);
    lapsize = lapsize + dims(1);
end
%
lap = zeros(lapsize);
%
lapsize = 0;
for ni = 1:nlap
    clap = laps{ni};
    dims = size(clap);
    lap((lapsize+1):(lapsize+dims(1)),(lapsize+1):(lapsize+dims(1))) = clap;
    lapsize = lapsize + dims(1);
end
