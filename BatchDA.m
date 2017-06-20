function [Charge_time, dDQdV, End_of_life, cycle, Q, DQ, cell_ID1, ...
    test_time] = BatchDA( ResultData, fig, alg, cell_ID )
%Automated Data Analysis Goes Through CSV files and gives an experimental
%dashboard
%   Reads in csv data file and plots and exports resulting plots and stats.
%   Starts with CE, then Runs dQdV
%   What else...
    % Total Test time
    Total_time=ResultData(:,1); 
    % Unix Date Time
    Date_time=ResultData(:,2);
    % Time for individual step
    Step_Time=ResultData(:,3);
    % Index of step in Schedule file
    Step_Index=round(ResultData(:,4));
    % Cycle index, 0 is formation cycle
    Cycle_Index=ResultData(:,5);
    % All Voltage, current, charge capacity, internal resistance,
    % and temperature variables
    VoltageV=ResultData(:,7);
    Current=ResultData(:,6);
    Charge_CapacityAh=ResultData(:,8);
    Discharge_CapacityAh=ResultData(:,9);
    Internal_Resistance=ResultData(:,13);
    TemperatureT1=ResultData(:,14);
    %Shelf_temp=horzcat(ResultData(:,15),ResultData(:,16));
    % Cell temp is 14, Shelf is 15 and 16
    % Initialize Vector of capacity in and out, maximum temperature, 
    % and discharge dQdV
    C_in=[];
    C_out=[];
    tmax=[];
    dDQdV=[];
    % 18 increasing darkness reds for cycle results
    color_array={[255,230,230]./256; [255,204,204]./256; ...
        [255,179,179]./256; [255,153,153]./256; [255,128,128]./256; ...
        [255,102,102]./256; [255,77,77]./256; [255,0,0]./256; ...
        [230,0,0]./256; [204,0,0]./256; [179,0,0]./256; [153,0,0]./256; ...
        [128,0,0]./256; [102,0,0]./256; [77,0,0]./256; [51,0,0]./256; ...
        [26,0,0]./256; [0,0,0]};
    % 18 increasing darkness blues for cycle results
    color_array_blue={[230,230,255]./256; [204,204,255]./256; ...
        [179,179,255]./256; [153,153,255]./256; [128,128,255]./256; ...
        [102,102,255]./256; [77,77,255]./256; [51,51,255]./256; ...
        [26,26,255]./256; [0,0,255]./256; [0,0,230]./256; ...
        [0,0,204]./256; [0,0,179]./256; [0,0,153]./256; [0,0,128]./256; ...
        [0,0,102]./256; [0,0,77]./256; [0,0,51]./256; [0,0,26]./256; ...
        [0,0,0]};
    % Cycle legends2
    legend_array={'100'; '200'; '300'; '400'; '500';'600';'700';'800'; ...
        '900';'1000'};
    % Translate charging algorithm to something we can put in a legend.
    t = alg;
    t2 = strrep(t, '_' , '.' );
    t2 = strrep(t2, '-' , '(' );
    t2 = strrep(t2, 'per.' , '%)-' );
    alg=t2;
    % Set Figure
    cell_ID1=figure('units','normalized','outerposition',[0 0 1 1]);
    %% Go Through Every Cycle except current running one
    for j=1:max(Cycle_Index)-1
        i1 = find(Cycle_Index == j);
        i1a = i1(1); i1b = i1(end);
        % Time in the cycle
        cycle_time=Total_time(i1a:i1b)-Total_time(i1a);
        % Voltage of Cycle J
        Voltage=VoltageV(i1a:i1b);
        % Current values for cycle J
        Current_J=Current(i1a:i1b);
        % Charge Capacity for the cycle 
        Charge_cap=Charge_CapacityAh(i1a:i1b);
        %Discharge Capacity for the cycle 
        Discharge_cap=Discharge_CapacityAh(i1a:i1b);
        % Temperature of the cycle. 
        temp=TemperatureT1(i1a:i1b);
        % Index of any charging portion
        i2 = find(Current(i1a:i1b) >= 0); % todo: > or >= ?
        i2a = i2(1); i2b = i2(end);
        % Index of discharging portion of the cycle 
        i3 = find(Current(i1a:i1b) < 0);
        % In case i3 is empty
        if isempty(i3)
            i3a=1; i3b=2;
        else 
            i3a = i3(1); i3b = i3(end);
        end
        %% Plot every 100 cycles
        if mod(j,100) == 0
            %% Plot ICA for Charge
