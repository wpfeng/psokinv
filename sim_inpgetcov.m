function sim_inpgetcov(inpfile,unwfile,outinpfile,patchsize)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% [outp,outstd] = sim_roi2profile(file,datatype,x,y,axstep,aystep)
if nargin < 3
    outinpfile = inpfile;
end
if nargin < 4
    patchsize = 4;
end
%
inpdata       = sim_inputdata(inpfile);
%
[~,outstd]    = sim_roi2profile(unwfile,'float',inpdata(:,1),inpdata(:,2),patchsize,patchsize);
info          = sim_roirsc([unwfile,'.rsc']);
%
inpdata(:,7)  = outstd.*info.wavelength./(4*pi);
%
sim_input2outfile(inpdata,outinpfile);
