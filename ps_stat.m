function ps_stat(dire,postfix,outdir)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
if nargin<1 || isempty(dire)==1
   disp('-------------------------------------');
   disp('ps_stat(dire,postfix,outdir)');
   disp('          dire,  the necessary keyward,destination folder, e.g, /./');
   disp('       postfix,  the postfix for searching, default /*.inp*/');
   disp('         outdir, the folder to save results,default /./');
   disp(['Example: ps_stat(' '''' '.' '''' ',' '''' '*.inp*' '''' ');']);
   disp('-------------------------------------');
   return
end
%
if nargin<2 || isempty(postfix)==1
   postfix = '*.inp*';
end
if nargin<3 || isempty(outdir)==1
   outdir = '.';
end
%
%file   = dir(fullfile(dire,postfix));
%fpara  = sim_oksar2SIM(fullfile(dire,file(1).name));

file   = dir(fullfile(dire,postfix));
for nj=1:numel(file)
    fpara  = sim_oksar2SIM(fullfile(dire,file(nj).name));
    nfault = size(fpara,1);
    %fid    = zeros(nfault,1);
    for ni=1:nfault
        %nfault = size(fpara,1);
         fid    = zeros(nfault,1);
        fid(ni) = fopen(fullfile(outdir,['monte_Fault' num2str(ni) '.dat']),'a');
        m0      = sim_fpara2moment(fpara(ni,:),[]);
        [xuc,yuc,zuc] = sim_fpara2corners(fpara(ni,:),'uc','UTM','UTM',[]);
        [xlc,ylc,zlc] = sim_fpara2corners(fpara(ni,:),'lc','UTM','UTM',[]);
        [xlc,ylc,zcc] = sim_fpara2corners(fpara(ni,:),'cc','UTM','UTM',[]);
        rake          = atan2(fpara(ni,9),fpara(ni,8));
        slip          = sqrt(fpara(ni,9)^2+fpara(ni,8)^2);
        strike        = fpara(ni,3);
        dip           = fpara(ni,4);
        len           = fpara(ni,7);
        wid           = fpara(ni,6);
        outdata = [strike,dip,rake*180/3.14159165,slip,xuc,yuc,len,wid,zuc,zlc,zcc,0,0,0,m0(1)/10e18,0];
        %disp(outdata);
        fprintf(fid(ni),['%8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f'...
                         '%8.4f %8.4f %8.4f %8.4f %8.4f\n'],outdata);
        fclose(fid(ni));
    end
    
end
% for ni = 1:nfault
%     fclose(fid(ni));
% end
