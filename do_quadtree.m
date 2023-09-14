function output=do_quadtree(input, output, minvar, maxvar,...
                            mindim, maxdim, fraction, start_row, start_col, null_filename)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
    

% function output=do_quadtree(input, output, minvar, maxvar,
%   mindim, maxdim, fraction, start_row, start_col, null_filename)
%
% This routine performs a quadtree decomposition of an image,
% calculating the variance of the image, and subdividing it
% into 4 quadrants if the variance is above a stated threshold.
% The function calls itself recursively until the whole image is
% covered by subdivided regions which either have below-threshold
% variances, or cannot be divided any more (i.e. they have an odd
% number of rows and columns).
%
% The inputs for this function are:
%
% input         - a (m x m) image matrix, where m is an even
%                 number
%
% output        - a (m x m) output matrix, which can be full or
%                 sparse
%
% minvar        - a value of variance above which the image block
%                 will be subdivided
%
% maxvar        - a value of variance above which the image block
%                 will be nulled (thus eliminating steep gradients
%                 such as those seen in noisy areas or in crossing
%                 the fault)
%
% mindim        - minimum dimension of an image block
%
% maxdim        - maximum dimension of an image block
%
% fraction      - proportion of non-zero elements required in a
%                 block
%
% start_row     - the position of the top left point of the input
% start_col       matrix (recommended that you first call the
%                 function with both set to 1)
%
% null_filename - the name of the null output file
%
%
% gjf, 9/5/01
% modified to include maximum variance 25/10/01
% modified to include variable fractions 21/11/01
% modified to allow named null files 28/11/01
% modified to remove the need for qtc files 17/12/01
% modified to include maximum block size 18/11/02 (tjw)
%
% genius in action (TM)
%

% count the columns/rows
%
m = numel(input(1,:));
% check variance, by calling the split_block function
[split,mn] = split_test(input, minvar, maxvar, mindim, maxdim, fraction);
% if block is indivisible, or of the minimum dimensions, or if
% the variance is within the threshold set, write to output
%
%
if (split==0)
    output(start_row:start_row+m-1,...
        start_col:start_col+m-1) = zeros(m) ;
    output(start_row, start_col) = m ;
    % if the variance is above the allowed threshold,, divide the image
    % into 4 and call the function again for each, modifying the input
    % dataset and start position accordingly
elseif (split==1)
    % procedure: first, create a new matrix, a subset of the input
    % (in this case the upper left quadrant)
    newinput = input(1:(m/2),1:1:(m/2)) ;
    % feed this new matrix back into the do_quadtree function,
    % modifying the variables start_row and start_col if necessary,
    % to give the 'absolute' position in the output matrix
    %disp(output);
    output = do_quadtree(newinput, output, minvar, maxvar, ...
        mindim, maxdim, fraction, start_row,start_col,...
        null_filename) ;
    
    % and now, do the same for the lower left quadrant...
    newinput = input(1+(m/2):m,1:(m/2)) ;
    output   = do_quadtree(newinput, output, minvar, maxvar, ...
        mindim, maxdim, fraction, (start_row+(m/2)),...
        start_col,null_filename) ;
    % and the upper right quadrant...
    newinput = input(1:(m/2),1+(m/2):m) ;
    output   = do_quadtree(newinput, output, minvar, maxvar, ...
        mindim, maxdim, fraction, start_row,(start_col+(m/2)),...
        null_filename) ;
    % and, finally, the lower right quadrant...
    newinput  = input(1+(m/2):m,1+(m/2):m) ;
    output    = do_quadtree(newinput, output, minvar, maxvar, ...
        mindim, maxdim, fraction, (start_row+(m/2)),(start_col+(m/2)),...
        null_filename) ;
    % finally, deal with the null data
elseif (split==2)
    output(start_row:start_row+m-1,...
        start_col:start_col+m-1) = zeros(m) ;
    output(start_row, start_col) = m ;
end
