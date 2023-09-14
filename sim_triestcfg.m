function sim_triestcfg(outnames,unmat,uncfg,wid,len,outmat,psw,psl,alphas,...
    bounds,minscale)
 %
 %************** FWP Work ************************
 %Developed by FWP, @GU/BJ, 2007-2014
 %  contact by wanpeng.feng@hotmail.com
 %************** Good Luck ***********************
                   
 %
 % sim_triestcfg(outnames,unmat,uninp,wid,len,outmat,psw,psl)
 %   Produce a configure files for Smoothing parameters determination.
 % Input:
 %      outnames, configure file's name
 %      psoksar,  the uniform model MAT file
 %      uncfg,    the configure file for uniform inersion
 %      wid,      the width size in distributed-slip inversion, 2*W(u)
 %      len,      the length size in distributed-slip inversion, 2*L(u)
 %      outmat,   the distributed slip inversion results, all you need
 %      psw,      the patch size in dip direction
 %      psl,      the patch size in strike direction
 % Created by Feng W.P (skyflow2008@hotmail.com)
 % Institute of Geophysics, Chinese Earthquake Administration
 % Completed this work in University of Glasgow
 % 3 July,2009 v0.1
 %
 if nargin < 1 || isempty(outnames)==1
    outnames = 'psokinv_TRIEST.cfg';
 end
 if nargin < 2 || isempty(unmat)==1
    unmat = 'DSM.psoksar';
 end
 if nargin < 3 || isempty(uncfg)==1
    uncfg = 'psokinv.cfg';
 end
 if nargin < 4 || isempty(wid)==1
    wid = '20';
 end
 if nargin < 5 || isempty(len)==1
    len = '20';
 end
 if nargin < 6 || isempty(outmat)==1
    outmat = 'result\SMEST.mat';
 end
 if nargin < 7 || isempty(psw)==1
    psw = '1';
 end
 if nargin < 8 || isempty(psl)==1
    psl = '1';
 end
 if nargin < 9 || isempty(alphas)==1
     alphas = num2str([0.025,0.025,0.025]);
 end
 if nargin < 10 || isempty(bounds)==1
     bounds = num2str(zeros(numel(len)*4,1));
 end
 if nargin < 11 || isempty(minscale)==1
     minscale = '0';
 end
 %
 fid = fopen(outnames,'w');
 fprintf(fid,'%s\n','# Uniform Model MAT or PSOKSAR');              % the uniform fault model in matlab mat format
 fprintf(fid,'%s\n',unmat);
 fprintf(fid,'%s\n','# Uniform Inversion CFG');          % the configure file when uniform model inversion.
 fprintf(fid,'%s\n',uncfg);
 fprintf(fid,'%s\n','# Distributed Model WIDTH(km)');    % the width size   (km), when multiple faults, the width will be n*1.
 fprintf(fid,'%s\n',wid);
 fprintf(fid,'%s\n','# Distributed Model LENGTH(km)');   % the length size (km), the same with obve.
 fprintf(fid,'%s\n',len);
 fprintf(fid,'%s\n','# Distributed Model PatchSize(W)'); % same with obove
 fprintf(fid,'%s\n',psw);
 fprintf(fid,'%s\n','# Distributed Model PatchSize(L)'); % same with length
 fprintf(fid,'%s\n',psl);
 fprintf(fid,'%s\n','# Smoothing Wight Parameter');      % you must give three 
 fprintf(fid,'%s\n',alphas);
 fprintf(fid,'%s\n','# ABIC to estimation of DIP angles: e.g, nofault,nopara,minv,step,maxv');
 fprintf(fid,'%s\n','0 ');
 fprintf(fid,'%s\n','# Boundary zero constraints: default, R L U B; 0 Yes,1 No');
 fprintf(fid,'%s\n',bounds);
 fprintf(fid,'%s\n','# Minumn Moment Scale Wight Parameter');
 fprintf(fid,'%s\n',minscale);
 fprintf(fid,'%s\n','# Output Result');
 fprintf(fid,'%s\n',outmat);
 fclose(fid);
 %disp('Feng W.P...');
 
 
 
 
    
