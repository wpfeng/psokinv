function [input info G lap] = sim_rquads(fpara,unwfile,incfile,azifile,outfile,maxblocksize,minblocksize,fractor,null_file,...
                              qti_file,threshold, lamd, subxsize, subysize,qtminvar,qtmaxvar,zone,flen,fwid)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
    
%%
% Developed by FWP, @GU, 2009-05-01
% Final version was updated by FWP, @GU, 2012-12-02
% sim_rquads()
% Resolution Quadtree Sampling meothod
%
%%
global isinv datatype OUTPROJ UTMZONE CPROJ rakecons dampingfactor ...
       outputunit extendingtype dsminfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    disp('sim_rquads(fpara,unwfile,inc,azi,outfile,maxblocksize,...');
    disp('           minblocksize,fractor,null_file,qti_file,...');
    disp('           threshold, lamd, subxsize, subysize)');
    disp('---------------------------------------------------------');
    disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    disp('Reference from Rowena Paper (2005,3G).');
    disp('Function: Realize donwsampling by R algorithm.');
    disp('Input:');
    disp('      fpara, the SIM format uniform fault model, m*10.');
    disp('    unwfile, needed to sample data with a rsc header');
    disp('        inc, the inc file to save incidence info with a rsc.');
    disp('        azi, the azi file to save azimuth data with a rsc');
    disp('---------------------------------------------------------');
    disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    disp('The work is completed by Mr.Feng W.P')
    disp('Instituge of Geophysics(IGP),CEA && University of Glasgow.');
    disp('Latest modified time: 5 June 2009');
    disp('A new version on 02/12/2012, a vector bug was fixed...');
    %
    disp('eMail: skyflow2008@hotmail.com');
    disp('---------------------------------------------------------');
    disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    return
end
%
if nargin < 2 || isempty(unwfile)==1
    disp('You must give a InSAR unwrapped file with RSC header!');
    return
end
% [unw,a,b,info] = sim_readroi(unwfile);
% Input the unw file and the headerinfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(unwfile,'file')
    disp([unwfile,' is NOT found. Please have a check and try again!']);
    return
end
%
[indata,cx,cy,info] = sim_readroi(unwfile);
CPROJ               = info.projection;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_ref      = info.x_first;
y_ref      = info.y_first;
x_dim      = info.file_length;
y_dim      = info.width;
x_grid     = info.x_step;
y_grid     = info.y_step;
wavelength = info.wavelength;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dim2x      = fix(log2(x_dim));
dim2y      = fix(log2(y_dim));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 2^dim2x ~= x_dim
    x_dim = 2^(dim2x+1);
end
if 2^dim2y ~= y_dim
    y_dim = 2^(dim2y+1);
end
x_dim = (x_dim > y_dim)*x_dim+(x_dim <= y_dim)*y_dim;
y_dim = (y_dim > x_dim)*y_dim+(y_dim <= x_dim)*x_dim;
%
tmp                                        = zeros(x_dim,y_dim);
tmp(1:info.file_length,1:1:info.width)     = indata;
unw                                        = tmp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 3 || isempty(incfile)==1
    inc = info.incidence;
end
if nargin < 4 || isempty(azifile)==1 || exist(azifile,'file')==0
    azi = info.heading_deg;
end
%
if nargin < 5 || isempty(outfile)==1
    outfile = 'ODRs.xy';
end
if nargin < 6 || isempty(maxblocksize)==1
    maxblocksize = 64;
end
if nargin < 7 || isempty(minblocksize)==1
    minblocksize = 4;
end
if nargin <8 || isempty(fractor)==1
    fractor = 0.5;
end
if nargin <9 || isempty(null_file)==1
    null_file = 'ODRs.null';
end
if nargin <10 || isempty(qti_file)==1
    qti_file = 'ODRs.qti';
end
if nargin <11 || isempty(threshold)== 1
    threshold = 0.05;
