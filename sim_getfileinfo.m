function [idir,bname,postfix] = sim_getfileinfo(fnames)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%Purpose:
%      return the file's idir,basename,prefix and postfix
%Input:
%     fnames, the full file path name
%Output:
%     idir
%     bname
%     prefix
%     postfix
%Created in Glasgow University
%June 20 2009
sysinfo = computer;
if isempty(findstr(sysinfo,'PC'))~=1
   inidex = '\';
end
if isempty(findstr(sysinfo,'PC'))==1
   inidex = '/';
end
dirinds = findstr(fnames,inidex);
if isempty(dirinds)==1
   idir = '';
   fname= fnames;
else
   idir = fnames(1:dirinds(end)-1);
   fname= fnames(dirinds(end)+1:end);
end
fixinds = findstr(fname,'.');
if isempty(fixinds)==1
   bname   = fname;
   postfix = '';
else
   bname   = fname(1:fixinds(1)-1);
   postfix = fname(fixinds(1):end);
end
   
