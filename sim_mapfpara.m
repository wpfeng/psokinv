function sim_mapfpara(fpara,model)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% Usage:
%    sim_mapfpara(fpara,model)
% Input:
%    fpara, the fault model(rec),N*10
%    model, detail requirement.
% Modification History:
%   2010-11-29, Feng, W.P, initial version
% 
switch model
    case 2
        sim_fig2d(fpara);
    case 3
        sim_fig3d(fpara);
    case 2.1
        p = sim_fpara2allcors(fpara);
        p = [p(1:4,:);p(1,:)];
        plot(p(:,1),p(:,2),'o-r');
end
