function fpara = sim_fixmodelconvstr(fpara)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
for ni = 1:numel(fpara(:,1))
    if fpara(ni,3) > 180 || fpara(ni,3) < 0
        if fpara(ni,3) < 0
            fpara(ni,3) = 360+fpara(ni,3);
        end
        fpara(ni,3) = fpara(ni,3) -180;
        fpara(ni,4) = 180 - fpara(ni,4);
    end
end
