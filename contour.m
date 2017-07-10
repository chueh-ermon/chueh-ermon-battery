% BMS contour plotting
% Peter Attia and Michael Chen
% 2017-07-07
function [contours] = contour(master_cycle, DQ, charge_time, ...
    time_evol, master_capacity, CA_array, cyc_array, last_time)

close all
clear all

Q1=5:5:80;
CC1=3:0.2:6;
time_vector =[10];

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

% for i=1:length(time_vector)
%     subplot(2,length(time_vector),i), hold on, box on
%     xlabel('CC1'),%ylabel('Q1 (%)')
%     title(['Time to 80% = ' num2str(time_vector(i)) ' minutes'])
% end
time_vector(i) == 10
        figure(1)
        hold on
        Q1=0.5:0.1:79.5;
        CC1=1:0.02:6;
        [X,Y] = meshgrid(CC1,Q1);
        CC2 = [(time_vector(i) - (Y./100).*(60./X))./(60.*(0.8-(Y./100)))].^(-1);
        v = [1 1.5 2 2.5 3 3.25 3.5 3.75 3.8 4 4.2 4.25 4.5 4.6 4.65 4.75 4.775 4.8 4.825 4.85 5 5.25 5.5 5.75 6];
        contour(X,Y,CC2,v,'LineWidth',2,'ShowText','on')
        xlabel('CC1'),ylabel('Q1 (%)')




% Manually determined degradation values in Excel. The list of policies and
% the list of degradation values should be programmatically generated

list = [10	1	4.00	6
10	2	10.00	6
10	2	6.67	5.5
10	2	2.22	5
10	3.6	30.00	6
10	3.6	22.11	5.5
10	3.6	8.57	5
10	3.6	2.40	4.85
10	4	40.00	6
10	4	31.11	5.5
10	4	13.33	5
10	4	3.92	4.85
10	4.4	55.00	6
10	4.4	46.67	5.5
10	4.4	24.44	5
10	4.4	8.15	4.85
10	4.65	68.89	6
10	4.65	44.29	5
10	4.65	19.38	4.85
10	4.8	80.00	0
10	4.8	80.00	0
10	4.8	80.00	0
10	4.9	27.22	4.75
10	4.9	61.25	4.5
10	4.9	69.10	4.25
10	5.2	9.63	4.75
10	5.2	37.14	4.5
10	5.2	50.18	4.25
10	5.2	57.78	4
10	5.2	66.27	3.5
10	5.2	70.91	3
10	5.6	5.49	4.75
10	5.6	25.45	4.5
10	5.6	38.02	4.25
10	5.6	46.67	4
10	5.6	57.78	3.5
10	5.6	64.62	3
10	6	4.00	4.75
10	6	20.00	4.5
10	6	31.43	4.25
10	6	40.00	4
10	6	52.00	3.5
10	6	60.00	3];

colormap jet;

% scalefactor = 1e6; % Factor to scale 

% maxvalue = max(list(:,5))*scalefactor;


for i = 1:length(list(:,1))
%     if list(i,1) == 10
        if list(i,3) == 80
            figure(1)
            scatter(list(i,2),list(i,3),'rsquare','SizeData',250,'LineWidth',5)
        else
            figure(1)
            scatter(list(i,2),list(i,3),'ro','SizeData',250,'LineWidth',5)
        end
        
        
        if list(i,3) == 80
            figure(2)
            scatter(list(i,2),list(i,4),'rsquare','SizeData',250,'LineWidth',5)
        else
            figure(2)
            scatter(list(i,2),list(i,4),'ro','SizeData',250,'LineWidth',5)
        end
%    
end

%% Save images
% saveas(gcf,'contour.png')
% saveas(gcf,'contour.fig')