%            figure(fig+1)
%             subplot(2,2,1)
%             [dQdV,xVoltage]=ICA(Charge_cap(i2a:i2b),Voltage(i2a:i2b));
%             plot(xVoltage,dQdV);
%             hold on
%             xlabel('Voltage (Volts)')
%             ylabel('dQ/dV (Ah/V)')
            %% Plot ICA for Discharge
            figure(cell_ID1)
            subplot(2,4,8)
            [IDC,xVoltage2]=IDCA(Discharge_cap(i3a:i3b),Voltage(i3a:i3b));
            plot(xVoltage2,IDC,'Color',color_array{fix(j/100)+1}, ...
                'LineWidth',1.5);
            hold on
            xlabel('Voltage (Volts)')
            ylabel('dQ/dV (Ah/V)')
            
            %% Plot Voltage Curve
            figure(cell_ID1)
            subplot(2,4,6)
            plot(Charge_cap(i2a:i2b),Voltage(i2a:i2b),'Color',...
                color_array{fix(j/100)+1},'LineWidth',1.5);
            hold on
            xlabel('Charge Capacity (Ah)')
            ylabel('Cell Voltage (V)')
            xlim([0 1.2])
            ylim([3.1 3.65])
            subplot(2,4,7)
            plot(Charge_cap(i2a:i2b),temp(i2a:i2b),'Color',...
                color_array{fix(j/100)+1},'LineWidth',1.5);
            hold on 
            xlabel('Charge Capacity (Ah)')
            ylabel('Cell Temperature (Celsius)')
            ylim([28 45])
            %% Plot Current Profile 
            figure(cell_ID1)
            subplot(2,4,5)
            yyaxis left
            plot(cycle_time(i2a:i2b)./60,Current_J(i2a:i2b)/1.1,'-',...
                'Color', color_array_blue{fix(j/100)+1},'LineWidth',1.5);
            xlabel('Time (minutes)')
            ylabel('Current (C-Rate)')
            hold on
            yyaxis right
            plot(cycle_time(i2a:i2b)./60,Charge_cap(i2a:i2b),'-',...
                'Color', color_array{fix(j/100)+1},'LineWidth',1.5);
            ylabel('Charge Capacity (Ah)')
            
        end
        %% Add Cycle Legend
        C_in(j) = max(Charge_cap);
        C_out(j) = max(Discharge_cap);
        tmax(j)= max(temp);
        tmin(j)=min(temp);
        t_avg(j)=mean(temp);
        IR_CC1(j)=Internal_Resistance(i1b);
        %% Smooth perform dQdV and add to Discharge PCA
        [dDQdV_j, xVoltage2]=IDCA(Discharge_cap(i3a:i3b),Voltage(i3a:i3b));
        dDQdV=vertcat(dDQdV,dDQdV_j);
        %% Find Time to 80%
        i3 = find(Charge_CapacityAh(i1a:i1b) >= .88,2);
        if isempty(i3) || length(i3) == 1 
            tt_80(j)=1200;
        else
            tt_80(j)=Total_time(i3(2)+i1a)-Total_time(i1a);
            Total_time(i3+i1a);
            Total_time(i1a);
        end
        % In case an incomplete charge
        if tt_80(j)<300
            tt_80(j)=tt_80(j-1);
        end
    end
    
    %% Plot Summary Statistics
     figure(cell_ID1)
        subplot(2,4,8)
        legend(legend_array{1:(fix(j/100))},'Location','eastoutside', ...
            'Orientation','vertical')
    % Export Charge Capacity and correct if errant charge
    if j>5
        [sorted_C, ind]=sort(C_in,'descend');
        maxValues = sorted_C(1:5);
        maxValueIndices = ind(1:5);
        median(C_in(maxValueIndices));
        Q=C_in./median(C_in(maxValueIndices));
        DQ=C_out./median(C_in(maxValueIndices));
        End_of_life=C_out(j)./median(C_in(maxValueIndices));
    end
    %% Plot Capacity Curve
    subplot(2,4,1)
    plot(1:j, DQ, 'Color','r','LineWidth',1.5)
    hold on
    plot(1:j, Q, 'Color', 'b','LineWidth',1.5)
    hold on
    legend('Discharge', 'Charge')
    xlabel('Cycle Index')
    ylabel(' Remaining Capacity')
    %% Plot IR during CC1 and CC2
    subplot(2,4,4)
    plot(1:j,IR_CC1,'LineWidth',1.5)
    hold on
    xlabel('Cycle Index')
    ylabel('Internal Resistance (Ohms)')
    ylim([.015 .02])
    %% Plot Temperature as a function of Cycle Index
    subplot(2,4,3)
    plot(1:j, tmax, 'Color', [0.800000 0.250000 0.330000],'LineWidth',1.5)
    hold on
    plot(1:j, tmin, 'Color', [0.600000 0.730000 0.890000],'LineWidth',1.5)
    hold on 
    plot(1:j, t_avg, 'Color',[1.000000 0.620000 0.000000],'LineWidth',1.5)
    xlabel('Cycle Index')
    ylabel('Temperature (Celsius)')
    ylim([28 45])
    title(cell_ID)
    CE=(100-100.*((C_in-C_out)./C_in));
    %% Plot Charge Time 
    subplot(2,4,2)
    plot(1:j,smooth(tt_80./60),'LineWidth',1.5)
    hold on 
    xlabel('Cycle Index')
    ylabel('Time to 80% SOC (minutes)')
    title(alg)
    ylim([8.5 14])
    %Output Charging time in Minutes
    Charge_time=tt_80./60;
    % Output final capacity and cycle count
    cycle=j;
    test_time=max(Date_time);
    test_time=datenum([1970 1 1 0 0 test_time]);
end

