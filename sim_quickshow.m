function input = sim_quickshow(inputfile,zone)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Purpose:
%    quick map the inp data by pcolor...
% Modification History:
%  Feng, W.P, 2010-01,created.
%  Feng, W.P, 2010-11-29,add zone, a new option
%     -> permit to convert the coordinates into LL.
% 
if nargin < 2
    zone = 'NULL';
end
%
[~,fname] = fileparts(inputfile);
input   = sim_inputdata(inputfile);
x       = input(:,1);
y       = input(:,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(zone,'NULL')~=1
    [cx,cy] = utm2deg(x.*1000,y.*1000,zone);
    x = cy;
    y = cx;
end
mindist = sim_mindistv2([x(:) y(:)]);
np      = size(x(:),1);
XI      = zeros(np,5);
YI      = zeros(np,5);
XI(:,1) = x-mindist/2;
XI(:,2) = x+mindist/2;
XI(:,3) = x+mindist/2;
XI(:,4) = x-mindist/2;
XI(:,5) = x-mindist/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
YI(:,1) = y-mindist/2;
YI(:,2) = y-mindist/2;
YI(:,3) = y+mindist/2;
YI(:,4) = y+mindist/2;
YI(:,5) = y-mindist/2;
%disp('FENG W.P...');
hold on
%sim_fig3d(fpara);
%figure();
%subplot(ndata,1,nf);
patch(XI',YI',input(:,3)');
title(fname);
colorbar;
caxis([min(input(:,3)),max(input(:,3))]);
xlim = get(gca,'XLim');
ylim = get(gca,'YLim');
axis equal;
set(gca,'XLim',xlim);
set(gca,'YLim',ylim);
box on;
