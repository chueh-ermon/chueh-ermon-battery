clear; close all; clc
%Script to test the PlotCycles file, this should run as is so long as
%you've downloaded the dataset (ChenLiProcessed) and plotting function
%(PlotCycles)

load ChenLiProcessed.mat

% this will create a figure with subplots
cycFig =  PlotCycles( xVoltage, master_dQdV, master_Q, 4, 6 );
% recommend saving plots as eps files but can print to any file type
set(cycFig,'position',get(0,'Screensize'))
print('CyclePlot_Test','-dpng')
print('CyclePlot_Test','-depsc')

% this returns a plot for just one batter
cycFig1 = PlotCycles(xVoltage{1},master_dQdV{1}, master_Q{1}, 1,1);