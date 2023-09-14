function [split,mn]=split_test(block_array, minvar,...
    maxvar, mindim, maxdim, fraction)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
    

% function [split,mean]=split_test(block_array, minvar,
%   maxvar, mindim, maxdim, fraction)
%
% A function called by do_quadtree which calculates the variance of
% the datapoints within a block of data, and returns a value of
% 0 (don't split the block), 1 (split the block), or 2 (ignore the
% block) depending on whether the variance is within set variance
% thresholds, or whether it has a large proportion of non-zero
% elements.
%
% And because it calculates the mean, it'll return that too.
% gf
%
% modified to include test for maximum block size
% tjw 18-nov-2002

% let's see what we're working with here...
% ...find dimensions of the input block array

m=numel(block_array(1,:)) ;

% calculate proportion of non-zero elements
nz=nnz(block_array) ;
% if block is too big recommend a split
if (m > maxdim)
    split=1;
    mn=0;
    % check for proportion of non-zero elements - if there are
    % none, don't split the block and return a zero mean
    
elseif (nz==0)
    
    split=2 ;
    mn=0 ;
    
    % if less than the threshold fraction are non-zero, and the block is not
    % minimum size, recommend a split
    
elseif ((nz/(m^2))<fraction) && (m>mindim)
    split=1 ;
    mn=0 ;
    % if less than the minimum fraction are non-zero, and the block is minimum
    % size, ignore it
elseif ((nz/(m^2))<fraction) && (m<=mindim)
    split=2 ;
    mn=0 ;
    % if none of these, carry on with the variance test
    
else
    % extract non-zero elements of the input data
    nzs=nonzeros(block_array) ;
    % calculate mean of the non-zero elements
    mn=mean(nzs) ;
    % calculate variance of the non-zero elements
    variance=var(nzs) ;
    % check that the variance is not greater than the specified
    % minimum - if it is, then set the split variable to 1, if
    % not, then set it to zero if its variance is less than
    % the specified maximum, or 2 if it isn't.
    if (variance>=minvar) && (m>mindim)
        split=1 ;
        %
    else
        %
        if (variance>=maxvar) && (m>mindim)
            split=2;
        else
            split=0 ;
        end
    end
    
end
