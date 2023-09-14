function [X,Y,slip,offx,offy] = sim_fig2d(fpara,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
   %
   % ncl is colormap, like 'jet'
   % lwid is the width of the quiver, arrow
   % acl  is the color of the quiver, arrow
   % polygon is another region on the planet.
   % isquiver, a signal, 1 is true, to plot; 0 is no, don't plot.
   % 
   % Revised history:
   %     Writen by Feng W.P, at 2008-07-05
   %     added the some documents by Feng W.P, at 2008-07-19
  if nargin<1
     disp('sim_fig2d(fpara,ncl,lwid,acl,polygon,isquiver,qlen,conWid,conCol,crange,vector)');
     disp('new version: sim_fig2d(fpara,varargin);');
     return
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %load mycolor.mat
  outcpt = gmt_cptdb('slipm','matlab');
  ncl = flipud(outcpt);
  % ncl      = mycolor;
  nclf      = 'NULL.cpt';
  lwid     = 0.8;
  acl      = 'k';
  polygon  = [];
  isquiver = 1;
  qlen     = 0.8;
  conWid   = 0.7;
  conCol   = 'r';
  crange   = [];
  vector   = 0:10:50;
  istitile = 0;
  iscolor  = 1;
  sliptype = 'syn';
  isnoline = 0;
  xytype   = 1;
  colorbarloc = 1;
  modeltype   = 'fpara';
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  v = sim_varmag(varargin);
  %
  for ni = 1:2:numel(varargin)
    %
    par = varargin{ni};
    val = varargin{ni+1};
    eval([par,'=val;']);
  end
  %
  %
  if exist(nclf,'file')
      bname = strsplit(nclf,'.cpt');
      ncl = gmt_cptdb(bname{1},'matlab');
      ncl = ncl(1:256,:);
      % ncl = flipud(outcpt);
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  
  fpara  = sim_rmduplicate(fpara);
  if strcmpi(modeltype,'fpara')
      fpara  = sim_fpara2sortv3(fpara,xytype);
  else
      fpara  = sim_fpara2sort_fixmodel(fpara,xytype);
  end
  hold on ;
  %
  %fpara  = sim_fpara2sortv3(fpara,xytype);
  [X,Y,Cx,Cy,Aslip,offx,offy,ind] = sim_plot2d(fpara,xytype,modeltype);
  %
  Y    = Y.*-1;
  Cy   = Cy.*-1;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  switch sliptype
      case 'syn'
         slip = sqrt(Aslip(:,1).^2+Aslip(:,2).^2);
      case 'strike'
         slip = Aslip(:,1);
      case 'dip'
         slip = Aslip(:,2);
      case 'opening'
         slip = Aslip(:,3);
      otherwise
         slip = Aslip(:,2);
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if isempty(crange) == 1
      crange = [round(min(slip(:)).*100)./100,round(max(slip(:)).*100)./100];
  end
  if isempty(vector) == 1
      vector = crange(1):(crange(2)-crange(1))/10:crange(2);
      vector = round(vector.*100)./100;
  end
  %
  op = [min(min(X)),max(max(X)),min(min(Y)),max(max(Y))];
  paid = patch(X,Y,slip');
  
  if isnoline == 1
     set(paid,'LineStyle','none');
     %
     outpoly = [op(1),op(3);...
                op(1),op(4);
                op(2),op(4);
                op(2),op(3);
                op(1),op(3)];
     hold on
     plot(outpoly(:,1),outpoly(:,2),'-k','LineWidth',1.8);
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  hold on
  if isempty(polygon)~=1 
    plot(polygon(1:2,1),polygon(1:2,2),'Color','w','LineWidth',2.0);
    plot(polygon(2:3,1),polygon(2:3,2),'Color','w','LineWidth',2.0);
    plot(polygon(3:4,1),polygon(3:4,2),'Color','w','LineWidth',2.0);
    plot([polygon(4,1),polygon(1,1)],...
         [polygon(4,2),polygon(1,2)],...
         'Color','w','LineWidth',1.0);
  end
  %
  if isquiver == 1 
   ty = Aslip(:,2);                              %.*cosd(fpara(:,4));%.*cosd(fpara(:,3)-180)-Aslip(:,1).*sind(180-fpara(:,3));
   tx = Aslip(:,1);                              %-1.*Aslip(:,2).*cosd(fpara(:,4)).*sind(fpara(:,3)-180)-Aslip(:,1).*cosd(180-fpara(:,3));
   quiver(Cx(:),Cy(:),tx(:),ty(:),qlen,'Linewidth',lwid,'Color',acl);
  end
  grid on
  %;
  nx = max(ind(:,1));%
  ny = max(ind(:,2));% disp(max(Y(:)));
  if nx*ny ~= numel(Cx)
     disp('Please check the fault model, there should be duplicated ones...');
     % return
  end
  %
  flag = 1;
  if (flag==0) 
    [C,h] = contour(resizem(reshape(Cx(:),ny,nx),[10*ny,10*nx],'bicubic'),...
                  resizem(reshape(Cy(:),ny,nx),[10*ny,10*nx],'bicubic'),...
                  resizem(reshape(slip(:),ny,nx),[10*ny,10*nx],'bicubic'),...
                  vector,'LineWidth',conWid);
    text_handle = clabel(C,h);
    set(text_handle,'FontName','Arial','FontSize',10,'BackgroundColor',[1 1 .9]) 
    %get(text_handle(1))
    %
    set(h,'ShowText','on','LineColor',conCol);%,'TextStep',get(h,'LevelStep')*1.5);
  end
  
  %
  axis equal
  set(gca,'XLim',[min(X(:)),max(X(:))],...
          'YLim',[min(Y(:)),max(Y(:))]);
  box on
  if istitile == 1
      xlabel('Along Strike (km)');
      ylabel('Along Dip (km)');
  end
  %
  hid = findobj(gca);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cax1 = gca();
  colormap(cax1,ncl);
  %
  if iscolor == 1
     %
     switch colorbarloc
         case 1
             colorbar('Location','EastOutside');
         case 2
             colorbar('Location', 'SouthOutside');
     end
  end
  %
  hold on
  caxis(crange);
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %pos = get(get(paid,'Parent'),'Position');
  
 
