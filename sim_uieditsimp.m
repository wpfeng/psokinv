function hid = sim_uieditsimp(oksarfile,figid)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%
%
% Plot oksar with GEO Coordinates...
% Developed by FWP, @ GU, 2013-03-22
% Re-shaped by Wanpeng Feng, @NRCan, 2016-11-14
%
%
if nargin < 2
    disp('sim_dispoksaringeo(oksarfile)');
    return
end
%
% Updated by Feng, W.P., @ EOS of NTU, Singapore
%
[tmp_a,tmp_b,bext] = fileparts(oksarfile);
switch upper(bext)
    case '.OKSAR'
        [fpara,zone] = sim_oksar2SIM(oksarfile);
        %
    case '.SIMP'
        [fpara,zone] = sim_simp2fpara(oksarfile);
end
%
%zone = sim_oksar2utm(oksarfile);
if isempty(zone)
    disp('SIM_DISPOKSARINGEO: No zone of UTM is returned...');
    return
end
% 
hid = [];
for ni = 1:numel(fpara(:,1))
    %
    [ix1,iy1,iz1] = sim_fpara2corners(fpara(ni,:),'ur');
    [ix2,iy2,iz2] = sim_fpara2corners(fpara(ni,:),'ul');
    [ix3,iy3,iz3] = sim_fpara2corners(fpara(ni,:),'ll');
    [ix4,iy4,iz4] = sim_fpara2corners(fpara(ni,:),'lr');
    %
    datapoly = [ix1,iy1;ix2,iy2;ix3,iy3;ix4,iy4;ix1,iy1];
    %
    ifpara        = sim_fpara2rand_UP(fpara(ni,:));
    [ixl,iyl,izl] = sim_fpara2corners(ifpara,'ur');
    [ixr,iyr,izr] = sim_fpara2corners(ifpara,'ul');
    topline       = [ixl,iyl;ixr,iyr];
    %
    [lat,lon]   = utm2deg(datapoly(:,1).*1000,datapoly(:,2).*1000,zone);
    [tlat,tlon] = utm2deg(topline(:,1).*1000, topline(:,2).*1000,zone);
    %
    h = imline(figid,tlon,tlat);
    p = wait(h);
    fpara(ni,:) = sim_2plltofault(p,zone);
    
end
%
sim_fpara2simp(fpara,oksarfile,zone);
