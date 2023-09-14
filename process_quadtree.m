function qtc=process_quadtree(decomp,indata,imsize,...
                    mindim,qtfrac,image_out,isdisp)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
    

% function qtc=process_quadtree(decomp,indata,imsize,...
%   mindim,qtfrac,image_out)
% Given a dataset corrected for nulls, this will create an
% image and generate a set of quadtree coordinates (the
% variable 'qtc') which can then be used for output.
% gjf, 14/12/01
% fixed so it actually works 11/03/02
% modified to allow output of box size 16/04/02
%
% genius in action (TM)

% set data counter to zero

count = 0 ;
qtc   = zeros(1,4);
% on with the show: extract data in blocks from the input
% data file...

for i=(log2(mindim)):(log2(imsize))
    
% first, extract the blocks of whatever size    
    [blockvals,rowes,columnes] = qtgetblk(indata,decomp,(2^i)) ;
% check that there are any blocks of that size
    m = numel(blockvals(1,1,:)) ;
    if ( m> 0)
% and if there are, calculate their means and set them
% equal to the whole block in the image output, and output
% their centre coordinates
        for j=1:m
            if ((nnz(blockvals(:,:,j)))/((2^i)^2))>=qtfrac
                %
                nzmean = mean(nonzeros(blockvals(:,:,j))) ;
                decomp_image(rowes(j):rowes(j)-1+2^i,...
                    columnes(j):columnes(j)-1+2^i) = nzmean ;                
                count = count+1 ;
                %
                % Modified by Feng W.P, mean value corresponding to the center
                %  
                qtc(count,1)= (columnes(j)+columnes(j)-1+2^i)/2; % (columnes(j)-1)+2^(i-1) ; %;%
                qtc(count,2)= (rowes(j)+rowes(j)-1+2^i)/2;       % (rowes(j)-1)+2^(i-1) ;    %      ;%
                %qtc(count,1) =  (columnes(j)-1)+2^(i-1) ; %;%
                %qtc(count,2) =  (rowes(j)-1)+2^(i-1) ;    %      ;%
                qtc(count,3) =  nzmean ;
                qtc(count,4) =  2^i ;
                %
            else
                
                decomp_image(rowes(j):rowes(j)-1+2^i,...
                    columnes(j):columnes(j)-1+2^i)=0 ;
            end
            
        end
        
    end
            
end    
% output the image in binary format
outfile = fopen(image_out,'w') ;
fwrite(outfile,decomp_image','real*4') ;
fclose(outfile) ;
if isdisp==1
   imagesc(decomp_image);
end
% the end

