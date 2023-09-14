function [fpara,index] = sim_psokinv2re(matfile,isplot)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Return the best one with some figures
% Input: matfile, the result from psokinv code.
% Created by Feng W.P, 2010-04-25
% Example:
% >> fpara = sim_psokinv2re('result/Yushu_VCM_v2.mat');
% NOTICE: currect directory should include the inp directory...
%%%%%
% Updated by Feng W.P, 2010-05-03
% Now if sub(abs(abc)) not equal 0, then a modified inp file will be
% created.
%
%
if nargin<1
  fpara = [];
  index = [];
  return
end
if nargin<2
   isplot = 1;
end
%
smat  = load(matfile);
mstd  = smat.outstd;
mstd  = mstd(:,1);
index = find(mstd ==min(mstd));
modls = smat.outfpara;
fpara = modls{index};
ndata = numel(smat.cinput);
mabc  = smat.abcsm{index};
nrow  = ceil(ndata/2);
for ni=1:ndata
    %df  = smat.cinput{ni};
    df  = mabc(ni).fname;
    df  = df{1};
    a   = mabc(ni).a;
    b   = mabc(ni).b;
    c   = mabc(ni).c;
    %
    if exist(df,'file')~=0
        data= sim_inputdata(df);
        dis = multiokadaALP(fpara,data(:,1),data(:,2));
        erro= data(:,1).*a+data(:,2).*b+c;
        osim= dis.E.*data(:,4)+dis.N.*data(:,5)+dis.V.*data(:,6)-erro;
        [ipath,iname,ext] = fileparts(df);
        outname = [ipath,'/',iname,'_RMABC',ext];
        outdata = [data(:,1),data(:,2),data(:,3)-erro,data(:,4:7)];
        foutid  = fopen(outname,'w');
        fprintf(foutid,'%15.8f %15.8f %11.8f %11.8f %11.8f %11.8f %11.8f\n',outdata');
        fclose(foutid);
        if isplot == 1
            subplot(2,nrow,ni);plot(data(:,3),'-r','LineWidth',2.5);hold on;
            plot(osim,'-b');title([df ' STD:' num2str(std(osim-data(:,3)))]);
            legend('OBS','SIM');
        end
        
    else
        disp([df{1} ' is not found...']);
    end
end
