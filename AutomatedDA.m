function [Cell_Statistics, dDQdV, End_of_life, cycle] = AutomatedDA( ResultData )
%Automated Data Analysis Goes Through CSV files and gives an experimental
%dashboard
%   Reads in csv data file and plots and exports resulting plots and stats.
%   Starts with CE, then Runs dQdV
%   What else...
    Total_time=ResultData(:,1);
    Step_Time=ResultData(:,3);
    Step_Index=round(ResultData(:,4));
    Cycle_Index=ResultData(:,5);
    VoltageV=ResultData(:,7);
    Current=ResultData(:,6);
    Charge_CapacityAh=ResultData(:,8);
    Discharge_CapacityAh=ResultData(:,9);
    
    C_in=[];
    C_out=[];
    dDQdV=[];
    %% Go Through Every Cycle
    for j=1:max(Cycle_Index)-1
        i1 = find(Cycle_Index == j);
        i1a = i1(1); i1b = i1(end);
        Voltage=VoltageV(i1a:i1b);
        Current_J=Current(i1a:i1b);
        i2 = find(Current(i1a:i1b) > 0);
        i2a = i2(1); i2b = i2(end);
        i3 = find(Current(i1a:i1b) < 0);
        if isempty(i3)
            i3a=1; i3b=2;
        else 
            i3a = i3(1); i3b = i3(end);
        end
        Charge_cap=Charge_CapacityAh(i1a:i1b);
        Discharge_cap=Discharge_CapacityAh(i1a:i1b);
        C_in(j) = max(Charge_cap);
        C_out(j) = max(Discharge_CapacityAh(i1a:i1b));
        %% Add to Discharge PCA
        [dDQdV_j, xVoltage2]=IDCA(Discharge_cap(i3a:i3b),Voltage(i3a:i3b));
        dDQdV=vertcat(dDQdV,dDQdV_j);
        %% Plot 150 cycles
        if mod(j,20) == 0
            %Plot ICA for Charge
            figure(2)
            [dQdV,xVoltage]=ICA(Charge_cap(i2a:i2b),Voltage(i2a:i2b));
            plot(xVoltage,dQdV);
            hold on
            xlabel('Voltage (Volts)')
            ylabel('dQ/dV (Ah/V)')
            %Plot ICA for Discharge
            figure(6)
            [IDC,xVoltage2]=IDCA(Discharge_cap(i3a:i3b),Voltage(i3a:i3b));
            plot(xVoltage2,IDC);
            hold on
            xlabel('Voltage (Volts)')
            ylabel('dQ/dV (Ah/V)')
            %Plot Voltage Curve
            figure(4)
            subplot(1,2,1)
            plot(Charge_cap(i2a:i2b),Voltage(i2a:i2b));
            hold on
            xlabel('Charge Capacity (Ah)')
            ylabel('Cell Voltage (V)')
            %Plot Current Profle 
            figure(4)
            subplot(1,2,2)
            plot(Charge_cap(i2a:i2b),Current_J(i2a:i2b));
            xlabel('Charge Capacity (Ah)')
            ylabel('Current (Amps)')
            hold on
        end
        %Time to 80%
        i3 = find(Charge_CapacityAh(i1a:i1b) >= .88,2);
        if isempty(i3) || length(i3) == 1 
            tt_80(j)=1200;
        else
            tt_80(j)=Total_time(i3(2)+i1a)-Total_time(i1a);
            Total_time(i3+i1a);
            Total_time(i1a);
        end  
    end
    %% Plot Summary Statistics 
    %Plot Charge Capacity
    figure(1)
    plot(1:j,smooth(C_in./max(C_in),.02,'rloess'))
    hold on;
    %Plot Discharge Capacity
    plot(1:j,smooth(C_out./max(C_in),.02,'rloess'),'-b')
    %plot(1:j,C_out./max(C_out))
    xlabel('Cycle Index')
    ylabel('Fraction of Charge Capacity')
    legend('Charge Capacity', 'Discharge Capacity','Location','SW')
    %Plot Coulombic Efficiency 
    figure(3)
    plot(1:j,smooth(100-100.*((C_in-C_out)./C_in)))
    hold on
    xlabel('Cycle Index')
    ylabel('Coloumbic Efficiecny (%)')
    %Output Charging time in Minutes
    Cell_Statistics=tt_80./60;
    End_of_life=C_out(j)./max(C_in);
    cycle=j;
   
    %Cdis = C_out./max(C_out);
end

