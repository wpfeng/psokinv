function sim_sortdata4mcanalysis(dire,postfix,outdir,prefix,isll)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% 
% Modified by Feng W.P, 5 Sep 2009
%         reviced the help info.
% the unit in default for (x,y) is lonlat now. by FWP, @ GU, 20130623
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Renamed by FWP,@GU, 2014-08-21
%    the previous version is sim_getrev2 that is obsoleted 
%    1     2    3   4    5   6   7   8   9   10 11   12   13  14 15 16
% [strike,dip,rake,slip,xuc,yuc,len,wid,zuc,zlc,zcc,xuc1,yuc1,0,m0(1),0]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 1 || isempty(dire) == 1
   disp('-------------------------------------------------------------------');
   disp('Usage: Convert the MC results into the dat files to next plotting...');
   disp('sim_getrev2(dire,postfix,outdir)');
   disp('          dire,  the necessary keyward,destination folder, e.g, /./');
   disp('       postfix,  the postfix for searching, default /*.oksar/');
   disp('         outdir, the folder to save results,default /./');
   disp(['Example: sim_getrev2(' '''' '.' '''' ',' '''' '*.oksar*' '''' ');']);
   disp('-------------------------------------------------------------------');
   return
end
%
if nargin < 6
    isll = 1;
end
%
if nargin<2 || isempty(postfix)==1
   postfix = 'MC_*.oksar*';
end
if nargin<3 || isempty(outdir)==1
   outdir = '.';
end
if nargin<4 || isempty(prefix)==1
   prefix = 'monte_Fault';
end
%

file   = dir(fullfile(dire,postfix));
if numel(file)==0
   disp('No finding!');
end
for nj=1:numel(file)
    %
    %
    disp(fullfile(dire,file(nj).name));
    [fpara,uzone] = sim_openfault(fullfile(dire,file(nj).name));
    %fpara  = sim_oksar2SIM(fullfile(dire,file(nj).name));
    %uzone  = sim_oksar2utm(fullfile(dire,file(nj).name));
    %
    nfault   = size(fpara,1);
    %
    for ni=1:nfault
        %nfault = size(fpara,1);
         fid    = zeros(nfault,1);
        fid(ni) = fopen(fullfile(outdir,[prefix num2str(ni) '.dat']),'a');
        m0      = sim_fpara2moment(fpara(ni,:),[]);
        [xuc,yuc,zuc]   = sim_fpara2corners(fpara(ni,:),'uc','UTM','UTM',[]);
        [xlc,ylc,zlc]   = sim_fpara2corners(fpara(ni,:),'lc','UTM','UTM',[]);
        [xuc1,yuc1,zcc] = sim_fpara2corners(fpara(ni,:),'cc','UTM','UTM',[]);
        if isll == 1
            [lats,lons] = utm2deg(xuc.*1000,yuc.*1000,uzone);
            xuc = lons;
            yuc = lats;
            %
            [lats,lons] = utm2deg(xuc1.*1000,yuc1.*1000,uzone);
            xuc1 = lons;
            yuc1 = lats;
        end
        %
        %rake          = atan2(fpara(ni,9),fpara(ni,8));
        rake          = sim_calrake(fpara(ni,:));
        slip          = sqrt(fpara(ni,9)^2+fpara(ni,8)^2);
        strike        = fpara(ni,3);
        dip           = fpara(ni,4);
        len           = fpara(ni,7);
        wid           = fpara(ni,6);
        outdata = [strike,dip,rake,slip,xuc,yuc,len,wid,zuc,zlc,zcc,xuc1,yuc1,0,m0(1),0];
        %disp(outdata);
        fprintf(fid(ni),['%8.4f %7.4f %6.4f %6.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f '...
                         '%9.4f %8.4f %8.4f %e %6.4f\n'],outdata);
        fclose(fid(ni));
    end
    
end
% for ni = 1:nfault
%     fclose(fid(ni));
% end
