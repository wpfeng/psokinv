function [pha_utm_out hdinfo] = sim_quadsub(unwfile,output_path,...
                                          qtblocksize,qtmaxblocksize,qtminvar,qtmaxvar,...
                                           qtfrac,remove_near_field,isdisp,startrow,startcol,outname,zone,smethod)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Created by Feng, Wanpeng, IGP/CEA,2009/06
% working to extract data points for UNW file.
% Modified by Feng, W.P, 2011-04-25
% add datatype and zone
%
global datatype OUTPROJ UTMZONE ISKM CPROJ
%
ISKM = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<1 || isempty(unwfile)==1 || exist(unwfile,'file')==0
    disp('Please input a right UNW file!');
    pha_utm_out = [];
    return
end
if nargin<2 || isempty(output_path)==1
    output_path = '.';
end
if nargin<10|| isempty(startrow)==1
    startrow = 1;
end
if nargin<11 || isempty(startcol)==1
    startcol = 1;
end
if exist(output_path,'dir')==0
    mkdir(output_path);
end
%zone
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pha_input_path,reg_names,b] = fileparts(unwfile);
reg_names  = [reg_names,b];
info       = sim_roirsc([unwfile,'.rsc']);
CPROJ      = info.projection;
%
if isempty(OUTPROJ)
    if isempty(strcmpi(CPROJ,'L'))
        OUTPROJ = 'UTM';
    else
        OUTPROJ = 'LL';
    end
