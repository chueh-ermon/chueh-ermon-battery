function [deg_rates ] = plot_spread(master_cycle, DQ, charge_time, ...
    time_evol, master_capacity, CA_array, cyc_array, last_time)
%% Plots Spread of Batch Charging Algorithms 
now=datenum(datetime('now'));
non_linear_regression( master_cycle, DQ)
leg=[];
line_color={};
col_array={};
deg_rates={};
finished_test=[];
col_capacity=[];
for i=1:numel(DQ)
    %vector of capacities
    cap=DQ{i};
    % vector of charge times
    d_tt80=time_evol{i};
    if master_cycle(i) > 100
        figure(50)
        l_c_1=plot([median(d_tt80(1:100)),median(d_tt80(master_cycle(i)-100:master_cycle(i)))],...
            [((1-cap(master_cycle(i)))./master_cycle(i)),((1-cap(master_cycle(i)))./master_cycle(i))],...
            'Color','k');
        hold on
        l_c_2=plot([median(d_tt80),median(d_tt80)],...
            [((1-cap(100)))./100,((cap(master_cycle(i)-100)-cap(master_cycle(i)))./100)],...
            'Color','k');
        deg_rates{i}=[((1-cap(100)))./100, ...
            ((1-cap(master_cycle(i)))./master_cycle(i)), ...
            ((cap(master_cycle(i)-100)-cap(master_cycle(i)))./100)];
        error_bars=horzcat(l_c_1,l_c_2);
        line_color=vertcat(line_color, error_bars);
    end 
    if now > last_time(i) +1 
        finished_test=horzcat(finished_test,i);
        figure(51)
        plot(1:master_cycle(i),cap,'Color','r');
        hold on
    end
end 
for i=1:numel(charge_time)
    figure(49)
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]) 
    tt80=charge_time{i};
    mQ=master_capacity{i};
    cyc_count=cyc_array{i};
    [col, mark]=random_color('y','y');
    scatter(tt80,mQ,100,col,mark,'LineWidth',2)
    hold on
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Remaining Capacity')
    
    figure(50)
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    i=scatter(tt80,(1-mQ)./cyc_count,200,col,mark,'LineWidth',2);
    leg=vertcat(leg,i);
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Degradation rate')
    hold on
    for k=1:length(tt80)
        col_array=vertcat(col_array,col);
    end 
end
count=0;
for i=1:length(finished_test)
        b = master_cycle;
        c = DQ;
        c(finished_test(i)-count) = [];
        b(finished_test(i)-count) = [];
        master_cycle=b;
        DQ=c;
        count=count+1;
end
batch_cycle=min(master_cycle);
for i=1:length(master_cycle)
    total_cap=DQ{i};
    col_capacity=horzcat(col_capacity, transpose(total_cap(1:batch_cycle)));
end 

for i=1:numel(CA_array)
    t = CA_array{i};
    t2 = strrep(t, '_' , '.' );
    t2 = strrep(t2, '-' , '(' );
    t2 = strrep(t2, 'per.' , '%)-' );
    CA_array{i}=t2;
end 
figure(49), legend(CA_array, 'Location', 'bestoutside'), box on
figure(50), legend(leg,CA_array, 'Location', 'bestoutside'), box on

figure(51)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]) 
hold on
box on
if isempty(col_capacity) == 0
    med=median(col_capacity,2);
    min_c=min(col_capacity,[],2);
    max_c=max(col_capacity,[],2);
    spread=std(col_capacity,0,2);
    x =transpose(1:batch_cycle);
    p1=fill([x;flipud(x)],[max_c; flipud(min_c)],[0.680000 0.850000 0.900000]);
    p2=plot(1:batch_cycle,smooth(med),'LineWidth', 2, 'Color','b');
    xlabel('Cycle Index')
    ylabel('Fractional Capacity')
    ylim([0.8 1])
    legend([p1 p2],{'Total Cell Spread','Median Capacity'},'Location','southwest');
    legend('boxoff')
end
plotfixer;
for i=1:length(col_array)
    lines=line_color(i,:);
    for j=1:length(lines)
        line=line_color(i,j);
        line.Color=col_array{i};
        line.LineWidth=0.75;
    end
end 
    
end

