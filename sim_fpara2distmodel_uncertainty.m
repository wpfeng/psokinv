function [mfpara,outresult] = sim_fpara2distmodel_uncertainty(inpfiles,outmat)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% +Purpuose:
%     fpara,  cell format for multiple sets faults,cell(m,1)
%     input,  observation N*7
%  rakecons,  initial value of rake angle, m*3
%        mC,  the cell for covariance matrix
%       mat,  the Covarance matrix of observations
%     alpha,  the smooth constant
% minmoment,
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by Feng, Wanpeng, 2011-03-30
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

eval(['load ' outmat ]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pause(0.1);
whos G
mfpara = cell(1);
%
fprintf('%s \n','<FixTrace Model> 2) Begin to invert the slip model...');
%

%
losd   = zeros(numel(input(:,1)),numel(inpfiles));
%whos losd
for ni = 1:numel(inpfiles)
   tinput     = sim_inputdata(inpfiles{ni});
   %whos tinput
   losd(:,ni) = tinput(:,3);
end
%
parfor ni = 1:numel(inpfiles)
    %
    slips = sim_lsq(G,losd(:,ni),L,alpha(ni),COV,algor,minmoment,LB,UB,input(:,7));
    osim  = G*slips;
    res   = input(:,3)-osim;
    roug  = abs(L*slips);
    roug  = sort(roug,'descend');
    outs  = fix(numel(roug)/2);
    roug  = roug(1:outs);
    outresult(ni,:) = [alpha(ni),std(res),sum(roug)/numel(roug)];
    nf    = numel(fr);
    nb    = numel(br);
    sslip = slips(1:end/2);
    dslip = slips(end/2+1:end);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tfpara= afpara;
    %     for nj = 1:numel(fpara)
    %         afpara      =[afpara;fpara{nj}];
    %     end
    %
    tfpara(:,8) = sslip.*cosd(fr) + dslip.*cosd(br);
    tfpara(:,9) = sslip.*sind(fr) + dslip.*sind(br);
    mfpara{ni}  = tfpara;
    %fprintf('%s \n','<FixTrace Model>    Begin to invert the slip model...');
    fprintf('%s %3d %s %7.4f %s\n','<FixTrace Model>    NO: ',ni,' (ALPHA:',alpha(ni),') it is ok now...');
end
fprintf('%s \n','<FixTrace Model> 3) Distributed-Slip model is ok. Please check them...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    
    
