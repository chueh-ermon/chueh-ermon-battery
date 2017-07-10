% BMS contour
% Peter Attia
% 2017-06-15

close all
clear all

Q1=5:5:80;
CC1=3:0.2:6;
time_vector = [13 12 11 10]; %holds the possible times

% CC2 = ones(length(time_vector),length(CC1),length(Q1));
CC2 = ones(length(Q1),length(CC1),length(time_vector));

figure, set(gcf, 'units','normalized','outerposition',[0 0 1 1]) 

% for i=1:length(time_vector)
%     subplot(2,length(time_vector)/2,i), hold on, box on
%     xlabel('CC1'),ylabel('Q1 (%)')
%     title(['Time to 80% = ' num2str(time_vector(i))])
%     
%     [X,Y] = meshgrid(CC1,Q1);
%     CC2 = [(time_vector(i) - (Y./100).*(60./X))./(60.*(0.8-(Y./100)))].^(-1);
%     v =[3.8 4 4.2];
%     contour(X,Y,CC2,v,'LineWidth',2,'ShowText','on')
% end

for i=1:length(time_vector)
    subplot(2,length(time_vector)/2,i), hold on, box on
    xlabel('CC1'),ylabel('Q1 (%)')
    title(['Time to 80% = ' num2str(time_vector(i)) ' minutes'])
end

for i=1:length(time_vector)
    if time_vector(i) == 10
        subplot(2,length(time_vector)/2,4)
        Q1=0.5:0.1:79.5;
        CC1=3.6:0.02:6;
        [X,Y] = meshgrid(CC1,Q1);
        CC2 = [(time_vector(i) - (Y./100).*(60./X))./(60.*(0.8-(Y./100)))].^(-1);
        v = [3 3.5 4 4.5 4.75 4.8 4.85 5 5.5 6];
        contour(X,Y,CC2,v,'LineWidth',2,'ShowText','on')
    elseif time_vector(i) == 11
        subplot(2,length(time_vector)/2,3)
        Q1=0:0.02:80;
        CC1=4:0.02:6.2;
        [X,Y] = meshgrid(CC1,Q1);
        CC2 = 1./((time_vector(i) - ((Y./100).*(60./X)) )./ (60.*(0.8-(Y./100))));
        v = [3 3.5 3.8 4 4.2 4.5 4.8 5 5.5 6];
        contour(X,Y,CC2,v,'LineWidth',2,'ShowText','on')
    elseif time_vector(i) == 12
        subplot(2,length(time_vector)/2,2)
        Q1=5:1:79.5;
        CC1=3:0.01:6;
        [X,Y] = meshgrid(CC1,Q1);
        CC2 = [(time_vector(i) - (Y./100).*(60./X))./(60.*(0.8-(Y./100)))].^(-1);
        v = [3 3.5 3.8 4 4.2 4.5 4.8 5 5.5 6];
        contour(X,Y,CC2,v,'LineWidth',2,'ShowText','on')
        
    else
        subplot(2,length(time_vector)/2,1)
        Q1=0.05:0.05:79.5;
        CC1=3:0.01:4;
        [X,Y] = meshgrid(CC1,Q1);
        CC2 = 1./((time_vector(i) - ((Y./100).*(60./X)) )./ (60.*(0.8-(Y./100))));
        v = [3 3.5 3.8 4 4.2 4.5 4.8 5 5.5 6];
        contour(X,Y,CC2,v,'LineWidth',2,'ShowText','on')
        %y = 100.*(((time_vector(i)./60) - (0.8.*v(1))).*CC1)./(1-(CC1.*v(1)));
        %y = (5.*CC1.*(48.*v(1)-time_vector(i)))./(3.*(CC1-v(1)));
        %plot(CC1,y)
       


    end
        
end
% 
% % Manually determined degradation values in Excel. The list of policies and
% % the list of degradation values should be programmatically generated
% 
list = [10	6	45.45	3.8	0.1
10	5.5	53.92	3.8	0.1
10	5	69.44	3.8	0.1
10	6	40.00	4	0.1
10	5.5	48.89	4	0.1
10	5	66.67	4	0.1
10	4.8	80.00	0	0.1
10	6	33.33	4.2	0.1
10	5.5	42.31	4.2	0.1
10	5	62.50	4.2	0.1
11	6	28.18	3.8	0.1
11	5.5	33.43	3.8	0.1
11	5	43.06	3.8	0.1
11	4.5	66.43	3.8	0.1
11	6	20.00	4	0.1
11	5.5	24.44	4	0.1
11	5	33.33	4	0.1
11	4.5	60.00	4	0.1
11	4.36	80.00	0	0.1
11	6	10.00	4.2	0.1
11	5.5	12.69	4.2	0.1
11	5	18.75	4.2	0.1
11	4.5	45.00	4.2	0.1
12	6	10.91	3.8	0.1
12	5.5	12.94	3.8	0.1
12	5	16.67	3.8	0.1
12	4.5	25.71	3.8	0.1
12	4.2	42.00	3.8	0.1
12	4	80.00	0	0.1
12	3.2	12.80	4.2	0.1
12	3.6	24.00	4.2	0.1
12	3.8	38.00	4.2	0.1
13	3.2	12.44	3.8	0.1
13	3.4	19.83	3.8	0.1
13	3.6	42.00	3.8	0.1
13	3.2	26.67	4	0.1
13	3.4	37.78	4	0.1
13	3.6	60.00	4	1
13	3.7	80.00	0	0
13	3.2	35.20	4.2	0
13	3.4	46.75	4.2	0
13	3.6	66.00	4.2	0];

colormap jet;

% scalefactor = 1e6; % Factor to scale 

% maxvalue = max(list(:,5))*scalefactor;


for i = 1:length(list(:,1))
    if list(i,1) == 10
        subplot(2,length(time_vector)/2,4)
        if list(i,3) == 80
            scatter(list(i,2),list(i,3),'bsquare','SizeData',200,'LineWidth',5)
        else
            scatter(list(i,2),list(i,3),'ro','SizeData',200,'LineWidth',5)
        end
    elseif list(i,1) == 11
        subplot(2,length(time_vector)/2,3)
        if list(i,3) == 80
            scatter(list(i,2),list(i,3),'bsquare','SizeData',200,'LineWidth',5)
        else
            scatter(list(i,2),list(i,3),'ro','SizeData',200,'LineWidth',5)
        end
    elseif list(i,1) == 12
        subplot(2,length(time_vector)/2,2)
        if list(i,3) == 80
            scatter(list(i,2),list(i,3),'bsquare','SizeData',200,'LineWidth',5)
        else
            scatter(list(i,2),list(i,3),'ro','SizeData',200,'LineWidth',5)
        end
    else
        subplot(2,length(time_vector)/2,1)
        if list(i,3) == 80
            scatter(list(i,2),list(i,3),'bsquare','SizeData',200,'LineWidth',5)
        else
            scatter(list(i,2),list(i,3),'ro','SizeData',200,'LineWidth',5)
        end
%         caxis([0 maxvalue])
    end
end

%% Save images
saveas(gcf,'contour.png')
saveas(gcf,'contour.fig')