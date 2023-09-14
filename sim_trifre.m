function trif = sim_trifre(matfile,thd)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
if nargin<2
    thd = 0.1;
end
trif      = [];
data      = load(matfile);
tristruct = data.tristruct;
mdip      = data.mdip;
outstd    = zeros(1,2);
%mdips     = zeros(1);
mstd      = zeros(1);
for ni=1:size(tristruct,2)
    plot(tristruct(ni).smest(:,3),tristruct(ni).smest(:,2),'*-b');
    hold on
    text(tristruct(ni).smest(end,3),tristruct(ni).smest(end,2),['DIP: ' num2str(data.mdip(ni))]);
    cindex         = find(abs(tristruct(ni).smest(:,3)-thd)==min(abs(tristruct(ni).smest(:,3)-thd)));
    outstd(ni,1)   = tristruct(ni).smest(cindex,2);
    outstd(ni,2)   = cindex;
    plot(tristruct(ni).smest(cindex,3),tristruct(ni).smest(cindex,2),'o-r');
    mstd(ni)       = tristruct(ni).smest(cindex,2);
end
mindex = find(outstd(:,1)==min(outstd(:,1)));
trif   = tristruct(mindex).mtrif{outstd(mindex,2)};
disp(['Now the model with the dip of ' num2str(data.mdip(mindex)) ' is better!']);
figure('Name','TRIF Model:');
sim_trifshow(trif,'syn');
%
figure('Name','RES2OBS');
plot(data.data(:,3),'-r','LineWidth',2.5);
hold on
plot(tristruct(end).osim{1},'-b');
%
icor = corr2(data.data(:,3),tristruct(end).osim{cindex});
istd = std(data.data(:,3)-tristruct(end).osim{cindex});
disp(['The Correlation: ' num2str(icor)]);
disp(['The Standard Deviation: ' num2str(istd)]);
%
figure('Name','DIP2STD');
plot(mdip(:),mstd,'o-b');
xlabel('Dip Angle (degree)');
ylabel('Standard Deviation (cm)');
