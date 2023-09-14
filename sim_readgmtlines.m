function cellsegments = sim_readgmtlines(inp,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% + Purpose:
%    input GMT format with flat ">" line or polygon data into matlab
% + LOG:
%  created by Feng, Wanpeng, 20110410
%
%
if nargin < 2
   isplot = 0;
end
fid          = fopen(inp,'r');
ncell        = 0;
points       = [];
cellsegments = cell(1);
while ~feof(fid)
    tlines = fgetl(fid);
    if isempty(findstr(tlines,'>'))==0
       if ncell >= 1
         cellsegments{ncell} = points;
         points              = [];
       end
       ncell = ncell + 1;
    else
       tmp    = textscan(tlines,'%f %f');
       points = [points;tmp{1},tmp{2}];
    end
end
cellsegments{ncell} = points;
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isplot ~= 0
   for ni = 1:ncell
       tlines = cellsegments{ni};
       plot(tlines(:,1),tlines(:,2),'-or');
       hold on
   end
   axis equal
end