end
if nargin <12 || isempty(lamd)== 1
    lamd = 0.02;                       % for the smoothing weight
end
if nargin <13 || isempty(subxsize)== 1
    subxsize = 1;                       % for the smoothing weight
end
if nargin <14|| isempty(subysize)==1
    subysize = 1;
end
if nargin <15|| isempty(qtminvar)==1
    qtminvar = 3.14;
end
if nargin <16|| isempty(qtmaxvar)==1
    qtmaxvar = 314;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
mdim = size(unw,1);
fid  = fopen(outfile,'w');
%
input = [];
iter_num = 0;
for its = log2(maxblocksize):-1:log2(minblocksize)
    blocksize     = 2^(its);
    pha_qtoutput  = sparse(zeros(mdim, mdim)) ;
    unw(isnan(unw)) = 0.; 
    tunw = unw(unw~=0);
    %
    if size(tunw,1) < 1
        return
    end
    %
    %
    iter_num = iter_num + 1;
    % fractor = fractor / iter_num;
    disp([' Starting downsampling with a blocksize of ',num2str(blocksize),' with a fractor of ',num2str(fractor)])
    output        = do_quadtree(unw,pha_qtoutput,qtminvar,qtmaxvar,...
                     blocksize,blocksize,fractor, 1, 1, null_file);
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pha_qtc  = process_quadtree(output,unw,mdim,minblocksize,fractor,qti_file,0);
    %
    npoints  = numel(pha_qtc(:,1));  % the number points in the No: its loop
    tinput   = zeros(npoints,7);     %
    index_1  = find(pha_qtc(:,1) > info.width);
    index_2  = find(pha_qtc(:,2) > info.file_length);
    %
    pha_qtc([index_1;index_2],:)  = [];
    tinput([index_1;index_2],:)   = [];
    tinput(:,1) = pha_qtc(:,1).*info.x_step+info.x_first;
    tinput(:,2) = pha_qtc(:,2).*info.y_step+info.y_first;%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist(incfile,'file')~=0 && strcmpi(incfile,'NULL')==0
        %inc                  = sim_2dinterp(incfile,tinput(:,1),tinput(:,2),[],inunit);
        inc                  = sim_roi2profile(incfile,'float',tinput(:,1),tinput(:,2),1,1);
        inc(isnan(inc))      = 0;
        flag1                = abs(isnan(inc)-1);
        flag2                = inc~=0;
        flag                 = flag1.*flag2;
        meaninc              = mean(inc(flag==1));
        inc(isnan(inc))      = meaninc;
        inc(abs(inc)< 0.0001)= meaninc;
        inc(inc<=meaninc-10) = meaninc;
        inc(inc>meaninc+10)  = meaninc;
    else
        inc  = info.incidence;
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist(azifile,'file')~=0 && strcmpi(azifile,'NULL')==0
        azi                  = sim_roi2profile(azifile,'float',tinput(:,1),tinput(:,2),1,1);
        flag1                = abs(isnan(azi)-1);
        flag2                = azi~=0;
        flag                 = flag1.*flag2;
        meanazi              = mean(azi(flag==1));
        azi(isnan(azi))      = meanazi;
        azi(azi<=meanazi-10) = meanazi;
        azi(azi>meanazi+10)  = meanazi;
        % azi                  = azi-90;
        disp([ 'ps_dsm: mean azimuth ' num2str(meanazi)])
    else
        azi  = info.heading_deg;
    end
    %
    disp('+++++++++++++++++++++++++++++++++++++++++++++++++')
    disp([' sim_rquads: outputunit: ',num2str(outputunit)])
    disp(['             the input data are in ',dsminfo.obsmodel])
    disp('+++++++++++++++++++++++++++++++++++++++++++++++++')
    %
    if strcmpi(datatype,'displacements')
        losfactor = 1;
    else
        losfactor = wavelength/(-4*3.14159265);
    end
    switch upper(dsminfo.obsmodel)
        case 'PHASE'
            %
            tinput(:,3)  =  pha_qtc(:,3).*losfactor .* outputunit;
            tinput(:,4)  =  -1.*cosd(azi).*sind(inc);
            tinput(:,5)  =      sind(azi).*sind(inc);
            tinput(:,6)  =                 cosd(inc);
            %
        case 'AZI'
            tinput(:,3)  =  pha_qtc(:,3).* losfactor.*outputunit;%.*wavelength./(-4*3.14159265);
            tinput(:,4)  =  sind(azi);
            tinput(:,5)  =  cosd(azi);
            tinput(:,6)  =  0;
        case 'AZIMUTH'
            tinput(:,3)  =  pha_qtc(:,3).* losfactor .* outputunit;%.*wavelength./(-4*3.14159265);
            tinput(:,4)  =  sind(azi);
            tinput(:,5)  =  cosd(azi);
            tinput(:,6)  =  0;   
        case 'RNG' 
            % for offsets in range
            tinput(:,3)  =  pha_qtc(:,3).* losfactor .*outputunit;%.*wavelength./(-4*3.14159265);
            %
            tinput(:,4)  =  -1.*cosd(azi).*sind(inc);
            tinput(:,5)  =      sind(azi).*sind(inc);
            tinput(:,6)  =      cosd(inc);
        case 'RANGE' 
            % for offsets in range
            tinput(:,3)  =  pha_qtc(:,3).* losfactor .* outputunit;
            tinput(:,4)  =  -1.*cosd(azi).*sind(inc);
            tinput(:,5)  =      sind(azi).*sind(inc);
            tinput(:,6)  =      cosd(inc);
            %
        otherwise
            disp(' ERROR: please give a reasonable data direction: range of azimuth.')
            return
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Modified by Feng, W.P,2011-04-21
    % lower(info.projection) Modified by Feng W.P, 2010-04-22
    %
    if isempty(strfind(lower(info.projection),'utm'))==0
        if isempty(strfind(lower(info.x_unit(1)),'k'))==1
            tinput(:,1) = tinput(:,1)./1000;
        end
        if isempty(strfind(lower(info.y_unit(1)),'k'))==1
            tinput(:,2) = tinput(:,2)./1000;
        end
    else
        %
        [x0, y0]    = deg2utm(tinput(:,2),tinput(:,1),UTMZONE);
        utmx = x0./1000;
        utmy = y0./1000;
        %
        if numel(utmy(utmy<100)) > 0
            disp(tinput)
            disp(UTMZONE)
        end
         tinput(:,1) = utmx;
         tinput(:,2) = utmy;
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ns     = numel(input)/7;   %
    input  = [input;tinput];   %
    ne     = numel(input)/7;   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate the Resulotion of the observation
    %
    whichnon     = cell(size(fpara,1),1);
    %
    G = nan;
    while sum(isnan(G(:))) > 0
        %
        rakes        = sim_calrake(fpara,0.000001);
        rakecons     = [rakes(:)  rakes(:)];
        disp([' sim_rquads: given rakes ',num2str(rakecons(1)),' and ',num2str(rakecons(2))])
        sdim             = size(rakecons);
        mrakecons        = zeros(sdim(1),3);
        mrakecons(:,2:3) = rakecons;
        mrakecons(:,1)   = 1;
        rakecons         = mrakecons;
        %
        dampingfactor    = 1.0;
        % 
        [G,tmp_a,tmp_lap,tmp_a,tmp_a,tmp_a,lap] = sim_fpara4G(fpara,subxsize,subysize,flen,fwid,fwid*0.,input,0,0.5,whichnon);
        input(:,1)   = input(:,1) + rand(1)*0.01;
        input(:,2)   = input(:,2) + rand(1)*0.01;
        %
    end
    %
    numf         = size(G,2);
    L            = zeros(numf);
    norl         = 0;
    %
    for nj = 1:size(fpara,1)
        cnorl = norl+1;
        tLap  = lap{nj};
        nsize = size(tLap,1);
        norl  = norl+nsize*2;
        L(cnorl:norl,cnorl:norl) = lamd(1).*[tLap tLap.*0; tLap*.0 tLap];
    end
    %
    GG = [G;L];
    %
    N  = GG*((GG'*GG)\GG');
    dr = diag(N);           % the diagonal of N is above preset threshold
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Log info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp([' >> Now G size: ' num2str(size(G,1)) ' and ' num2str(size(G,2)), ' at ',num2str(iter_num)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dr = dr(ns+1:ne);       % subtract for current points in the loop
    % 
    if isinv == 1
        noindex = find(dr <= threshold);
        yeindex = find(dr >  threshold);
    else
        noindex = find(dr >= threshold);
        yeindex = find(dr <  threshold);
    end
    %
    if its ~= log2(minblocksize)
        input(noindex+ns,:) = [];
    end
    isok  = unw.*0;
    %
    if numel(noindex) > 0
        %
        for np = 1:numel(noindex)
            ni  = noindex(np);
            isok(pha_qtc(ni,2)-pha_qtc(ni,4)/2+0.5:...
                 pha_qtc(ni,2)+pha_qtc(ni,4)/2-0.5,...
                 pha_qtc(ni,1)-pha_qtc(ni,4)/2+0.5:...
                 pha_qtc(ni,1)+pha_qtc(ni,4)/2-0.5) = 1;
        end
    end
    %
    % For the last step we don't need remove the points which's value is
    % below the threshold 
    %
    if its == log2(minblocksize)
        yeindex = [yeindex(:);noindex(:)];
    end
    %
    %
    if numel(yeindex)>0
        %
        for ni=1:numel(yeindex)
            x1 = (pha_qtc(yeindex(ni),1) - (pha_qtc(yeindex(ni),4)/2)-0.5)*x_grid+x_ref ;
            x2 = (pha_qtc(yeindex(ni),1) + (pha_qtc(yeindex(ni),4)/2)-0.5)*x_grid+x_ref ;
            y1 = (pha_qtc(yeindex(ni),2) - (pha_qtc(yeindex(ni),4)/2)-0.5)*y_grid+y_ref ;
            y2 = (pha_qtc(yeindex(ni),2) + (pha_qtc(yeindex(ni),4)/2)-0.5)*y_grid+y_ref ;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(strfind(lower(info.projection),'utm'))==0
                if isempty(strfind(lower(info.x_unit(1)),'k'))==1
                    x1 = x1./1000;
                    x2 = x2./1000;
                end
                if isempty(strfind(lower(info.y_unit(1)),'k'))==1
                    y1 = y1./1000;
                    y2 = y2./1000;
                end
                if isempty(strfind(OUTPROJ,'UTM'))==1
                    [y1,x1] = utm2deg(x1.*1000,y1.*1000,UTMZONE);
                    [y2,x2] = utm2deg(x2.*1000,y2.*1000,UTMZONE);
                end
            else
                if isempty(strfind(OUTPROJ,'UTM')) == 0
                    [x0, y0] = deg2utm(y1,x1,UTMZONE);
                    x1    = x0./1000;
                    y1    = y0./1000;
                    [x0, y0] = deg2utm(y2,x2,UTMZONE);
                    x2    = x0./1000;
                    y2    = y0./1000;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(fid,'%s\n','>');
            fprintf(fid,'%10.8f %10.8f\n',x1,y1);
            fprintf(fid,'%10.8f %10.8f\n',x2,y1);
            fprintf(fid,'%10.8f %10.8f\n',x2,y2);
            fprintf(fid,'%10.8f %10.8f\n',x1,y2);
            fprintf(fid,'%10.8f %10.8f\n',x1,y1);
        end
        %
    end
    unw  = unw.*isok;
end
fclose(fid);
disp('FWP Good ending');
input(:,7) = input(:,7).*0+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
