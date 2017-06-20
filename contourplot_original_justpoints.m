% BMS contour
% Peter Attia
% 2017-06-15

close all

Q1=5:5:80;
CC1=3:0.5:10;
CC2=[3 3.6];
time = ones(length(CC2),length(CC1),length(Q1));
figure, set(gcf, 'units','normalized','outerposition',[0 0 1 1])
for i=1:length(CC2)
    subplot(1,length(CC2),i), hold on, box on
    xlabel('C1'),ylabel('SOC1 (%)')
    title(['C2 = ' num2str(CC2(i))])
    %axis([min(CC1) max(CC1) min(Q1) max(Q1)])
    
    [X,Y] = meshgrid(CC1,Q1);
    time = (60.*Y./X./100)+(60.*(80-Y)./CC2(i)./100);
    v = [13, 12, 11, 10, 9, 8];
    contour(X,Y,time,v,'LineWidth',2,'ShowText','on')
end

% Manually determined degradation values in Excel. The list of policies and
% the list of degradation values should be programmatically generated
list = [3.6	80	3.601	3.1279E-05
        4	80	4	3.8254E-05
        4.4	80	4.4	1.0923E-04
        4.8	80	4.8	2.6018E-04
        5.4	40	3.6	1.2798E-04
        5.4	50	3	1.6890E-04
        5.4	50	3.6	1.2336E-04
        5.4	60	3	2.2486E-04
        5.4	60	3.6	2.1632E-04
        5.4	70	3	2.1184E-04
        5.4	80	5.4	3.3856E-04
        6	30	3.6	1.4072E-04
        6	40	3	1.8642E-04
        6	40	3.6	2.2163E-04
        6	50	3	2.0858E-04
        6	50	3.6	2.4528E-04
        6	60	3	2.5727E-04
        7	30	3.6	2.5364E-04
        7	40	3	2.7135E-04
        7	40	3.6	2.9956E-04
        8	15	3.6	1.6029E-04
        8	25	3.6	2.7165E-04
        8	35	3.6	3.1434E-04];

colormap jet;

scalefactor = 1e6; % Factor to scale 

maxvalue = max(list(:,4))*scalefactor;


for i = 1:length(list(:,1))
    if list(i,3) == 3
        subplot(1, length(CC2), 1)
        %ax(2) = axes;
        scatter(list(i,1),list(i,2),'o','filled','CData',[0 0 0],'SizeData',200,'LineWidth',5)
    elseif list(i,3) == 3.6
        subplot(1, length(CC2), 2)
        scatter(list(i,1),list(i,2),'o','filled','CData',[0 0 0],'SizeData',200,'LineWidth',5)
    else
        subplot(1, length(CC2), 1)
        scatter(list(i,1),list(i,2),'square','filled','CData',[0 0 0],'SizeData',200,'LineWidth',5)
        caxis([0 maxvalue])
        subplot(1, length(CC2), 2)
        scatter(list(i,1),list(i,2),'square','filled','CData',[0 0 0],'SizeData',200,'LineWidth',5)
        caxis([0 maxvalue])
    end
end

%% Save images
saveas(gcf,'contour.png')
saveas(gcf,'contour.fig')