function [ hFig ] = PlotCycles( xVoltage, master_dQdV, master_Q, nrow, ncol )
%PlotCycles creates plot of dQdV data which is color-coded by the relative
%capacity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% xVoltage - x-axis range, is assumed to be the same for all batteries
% master_dQdV - cell containing the dQdV for each cycle for each battery
% master_Q - cell containing the relative capacity for each battery for
% each cycle
% nrow - number of rows of subplots
% ncol - number of columsn of subplots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hFig - resulting figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT: the axis ranges and maximum relative capacity are hard-coded
% and the titles are currently disabled because I wasn't sure about
% the data structure. Feel free to modify / use for other purposes. Be
% aware that it's a little slow!

% Initial written by KA Severson 6/27/2017

if size(master_Q,2) > 1 %check if plotting for one battery or many
% this case is for multiple batteries

    % choose the relative capacity range
    max_Q = 1;
    min_Q = 1;
    for j = 1:size(master_Q,2)
        check_min = min(master_Q{j});
        if check_min < min_Q
            min_Q = check_min;
        end
    end
    min_Q = floor(min_Q*100)/100;
    
    %set the colormap
    colormap('jet')
    CM = colormap('jet');
    hFig=figure();
    
    for j = 1:size(master_dQdV,2)
        %trick matlab to thinking we are making a surface plot
        if j == 1
            surf(peaks,colormap('jet'))
            cla
        end
        
        %plot the data
        subplot(nrow,ncol,j)
        hold on
        for i = 1:size(master_dQdV{1},2)
            color_ind = ceil((master_Q{j}(i) - min_Q)./(max_Q - min_Q)*64);
            plot(xVoltage{j}, master_dQdV{j}(:,i),'Color',CM(color_ind,:))
        end %end loop through cycles
        ylim([0,25])
        xlim([3.2,4.4])
        xlabel('Voltage (V)')
        ylabel('Incremental Capacity (mAh/V)')
        %title(data_list{j}(1:end-4))
        
    end %end loop through batteries
    suptitle('Relative Capacity and Internal Capacity: All cycles')
    h = colorbar;
    set(h,'Position',[0.92, 0.075 0.01 0.8])
    %over-write the legend to have the correct relative capacity range
    h.Label.String = 'Relative Capacity';
    h.TickLabels = linspace(min_Q,max_Q,11);
    set(hFig,'position',get(0,'Screensize'))
    
else
% this case is for a single battery (i.e. data to be on the same plot
    
    %choose the relative capacity range
    max_Q = 1;
    min_Q = floor(min(master_Q)*100)/100;
    
    %set the colormap
    colormap('jet')
    CM = colormap('jet');
    hFig=figure();
    
    %plot the data
    hold on
    for i = 1:size(master_dQdV,2)
        if i == 1
            surf(peaks,colormap('jet'))
            cla
        end
        subplot(1,1,1)
        color_ind = ceil((master_Q(i) - min_Q)./(max_Q - min_Q)*64);
        plot(xVoltage, master_dQdV(:,i),'Color',CM(color_ind,:))
    end %end loop through cycle number
    ylim([0,25])
    xlim([3.2,4.4])
    xlabel('Voltage (V)')
    ylabel('Incremental Capacity (mAh/V)')
    %title(data_list{j}(1:end-4))
    
    suptitle('Relative Capacity and Internal Capacity: All cycles')
    h = colorbar;
    set(h,'Position',[0.92, 0.075 0.01 0.8])
    %over-write the legend to have the correct relative capacity range
    h.Label.String = 'Relative Capacity';
    h.TickLabels = linspace(min_Q,max_Q,11);
    set(hFig,'position',get(0,'Screensize'))
    
end %end test of cases

end %end function

