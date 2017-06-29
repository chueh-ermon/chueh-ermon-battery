% full_cell_analysis.m
% Zi Yang (zya@umich.edu)
%
% In-depth analysis of dQdV, temperature, relative capacity, and voltage
% for each cycle in cell
%            ----
%           | policy (string)     ----
%           | barcode (string)   | N (num of cycles)
%           |                    | Q discharge
%           |                    | Q charge
%           | summary (struct) --| T min
%           |                    | T avg
%           |                    | T max
%           |                    | time to 80%
%           |                    | IR
%           |                     ----
%           |                     ----                  
%           |                    |               ----
%           | cycles (struct)  --|              | Q
%           |                    | dQdV charge -| 
% cells(1) -|                    |              | dQdV
%           |                    |               ----
%           |                    |                  ----
%           |                    |                 | V
%           |                    | dQdV discharge -|
%           |                    |                 | dQdV
%           |                    |                  ----
%           |                    |                  ----
%           |                    |                 | Q
%           |                    | dQdV discharge -|
%           |                    |                 | dQdV
%           |                     ----              ----  
%           | relative capacity/cycle (cell array of cell arrays)
%           | temperature
%            ----

function [cell] = full_cell_analysis(ResultData, alg)

    %% Initialize struct/object/cellarray
    %{ 
    may not be able to retrieve this here? cell.policy = 'string';
    may not be able to retrieve this here? cell.barcode = 'string';
    cell.cycles.discharge_dQdVvsV = {{},{}};
    cell.cycles.discharge_dQdVvsQ = {{},{}};
    cell.cycles.charge_dQdVvsQ = {{},{}};
    cell.capacity = {};
    cell.voltage = {};
    cell.temperature = {};
    %}

    % Total Test time
    Total_time = ResultData(:,1); 
    % Unix Date Time
    Date_time = ResultData(:,2);
    % Time for individual step
    Step_Time = ResultData(:,3);
    % Index of step in Schedule file
    Step_Index = round(ResultData(:,4));
    % Cycle index, 0 is formation cycle
    Cycle_Index = ResultData(:,5); % TODO: might remove this
    end_cycle_index = ResultData(end,5);
    % All Voltage, current, charge capacity, internal resistance,
    % and temperature variables
    VoltageV = ResultData(:,7);
    Current = ResultData(:,6);
    Charge_CapacityAh = ResultData(:,8);
    Discharge_CapacityAh = ResultData(:,9);
    Internal_Resistance = ResultData(:,13);
    TemperatureT1 = ResultData(:,14);
    
    % Cell temp is 14, Shelf is 15 and 16
    % Initialize Vector of capacity in and out, maximum temperature, 
    % and discharge dQdV
    C_in=[];
    C_out=[];
    tmax=[];
    dDQdV=[];
    
    % Translate charging algorithm to something we can put in a legend.
    % TODO: could clean up variables here
    alg_name = alg;
    alg_name = strrep(alg_name, '_' , '.' );
    alg_name = strrep(alg_name, '-' , '(' );
    alg_name = strrep(alg_name, 'per.' , '%)-' );
    cell.policy = alg_name;
    
    %% Go Through Every Cycle except current running one
    for j = 1:end_cycle_index
        % find the start and end indices for each cycle
        cycle_indices = find(Cycle_Index == j);
        cycle_start = cycle_indices(1);
        cycle_end = cycle_indices(end);
        % Time in the cycle
        cycle_time = Total_time(cycle_start:cycle_end) ...
            - Total_time(cycle_start);
        % Voltage of cycle j
        Voltage_J = VoltageV(cycle_start:cycle_end);
        % Current values for cycle j
        Current_J = Current(cycle_start:cycle_end);
        % Charge Capacity for the cycle 
        Charge_Cap_J = Charge_CapacityAh(cycle_start:cycle_end);
        % Discharge Capacity for the cycle 
        Discharge_Cap_J = Discharge_CapacityAh(cycle_start:cycle_end);
        % Temperature of the cycle. 
        Temp_J = TemperatureT1(cycle_start:cycle_end);
        
        % Index of any charging portion
        charge_indices = find(Current(cycle_start:cycle_end) > 0); % TODO: > or >= ?
        charge_start = charge_indices(1); 
        charge_end = charge_indices(end);
        
        % Index of discharging portion of the cycle 
        discharge_indices = find(Current(cycle_start:cycle_end) < 0);
        % In case discharge_indicies is empty
        if isempty(discharge_indices)
            discharge_start = 1; discharge_end = 2;
        else 
            discharge_start = discharge_indices(1); 
            discharge_end = discharge_indices(end);
        end
        
        %% Save dQdV data to cell.cycles(#) struct
        %[dQdV, xVoltage] = ICA(Charge_Cap_J(charge_start:charge_end), ...
        %    Voltage_J(charge_start:charge_end));
        % TODO: how to get dQdV vs Q
        
        [IDC,xVoltage2] = IDCA(Discharge_Cap_J(discharge_start: ...
            discharge_end),Voltage_J(discharge_start:discharge_end));
        cell.cycles(j).discharge_dQdVvsV.V = xVoltage2;
        cell.cycles(j).discharge_dQdVvsV.dQdV = IDC;
        
        
        
        %{
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
            [IDC,xVoltage2]=IDCA(Discharge_cap(discharge_start:discharge_end),Voltage(discharge_start:discharge_end));
            plot(xVoltage2,IDC,'Color',color_array{fix(j/100)+1}, ...
                'LineWidth',1.5);
            hold on
            xlabel('Voltage (Volts)')
            ylabel('dQ/dV (Ah/V)')
            % save as mat after each plot
            save(strcat(charging_algorithm, '_', cell_ID, ...
                '_dQdV_cycle', num2str(j)), 'xVoltage2', 'IDC')
            % savefig(strcat(charging_algorithm, '_', cell_ID, '_dQdV'))
            
            %% Plot Voltage Curve
            figure(cell_ID1)
            subplot(2,4,6)
            plot(Charge_cap(charge_start:charge_end),Voltage(charge_start:charge_end),'Color',...
                color_array{fix(j/100)+1},'LineWidth',1.5);
            charge_capacity = Charge_cap(charge_start:charge_end);
            volt = Voltage(charge_start:charge_end);
            hold on
            xlabel('Charge Capacity (Ah)')
            ylabel('Cell Voltage (V)')
            xlim([0 1.2])
            ylim([3.1 3.65])
            save(strcat(charging_algorithm, '_', cell_ID, ...
                '_VvsQ_cycle', num2str(j)), 'charge_capacity', 'volt')
            % savefig(strcat(charging_algorithm, '_', cell_ID, '_VvsQ'))
            
            subplot(2,4,7)
            plot(Charge_cap(charge_start:charge_end),temp(charge_start:charge_end),'Color',...
                color_array{fix(j/100)+1},'LineWidth',1.5);
            chrg_cap = Charge_cap(charge_start:charge_end);
            temperature = temp(charge_start:charge_end);
            hold on 
            xlabel('Charge Capacity (Ah)')
            ylabel('Cell Temperature (Celsius)')
            ylim([28 45])
            save(strcat(charging_algorithm , '_' , cell_ID , ...
                '_TvsQ_cycle', num2str(j)), 'chrg_cap','temperature')
            % savefig(strcat(charging_algorithm , '_' , cell_ID , '_TvsQ'))
            
            %% Plot Current Profile 
            figure(cell_ID1)
            subplot(2,4,5)
            yyaxis left
            plot(cycle_time(charge_start:charge_end)./60,Current_J(charge_start:charge_end)/1.1,'-',...
                'Color', color_array_blue{fix(j/100)+1},'LineWidth',1.5);
            cycle_t = cycle_time(charge_start:charge_end)./60;
            current = Current_J(charge_start:charge_end)/1.1;
            xlabel('Time (minutes)')
            ylabel('Current (C-Rate)')
            hold on
            yyaxis right
            plot(cycle_time(charge_start:charge_end)./60,Charge_cap(charge_start:charge_end),'-',...
                'Color', color_array{fix(j/100)+1},'LineWidth',1.5);
            ylabel('Charge Capacity (Ah)')
            xlim([0,60])
            save(strcat(charging_algorithm , '_' , cell_ID , ...
                '_Qvst_cycle', num2str(j)), 'cycle_t', 'current')
            % savefig(strcat(charging_algorithm , '_' , cell_ID , '_Qvst'))
            
        end
        %% Add Cycle Legend
        C_in(j) = max(Charge_cap);
        C_out(j) = max(Discharge_cap);
        tmax(j) = max(temp);
        tmin(j) = min(temp);
        t_avg(j) = mean(temp);
        IR_CC1(j) = Internal_Resistance(cycle_end);
        %% Smooth perform dQdV and add to Discharge PCA
        [dDQdV_j, xVoltage2]=IDCA(Discharge_cap(discharge_start:discharge_end),Voltage(discharge_start:discharge_end));
        dDQdV=vertcat(dDQdV,dDQdV_j);
        %% Find Time to 80%
        discharge_indices = find(Charge_CapacityAh(cycle_start:cycle_end) >= .88,2);
        if isempty(discharge_indices) || length(discharge_indices) == 1 
            tt_80(j)=1200;
        else
            tt_80(j)=Total_time(discharge_indices(2)+cycle_start)-Total_time(cycle_start);
            Total_time(discharge_indices+cycle_start);
            Total_time(cycle_start);
        end
        % In case an incomplete charge
        if tt_80(j)<300
            tt_80(j)=tt_80(j-1);
        end
        %}
    end