end
%
if isempty(strfind(lower(info.x_unit),'k'))==0
    ISKM = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generic output file details (will be prefixed by
%
decomp_output_file     = '.qtd.dat' ;
coordinate_output_file = '.qtc.dat' ;
utm_output_file        = '.utm.dat' ;
null_output_file       = '.null.dat' ;
image_output_file      = '.qti.r4' ;
weights_output_file    = '.wht.dat' ;
box_output_file        = '.quad.box.xy' ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delete(fullfile(output_path,['*_',decomp_output_file]));
delete(fullfile(output_path,[ '*_' coordinate_output_file ]));
delete(fullfile(output_path,[ '*_' utm_output_file ]));
delete(fullfile(output_path,[ '*_' null_output_file]));
delete(fullfile(output_path,[ '*_' image_output_file]));
delete(fullfile(output_path,[ '*_' weights_output_file]));
delete(fullfile(output_path,[ '*_' box_output_file]));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set timer and counters to zero
tim   = 0 ;
count = 0 ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up the master loop
% load in phase gradient data from 4-byte real binary file
disp(['Loading data file ' fullfile(pha_input_path,...
    reg_names)]) ;
[indata,cx,cy,hdinfo] = sim_defreadroi(unwfile,'float',1);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_ref      = hdinfo.x_first;
y_ref      = hdinfo.y_first;
x_dim      = hdinfo.file_length;
y_dim      = hdinfo.width;
x_grid     = hdinfo.x_step;
y_grid     = hdinfo.y_step;
wavelength = hdinfo.wavelength;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dim2x = fix(log2(x_dim));
dim2y = fix(log2(y_dim));
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
tmp(1:hdinfo.file_length,1:hdinfo.width)   = indata;
indata                                     = tmp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic ;
t = toc ;
disp(['...data file loaded in ' num2str(t) ' seconds']) ;
tim = tim+t ;
% set up the output...
pha_qtoutput    = sparse(zeros(y_dim, x_dim)) ;
qtc_file        = fullfile(output_path,['pha_',char(reg_names),...
    coordinate_output_file]) ;
null_file       = fullfile(output_path,['pha_',char(reg_names),...
    null_output_file]) ;
decomp_file     = fullfile(output_path,['pha_',char(reg_names),...
    decomp_output_file]) ;
utm_file        = fullfile(output_path,['pha_',char(reg_names),...
    utm_output_file]) ;
qti_file        = fullfile(output_path,['pha_',char(reg_names),...
    image_output_file]) ;
edit_file       = fullfile(output_path,['edit_pha_',char(reg_names),...
    decomp_output_file]) ;
weights_file    = fullfile(output_path,['pha_',char(reg_names),...
    weights_output_file]) ;
box_coords_file_LL = fullfile(output_path,[outname,...
    '_',smethod,'_LL_',MCM_rmspace(UTMZONE),box_output_file]) ;
%
box_coords_file_UTM = fullfile(output_path,[outname,...
    '_',smethod,'_UTM_',MCM_rmspace(UTMZONE),box_output_file]);
%
% disp(box_coords_file_LL);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ...and run the quadtree decomposition
disp('sim_quadsub: Beginning quadtree decomposition...') ;
tic ;
%qtmaxvar
pha_qtdecomped = do_quadtree(indata,pha_qtoutput,qtminvar,...
    qtmaxvar,qtblocksize,qtmaxblocksize,qtfrac,startrow,...
    startcol,null_file);
%
%
t = toc ;
disp(['sim_quadsub: ...quadtree completed in ' num2str(t) ' seconds']) ;
tim = tim+t ;
% save the decomposition matrix
save qt.dat pha_qtdecomped ;
movefile('qt.dat',decomp_file,'f') ;
% modify the input dataset to zero the null blocks, if desired
if (remove_near_field==1)&&(exist(null_file,'file')==1)
    null_set=load(null_file) ;
    for j=1:numel(null_set(:,1))
        indata(null_set(j,1):(null_set(j,1)+null_set(j,3)-1),...
            null_set(j,2):(null_set(j,2)+null_set(j,3)-1))...
            =zeros(null_set(j,3)) ;
    end
    clear null_set ;
end

% edit the quadtree decomposition if desired
if (exist(edit_file,'file')==1)
    disp('sim_quadsub: Editing decomposed image...') ;
    pha_qtdecomped = edit_quadtree(pha_qtdecomped,edit_file,x_dim) ;
end
% process the quadtree data - create coordinates and an image file
disp('sim_quadsub: Generating image file and coordinates...') ;
tic ;
pha_qtc = process_quadtree(pha_qtdecomped,indata,x_dim,qtblocksize,...
    qtfrac,qti_file,isdisp) ;
%
t = toc ;
%
tim = tim+t ;

% correct the coordinates to utm km, if there are any, and export them
if (isempty(pha_qtc)==0)
    %
    pha_utm_out(:,1) = ((pha_qtc(:,1)*x_grid)+x_ref) ;
    pha_utm_out(:,2) = ((pha_qtc(:,2)*y_grid)+y_ref) ;
    pha_utm_out(:,3) = pha_qtc(:,3);
    %
    % updated by Feng, Wanpeng, @NRCan, 2016-02-23
    % unite conversion should be carried out before final ouputs
    %
    %     switch upper(datatype)
    %         case 'PHASE'
    %             pha_utm_out(:,3) =   pha_qtc(:,3)*wavelength/(-4*pi);
    %         otherwise
    %             pha_utm_out(:,3) =   pha_qtc(:,3);%*wavelength/(-4*pi);
    %     end
    %
    points           = numel(pha_utm_out)/3 ;
    disp(['sim_quadsub: ' num2str(points) ' datapoints generated']) ;
    count           = count+points ;
    save qtc.dat pha_qtc -ascii ;
    %
    movefile('qtc.dat',qtc_file,'f');
    % write out the box area weights and box coordinates
    box_id_ll     = fopen(box_coords_file_LL,'w') ;
    box_id_utm    = fopen(box_coords_file_UTM,'w') ;
    %
    weights_id = fopen(weights_file,'w') ;
    for j=1:points
        %
        x1=(pha_qtc(j,1)-(pha_qtc(j,4)/2)-0.5)*x_grid+x_ref ;
        x2=(pha_qtc(j,1)+(pha_qtc(j,4)/2)-0.5)*x_grid+x_ref ;
        y1=(pha_qtc(j,2)-(pha_qtc(j,4)/2)-0.5)*y_grid+y_ref ;
        y2=(pha_qtc(j,2)+(pha_qtc(j,4)/2)-0.5)*y_grid+y_ref ;
        weight = pha_qtc(j,4)^2 ;
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Modified by Feng, W.P, @ BJ, 20110505
        % -> now support to output the dataset with LL projection...
        %
        if isempty(strfind(lower(hdinfo.projection),'utm'))==0
            if isempty(strfind(lower(hdinfo.x_unit(1)),'k'))==1
                tx1 = x1./1000;
                tx2 = x2./1000;
            end
            if isempty(strfind(lower(hdinfo.x_unit(1)),'k'))==1
                ty1 = y1./1000;
                ty2 = y2./1000;
            end
            %
            utmx1 = tx1;
            utmx2 = tx2;
            utmy1 = ty1;
            utmy2 = ty2;
            %
            [lly1,llx1] = utm2deg(utmx1.*1000,utmy1.*1000,UTMZONE);
            [lly2,llx2] = utm2deg(utmx2.*1000,utmy2.*1000,UTMZONE);
            %
            
            %
        else
            %                if isempty(strfind(lower(OUTPROJ),'utm')) == 0
            %                   [x0,y0] = deg2utm(y1,x1,UTMZONE);
            %                   x1      = x0./1000;
            %                   y1      = y0./1000;
            %                   [x0,y0] = deg2utm(y2,x2,UTMZONE);
            %                   x2      = x0./1000;
            %                   y2      = y0./1000;
            %                end
            lly1 = y1;
            lly2 = y2;
            llx1 = x1;
            llx2 = x2;
            [x0,y0] = ll2utm(y1,x1,UTMZONE);
            utmx1   = x0/1000;
            utmy1   = y0/1000;
            [x0,y0] = ll2utm(y2,x2,UTMZONE);
            utmx2   = x0/1000;
            utmy2   = y0/1000;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(box_id_ll,'%18.10f %18.10f \n', llx1, lly1) ;
        fprintf(box_id_ll,'%18.10f %18.10f \n', llx1, lly2) ;
        fprintf(box_id_ll,'%18.10f %18.10f \n', llx2, lly2) ;
        fprintf(box_id_ll,'%18.10f %18.10f \n', llx2, lly1) ;
        fprintf(box_id_ll,'%18.10f %18.10f \n', llx1, lly1) ;
        fprintf(box_id_ll,'> \n') ;
        %
        fprintf(box_id_utm,'%18.10f %18.10f \n', utmx1, utmy1) ;
        fprintf(box_id_utm,'%18.10f %18.10f \n', utmx1, utmy2) ;
        fprintf(box_id_utm,'%18.10f %18.10f \n', utmx2, utmy2) ;
        fprintf(box_id_utm,'%18.10f %18.10f \n', utmx2, utmy1) ;
        fprintf(box_id_utm,'%18.10f %18.10f \n', utmx1, utmy1) ;
        fprintf(box_id_utm,'> \n') ;
        %
        fprintf(weights_id,'%15.5f \n', weight) ;
    end
    fclose(weights_id) ;
    fclose(box_id_ll) ;
    fclose(box_id_utm) ;
    %
    clear pha_qtc ;
    save utm.dat pha_utm_out -ascii ;
    movefile('utm.dat',utm_file,'f') ;
    %clear pha_utm_out ;
    
else
    disp('No datapoints generated') ;
    pha_utm_out =[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% and that should be it, I think

disp(' ') ;
disp(['unw_pha_quadtree found ' num2str(count) ' datapoints']) ;
disp(['Finished in ' num2str(tim) ' seconds!']) ;
disp(' ')
