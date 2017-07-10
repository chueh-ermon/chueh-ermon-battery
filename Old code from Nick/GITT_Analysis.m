function [ ResultData, V1, SOC, C_rate] = GITT_Analysis( data_list )
%This Function opens multiple csv battery result files
%
%Once the file has been read it will select the important data,
%This data will be analyzed and an array of results will be output for each
%entry.
% This is primarily for looking at results of Overpotential Tests 
close all
overpotential_total=[];
IR_total=[];
Cell_voltage=[];
overp_avg=[];

for i=1:length(data_list)
    %Change to Location of the folder containing csv Arbin result files
    %% Using Arbin produced
    filepath='C:/Users/Arbin/Desktop/Aged_GITT/';
    %% Using Auto Importer
    %filepath= 'C://Data/';
    %Convert to String
    str = strcat(filepath,string(data_list(i)));
    %Reads CSV file into full matrix
    str
    ResultData = csvread(str,1,1);
    %% For AArbin produced
    %Label major CSV columns
    Total_time=ResultData(:,1);
    Step_Time=ResultData(:,2);
    Step_Index=round(ResultData(:,3));
    Cycle_Index=ResultData(:,4);
    VoltageV=ResultData(:,5);
    Current=ResultData(:,6);
    Charge_CapacityAh=ResultData(:,7);
    Discharge_CapacityAh=ResultData(:,8);
    
    %Reads CSV file into full matrix
    ResultData = csvread(str,1,1);
    time = ResultData(:,1);
    steptime  = ResultData(:,2);
    stepindex = round(ResultData(:,3));
    cycleindex = ResultData(:,4);
    V=ResultData(:,5);
    
    % Find cycle indices
    GITT_Steps=[7, 16, 25, 34, 43, 52];
    current=[0.25, 0.5, 1, 2, 4, 8];
    i1 = find(stepindex == 7);
    i1a = i1(1); i1b = i1(end);
    t1 = time(i1a:i1b) - time(i1a); V1 = V(i1a:i1b);
    
    i2 = find(stepindex == 16);
    i2a = i2(1); i2b = i2(end);
    t2 = time(i2a:i2b) - time(i2a); V2 = V(i2a:i2b);
    
    i3 = find(stepindex == 25);
    i3a = i3(1); i3b = i3(end);
    t3 = time(i3a:i3b) - time(i3a); V3 = V(i3a:i3b);
    
    i4 = find(stepindex == 34);
    i4a = i4(1); i4b = i4(end);
    t4 = time(i4a:i4b) - time(i4a); V4 = V(i4a:i4b);
    
    i5 = find(stepindex == 43);
    i5a = i5(1); i5b = i5(end);
    t5 = time(i5a:i5b) - time(i5a); V5 = V(i5a:i5b);
    
    i6 = find(stepindex == 52);
    i6a = i6(1); i6b = i6(end);
    t6 = time(i6a:i6b) - time(i6a); V6 = V(i6a:i6b);
    figure(1), hold on, box on
    plot(t1./60,V1), plot(t2./60,V2), plot(t3./60,V3), plot(t4./60,V4),...
        plot(t5./60,V5),plot(t6./60,V6)
    xlabel('Time (min)'), ylabel('Voltage (V)');
    xlim([0 450]), ylim([2.5 4.5])
    l = legend('C/4', 'C/2', 'C', '2C', '4C', '8C'); l.Location = 'southeast';
    %Find GITT Phases
    V1=[];
    SOC=[];
    C_rate=[];
    for j=1:max(Cycle_Index)
        index_j=find(Cycle_Index == j);
        j1a = index_j(1); j1b = index_j(end);
        t1 = time(j1a:j1b) - time(j1a); Vj = V(j1a:j1b);
        stepindex1=stepindex(j1a:j1b);
        for k=1:length(GITT_Steps)
            find_IR_drop=find(stepindex1 == GITT_Steps(k)+1,1);
            find_diff_end=find(stepindex1 == GITT_Steps(k)+1,1,'last');
            if isempty(find_IR_drop)
                
            else
                a=[Vj(find_IR_drop-1), Vj(find_IR_drop), Vj(find_diff_end)];
                V1=vertcat(V1, a);
                if mod(j,40) == 0
                    b=40;
                else 
                    b=mod(j,40);
                end
                SOC=vertcat(SOC, b);
                c=floor(j/40);
                if c == 6
                    c=5;
                end
                C_rate=vertcat(C_rate, current(c+1));
            end
        end
    end
    
   over_potential=V1(:,1)-V1(:,3);
   
   IR=V1(:,1)-V1(:,2);
   diff=V1(:,2)-V1(:,3);
   DR=over_potential./sqrt(C_rate);
   IR_total=horzcat(IR_total, IR);
   overpotential_total=horzcat(overpotential_total, over_potential);
   Cell_voltage=horzcat(Cell_voltage, V1(:,1));
   
   figure(2)
   tri = delaunay(2.5.*SOC,C_rate);
   h = trisurf(tri, 2.5.*SOC, C_rate, over_potential);
   xlabel('State of Charge (%)')
   ylabel('C-Rate')
   zlabel('Overpotential (Volts)')
   print('Overpotential_Map','-dpng')
   figure(2)
   saveas(gcf,'Overpotential_Map.fig')
   figure(3)
   tri = delaunay(2.5.*SOC,C_rate);
   h = trisurf(tri, 2.5.*SOC, C_rate, V1(:,1));
   xlabel('State of Charge (%)')
   ylabel('C-Rate')
   zlabel('Cell Voltage (Volts)')
   saveas(gcf,'CellVoltage.fig')
