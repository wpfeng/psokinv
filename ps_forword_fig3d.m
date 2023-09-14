%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% ps_forword_fig3d
%
if isempty(fig3dID)||ishandle(fig3dID)==0
    fig3dID = figure('Name','Fig3D');
    if isempty(fig3dID)~=1
        ginfo.fig3dposition = get(fig3dID,'Position');
        cid = get(fig3dID,'CurrentAxes');
        if isempty(cid)~=1
            [ginfo.az,ginfo.el] = view(cid);
        end
    end
else
    ginfo.fig3dposition = get(fig3dID,'Position');
    cid = get(fig3dID,'CurrentAxes');
    if isempty(cid)~=1
        [ginfo.az,ginfo.el] = view(cid);
    end
    delete(fig3dID);
    fig3dID = figure('Name','Fig3D');
    if isempty(ginfo.fig3dposition)~=1
        set(fig3dID,'Position',ginfo.fig3dposition);
    end
end
if sum(Cfpara(:)) ~=0
    figure(fig3dID);
    sim_fig3d(Cfpara);
    view([ginfo.az,ginfo.el]);
end
