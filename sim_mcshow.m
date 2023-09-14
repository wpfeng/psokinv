function sim_mcshow(modelfile,index,data_2,data_3,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sim_mcshow(modelfile,index)
% modelfile, created by sim_getrev2,ascii format
% index,     the parameter you need
% data_2,    the result will be shown simutaneously...
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% Index:
%   1      2   3    4    5   6   7   8   9   10  11       14
% [strike,dip,rake,slip,xuc,yuc,len,wid,zuc,zlc,zcc,0,0,0,m0,0];
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% Modified by Feng W.P, 5 Sep 2009
%          > print the specification when no input.
% Updated by FWP,@GU, 2014-08-21
%          > the input data is sorted by sim_sortdata4mcanalysis.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin<1
   disp('sim_mcshow(modelstas,index,varargin)');
   disp('************************************');
   disp('Input:');
   disp('  >>> modelstas, the result file from sim_getrev2');
   disp('  >>> index,     which parameters will be selected in the trade-off figure');
   disp('  >>> data_2,    the second result');
   disp('  >>> data_3,    the third result');
   disp('  >>> varagin,   the function supports the multi-parameters inputs.');
   disp('  >>> % Index:');
   disp('  >>> %   1      2   3    4    5   6   7   8   9   10  11  12  13 14,15');
   disp('  >>> % [strike,dip,rake,slip,xuc,yuc,len,wid,zuc,zlc,zcc,xcc,ycc,0,m0,0];');
   return
end
if nargin<2 || isempty(index) == 1
   index = [1,2,3,7,8,9,15];
end
if nargin<3
   data_2 = [];
end
if nargin<4 || isempty(data_3)==1
   data_3 = [];
   isdata3= 0;
else
   isdata3= 1;
end
%data_3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fontsize = 6;
%titels   = {'Str(deg)','Dip(deg)','Rake(deg)', 'Slip(m)','Local-x(km)','Local-y(km)',...
%          'Len(km)','Wid(km)' ,'Dep(km)', 'Dep_l_c(km)','Dep_c_c(km)','','','Mo(Nm)'};
%             1         2            3            4        5          6
titels   = {'Str(deg)','Dip(deg)','Rake(deg)', 'Slip(m)','Lon(deg)','Lat(deg)',...
          'Len(km)','Wid(km)' ,'Dep(km)', 'Dep_l_c(km)','Dep_c_c(km)','Lon(deg)','Lat(deg)','','Mo(Nm)','Mo(Nm)'};
          % 7          8          9          10           11            12         13            14
          %      
          %   
islonlat = 0;
npara = numel(index);
dx    = 0.8/npara;
dy    = 0.8/npara;
%
moscale      = 10^18;
markersize   = 2.2;
markersize_2 = 3.0; 
ylableshift  = -0.25;
histdata_2   = 0;
ystart       = 0.06;
rmargin      = 0.05;
xint         = rmargin/npara;
yint         = rmargin/npara;
repoint      = [];
scaleindex   = 1; 
scalerange   = [0,360];
utmzone      = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim_passingparameters;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data  = load(modelfile);
data(:,15) = data(:,15)./moscale;
%
%
%
for ni = 1:numel(scaleindex)
    %scalerange(ni,:)
    data(data(:,scaleindex(ni)) < scalerange(ni,1),:) = [];
    data(data(:,scaleindex(ni)) > scalerange(ni,2),:) = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ntime = size(data,1);
if islonlat==1 && isempty(repoint)==0
   if isempty(utmzone)==1
      [x0,y0,zone] = deg2utm(repoint(2),repoint(1));
   else
       zone = utmzone;
   end
   utmzone      = repmat(zone,numel(data(:,1)),1);
   [lat,lon]    = utm2deg(data(:,5).*1000,data(:,6).*1000,utmzone);
   data(:,5)    = lon;
   data(:,6)    = lat;
   titels{5}    = 'Lon(degree)';
   titels{6}    = 'Lat(degree)';
   if isempty(data_2)==0
       utmzone2 = repmat(zone,numel(data_2(:,1)),1);
       [lat,lon]= utm2deg(data_2(:,5).*1000,data_2(:,6).*1000,utmzone2);
       data_2(:,5) = lon;
       data_2(:,6) = lat;
   end
   if isempty(data_3)==0
       utmzone2 = repmat(zone,numel(data_3(:,1)),1);
       [lat,lon]= utm2deg(data_3(:,5).*1000,data_3(:,6).*1000,utmzone2);
       data_3(:,5) = lon;
       data_3(:,6) = lat;
       disp('Location from Data_3:');
       disp([lon,lat]);
   end
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ni = 1:npara
  if ni==1
     xstart = 0.08;
  else
     xstart=dx+xstart+xint;
  end
  position = [xstart,ystart,dx,dy];
  subplot(npara,npara,ni+(npara-1)*npara);hist(data(:,index(ni)),10); xlabel(titels{index(ni)},'fontsize',fontsize); 
  set(gca,'TickDir','out','TickLength',[0.05,0.05]);
  if nargin >=3 
     if isempty(data_2)==0 
       if histdata_2==1
          hold on
          subplot(npara,npara,ni+(npara-1)*npara);hist(data_2(:,index(ni)),10);
       end
     end
  end
  %%%%%%%%%%%
  %%%% Hist Color
  h = findobj(gca,'Type','patch');
  set(h,'FaceColor','k','EdgeColor','w')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % the norm fitting
  [muhat,sigmahat] = normfit(data(:,index(ni)));
  disp([titels{index(ni)},',mu = ',num2str(muhat) '; sigma = ' num2str(sigmahat)]);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ni >1
     set(gca,'YTickLabel',[]);
  else
     ay = ylabel('Frequancy','FontSize',fontsize);
     set(ay,'Units','normalized');
     ayposi = get(ay,'Position');
     set(ay,'Position',[ylableshift,ayposi(2:end)]);
  end
  set(gca,'YLim',   [0,ntime]);
  set(gca,'FontSize',fontsize);
  set(gca,'position',position);
  %
  
  if nargin>=3 && isempty(data_2)==0
    xlim = [min([data(:,index(ni));data_2(:,index(ni))]),...
            max([data(:,index(ni));data_2(:,index(ni))])];% 
  else
    xlim = [min(data(:,index(ni))),max(data(:,index(ni)))];%
  end
  %
  set(gca,'XLim',xlim);
  ylim  = get(gca,'YLim');
  xdata = xlim(1):(xlim(2)-xlim(1))/1000:xlim(2);
  ydata = normpdf(xdata,muhat,sigmahat); 
  hold on 
  ymax  = max(ydata(:));
  scale = ylim(2)*0.5/ymax;
  plot(xdata,ydata.*scale,'-r','LineWidth',1.5);
  if  histdata_2 == 1 && nargin>=3
      if isempty(data_2)==0 
         [muhat_2,sigmahat_2] = normfit(data_2(:,index(ni)));
         ydata_2 = normpdf(xdata,muhat_2,sigmahat_2);
         hold on
         plot(xdata,ydata_2.*scale,'-m','LineWidth',1.5);
         plot([muhat_2,muhat_2],ylim,'--g','LineWidth',1.0);
      end
  end
  
  plot([muhat,muhat],ylim,'--g','LineWidth',1.0);
  text((xlim(2)-xlim(1))*0.2+xlim(1),(ylim(2)-ylim(1))/10*6.5+ylim(1),['\xi = \pm' num2str(sigmahat,'%10.3f')],'FontSize',fontsize);
  text((xlim(2)-xlim(1))*0.2+xlim(1),(ylim(2)-ylim(1))/10*8.5+ylim(1),['\mu =   ' num2str(muhat,'%10.3f')],'FontSize',fontsize);
  %
  if ni ==npara-1
    %get(gca,'position')
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ystart = 0.06;
for nj = 1:npara-1
    in = npara-nj+1;
    ystart = ystart+dy+yint;
    for ni = 1:npara-nj
        if ni==1
            xstart=0.08;
        else
            xstart=dx+xstart+xint;
        end
        position = [xstart,ystart,dx,dy];
        %
        subplot(npara,npara,ni+(npara-nj-1)*npara);plot(data(:,index(ni)),data(:,index(in)),'ok',...
                                                        'MarkerFaceColor',[0,0,0],'MarkerSize',markersize);
        set(gca,'TickDir','out','TickLength',[0.05,0.05]);

        if nargin>=3
          if isempty(data_2)==0
           hold on
           plot(data_2(:,index(ni)),data_2(:,index(in)),'vr','MarkerFaceColor',[1,0,0],...
                'LineWidth',0.0001,'MarkerSize',markersize_2);
          end
        end
        if isdata3==1
            hold on
            plot(data_3(:,index(ni)),data_3(:,index(in)),'or','MarkerFaceColor','r',...
                'LineWidth',0.01,'MarkerSize',5.5);
        end
        if ni >1
            set(gca,'YTickLabel',[]);
            set(gca,'XTickLabel',[]);
        else
            ay = ylabel(titels{index(in)},'FontSize',fontsize);
            %
            set(ay,'Units','normalized');
            ayposi = get(ay,'Position');
            set(ay,'Position',[ylableshift,ayposi(2:end)]);
            %
            set(gca,'XTickLabel',[]);
        end
        %disp([min(data(:,index(in))),max(data(:,index(in)))]);
        if nargin>=3
           if isempty(data_2)==0
              miny = min([data(:,index(in));data_2(:,index(in))]);
              maxy = max([data(:,index(in));data_2(:,index(in))]);
           else
              miny = min(data(:,index(in)));
              maxy = max(data(:,index(in)));
           end
        else
           miny = min(data(:,index(in)));
           maxy = max(data(:,index(in)));
        end
        if nargin>=3 && isempty(data_2)==0
            xlim = [min([data(:,index(ni));data_2(:,index(ni))]),...
                    max([data(:,index(ni));data_2(:,index(ni))])];%
        else
            xlim = [min(data(:,index(ni))),max(data(:,index(ni)))];%
        end
        set(gca,'XLim',xlim);
        set(gca,'YLim',   [miny*1,maxy*1]);
        set(gca,'FontSize',fontsize);
        set(gca,'position',position)
        %get(gca,'position')
    end
end
%
set(gcf,'PaperType','A3','Units','Normalized','OuterPosition',[0,0.15,0.5,0.65]);
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
%
