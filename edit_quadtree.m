function decomp=edit_quadtree(decomp,editfile,imsize)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************

% Allows manual editing of quadtree decompositions to eliminate
% annoying patches of noise.
%
% gjf, 14/12/01
%
% genius in action (TM)

% load data

edit_coords=load(editfile) ;

% loop through entries in 'editfile' and correct the decomp matrix

for i=1:numel(edit_coords(:,1))
    
    decomp(edit_coords(i,1):(edit_coords(i,1)+edit_coords(i,3)-1),...
        edit_coords(i,2):(edit_coords(i,2)+edit_coords(i,3)-1))=...
        zeros(edit_coords(i,3)) ;
    
    decomp(edit_coords(i,1),edit_coords(i,2))=edit_coords(i,3) ;
    
end

