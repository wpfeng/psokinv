function psokinv = psokinv_psokinv_from_inp2initoksar(psokinv)
%
% Part of UI version for PSOKINV
% Created by FWP, @ BJ, 2010
% 
inp = psokinv.inps;
%
if ischar(inp)==0
    if (isempty(psokinv.inpids)==0 && exist(inp{psokinv.inpids},'file')~=0)
        data = sim_inputdata(inp{psokinv.inpids});
        x = [mean(data(:,1)),min(data(:,1)),max(data(:,1))];
        y = [mean(data(:,2)),min(data(:,2)),max(data(:,2))];
    else
        x = [0.5,0,99];
        y = [0.5,0,1];
    end
else
    x = [0.5,0,99];
    y = [0.5,0,1];
end
%
strike = [90,0.1,180];
dip    = [45,0.5,170];
depth  = [2,0.01,20];
length = [2,0.1,20];
width  = [2,0.1,20];
rakes  = [0,-45,45,1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
psokinv.rakes(psokinv.faultid,:)          = rakes;
psokinv.faultintpara(psokinv.faultid,1,:) = x;
psokinv.faultintpara(psokinv.faultid,2,:) = y;
psokinv.faultintpara(psokinv.faultid,3,:) = strike;
psokinv.faultintpara(psokinv.faultid,4,:) = dip;
psokinv.faultintpara(psokinv.faultid,5,:) = depth;
psokinv.faultintpara(psokinv.faultid,6,:) = width;
psokinv.faultintpara(psokinv.faultid,7,:) = length;
psokinv.isinv(psokinv.faultid,:)          = 1;
