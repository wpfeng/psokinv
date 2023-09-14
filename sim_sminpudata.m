function [input,am,cinput,vcm,abccof,weighs,dweight] = sim_sminpudata(inf,newinpdir)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 % Created by Feng, W.P,2011/11
 % working for ABC estimation coeff
 %
 global dweight vcmtype
 if nargin < 2
     newinpdir = [];
 end
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [psoPS,cinput,symbols,outoksar,abccof,outmatf,tfpara,...
  lamda,myu,aa,aa,aa,aa,weighs,vcms,a,a,a,a,a,a,a,a,a,a,a,a,isvcm] = sim_readconfig(inf);
 %
 % Updated by Feng, W.P. @ EOS of NTU, Singapore,2015-06-25
 %
 %weighs  = weighs;%./sum(weighs);
 dweight = [];
 %
 for ni=1:size(cinput,1)
     %
     cinp = cinput{ni}{1};
     if ~isempty(newinpdir)
         [t_mp,bname,bext] = fileparts(cinp);
         cinp = [newinpdir,'/',bname,bext];
     end
     %TMP_data = sim_inputdata(cinp);
     TMP_data = load(cinp);
     %
     % tmp_weig = zeros(size(TMP_data,1),1)+weighs(ni);
     % Updated by Feng, W.p., @ EOS of NUT in Singapre, 2015-06-21
     % 
     tmp_weig = TMP_data(:,7).*weighs(ni);
     dweight  = [dweight;tmp_weig];
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %
 if ~isempty(newinpdir) && exist(newinpdir,'dir')
     for ninps = 1:numel(cinput)
         [t_mp,bname,bext] = fileparts(cinput{ninps}{1});
         cinput{ninps}{1}  = [newinpdir,'/',bname,bext];
     end
 end
 [am,cyeind,cnoind] = sim_mergin(cinput,abccof);
 nset               = numel(cyeind);
 input              = [];
 if nset > 0
   for ni=1:nset
       inf   = cinput{cyeind(ni)}{1};
       if ~isempty(newinpdir) && exist(newinpdir,'dir')
           %
           [t_mp,bname,bext] = fileparts(inf);
           inf = [newinpdir,'/',bname,bext];
       end
       if exist(inf,'file')
           % data = sim_inputdata(inf);
           data = load(inf);
       else
           data = [];
       end
       %
       input = [input;data];
   end
 end
 if numel(cnoind)>0
   for ni=1:numel(cnoind)
      inf  = cinput{cnoind(ni)};
      if exist(inf{1},'file')
         data = load(inf{1});
      else
         data = [];
      end
      input= [input;data];
   end
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % For structure the weight column matrix
cindex = [cyeind;cnoind];
ndata  = numel(cindex);
cnum   = zeros(ndata,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wmatrix = [];
if isvcm == 1
    dig_1   = ones(size(input,1),1);
    mvcm    = diag(dig_1);
    novcm   = 0;
    for ni=1:ndata
        %
        [t_mp,np]  = sim_inputdata(cinput{ni}{1});
        cnum(ni)   = np;
        tmp        = (zeros(cnum(ni),1)+1).*weighs(cindex(ni));
        wmatrix    = [wmatrix;tmp];
        start      = novcm+1;
        novcm      = novcm+np;
        %
        if strcmpi(vcms{cindex(ni)},'NULL')==0
            disp([vcms{cindex(ni)}{1} ' is loading...']);
            [t_mp,nboot] = fileparts(vcms{cindex(ni)}{1});
            [t_mp,t_mp,ext] = fileparts(nboot);
            vcmtype  = ext(2:end);
            vcm      = load(vcms{cindex(ni)}{1});
            %
            if isfield(vcm,'vcm')
                vcmtype = 'vcm';
                vcm = vcm.vcm;
            else
                vcmtype = 'cov';
                vcm = vcm.cov;
            end
            mvcm(start:novcm,start:novcm) = vcm.*weighs(ni);
        end
        %
    end
vcm = mvcm;
else
    vcm = 1;
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
