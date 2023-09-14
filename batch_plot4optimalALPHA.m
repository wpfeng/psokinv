%
%
% An example script
% plot for optimal alpha
% 
% writtend by W. Feng, @SYSU, Guangzhou, 2022/11/17
%
% to make sure that the targetDIP below has been estimated in test.out.
%
targetDIP = 50;
%
data = load('test.out');
%
cdata = data(data(:,1)==targetDIP,:);
%
%
plot(cdata(:,2),cdata(:,5)./max(cdata(:,5)),'o-g');
xlabel('Smoothing factors(alpha) for dip 50d')
ylabel('Variations of STD and Roughness')
hold on
plot(cdata(:,2),cdata(:,4)./max(cdata(:,4)),'o-b');
hold on

yyaxis right
plot(cdata(:,2),cdata(:,3),'-r','LineWidth',3.5);
set(gca,'YColor','red');
ylabel('Log-function for optimal Alpha')
legend('Normalized STD','Normalized Smoothness','OptimalAlpha');