%    figure(4)
%    tri = delaunay(2.5.*SOC,C_rate);
%    h = trisurf(tri, 2.5.*SOC, C_rate, diff);
%    xlabel('State of Charge (%)')
%    ylabel('C-Rate (Amps)')
%    zlabel('Overpotential')
%    figure(5)
%    tri = delaunay(2.5.*SOC,C_rate);
%    h = trisurf(tri, 2.5.*SOC, C_rate, DR);
%    xlabel('State of Charge (%)')
%    ylabel('C-Rate')
%    zlabel('Dynamic Resistance')
end 
overpotential_deviation=std(overpotential_total,0,2);
figure(7)
scatter3(2.5.*SOC,C_rate,overpotential_deviation);
figure(6)
tri = delaunay(2.5.*SOC,C_rate);
h = trisurf(tri, 2.5.*SOC, C_rate, mean(overpotential_total,2));
xlabel('State of Charge (%)')
ylabel('C-Rate')
zlabel('Overpotential average (Volts)')
title('Mean Aged Overpotential')
figure(8)
tri = delaunay(2.5.*SOC,C_rate);
h = trisurf(tri, 2.5.*SOC, C_rate, mean(Cell_voltage,2));
xlabel('State of Charge (%)')
ylabel('C-Rate')
zlabel('Cell Voltage average (Volts)')
zlim([3 3.6]);
figure(9)
tri = delaunay(2.5.*SOC,C_rate);
h = trisurf(tri, 2.5.*SOC, C_rate, mean(overpotential_total,2)-mean(IR_total,2));
xlabel('State of Charge (%)')
ylabel('C-Rate')
zlabel('Overpotential IR corrected (Volts)')
zlim([0 .08]);
caxis([0, .08])
colorbar

figure(10)
tri = delaunay(2.5.*SOC,C_rate);
h = trisurf(tri, 2.5.*SOC, C_rate, 100.*diff./over_potential);
xlabel('State of Charge (%)')
ylabel('C-Rate')
zlabel('Percent of Diffuse Overpotential')


%% Plot Fixer
%Written by: Matt Svrcek  12/05/2001

%Run this script after generating the raw plots.  It will find
%all open figures and adjust line sizes and text properties.

%Change the following values to suit your preferences.  The variable
%names and comments that follow explain what each does and their options.

plotlsize = 1.5; %thickness of plotted lines, in points
axislsize = 3; %thickness of tick marks and borders, in points
markersize = 6;  %size of line markers, default is 6

%font names below must exactly match your system's font names
%check the list in the figure pull down menu under Tools->Text Properties
%note, the script editor does not have all the fonts, so use the figure menu

axisfont = 'Helvetica'; %changes appearance of axis numbers
axisfontsize = 12;            %in points
axisfontweight = 'normal';    %options are 'light' 'normal' 'demi' 'bold' 
axisfontitalics = 'normal';   %options are 'normal' 'italic' 'oblique'

legendfont = 'Helvetica'; %changes text in the legend
legendfontsize = 12;
legendfontweight = 'normal';
legendfontitalics = 'normal';

labelfont = 'Helvetica';  %changes x, y, and z axis labels
labelfontsize = 16;  
labelfontweight = 'demi'; 
labelfontitalics = 'normal';

titlefont = 'Helvetica';  %changes title
titlefontsize = 14;
titlefontweight = 'normal';
titlefontitalics = 'normal';

textfont = 'Helvetica';   %changes text
textfontsize = 14;
textfontweight = 'normal';
textfontitalics = 'normal';


%stop changing things below this line
%----------------------------------------------------
axesh = findobj('Type', 'axes');
legendh = findobj('Tag', 'legend');
lineh = findobj(axesh, 'Type', 'line');
axestexth = findobj(axesh, 'Type', 'text');

set(lineh, 'LineWidth', plotlsize);
set(lineh, 'MarkerSize', markersize);
set(axesh, 'LineWidth', axislsize);
set(axesh, 'FontName', axisfont);
set(axesh, 'FontSize', axisfontsize);
set(axesh, 'FontWeight', axisfontweight);
set(axesh, 'FontAngle', axisfontitalics);
set(axestexth, 'FontName', textfont);
set(axestexth, 'FontSize', textfontsize);
set(axestexth, 'FontWeight', textfontweight);
set(axesh, 'Box','on');
for(i = 1:1:size(axesh))
   legend(axesh(i));
   set(get(gca,'XLabel'), 'FontName', labelfont);
   set(get(gca,'XLabel'), 'FontSize', labelfontsize);
   set(get(gca,'XLabel'), 'FontWeight', labelfontweight);
   set(get(gca,'XLabel'), 'FontAngle', labelfontitalics);
   set(get(gca,'YLabel'), 'FontName', labelfont);
   set(get(gca,'YLabel'), 'FontSize', labelfontsize);
   set(get(gca,'YLabel'), 'FontWeight', labelfontweight);
   set(get(gca,'YLabel'), 'FontAngle', labelfontitalics);
   set(get(gca,'ZLabel'), 'FontName', labelfont);
   set(get(gca,'ZLabel'), 'FontSize', labelfontsize);
   set(get(gca,'ZLabel'), 'FontWeight', labelfontweight);
   set(get(gca,'ZLabel'), 'FontAngle', labelfontitalics);
   set(get(gca,'Title'), 'FontName', titlefont);
   set(get(gca,'Title'), 'FontSize', titlefontsize);
   set(get(gca,'Title'), 'FontWeight', titlefontweight);
   set(get(gca,'Title'), 'FontAngle', titlefontitalics);
end