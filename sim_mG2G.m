function G = sim_mG2G(mG,mrakecons)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
% Created by Feng,Wanpeng,2011-03-30

for ni = 1:numel(mG);
    tmpG     = mG{ni};
    rakecons = mrakecons{ni};
    if ni==1
       if rakecons(ni,2)==rakecons(ni,3)
           bG = tmpG;
           aG = [];
       else
           aG = tmpG(:,1:end/2);
           bG = tmpG(:,end/2+1:end);
       end
    else
        if rakecons(ni,2)==rakecons(ni,3)
            aG = [aG,[]];
            bG = [bG,tmpG];
        else
            aG = [aG,tmpG(:,1:end/2)];
            bG = [bG,tmpG(:,end/2+1:end)];
        end
    end
end
G = [aG,bG];
