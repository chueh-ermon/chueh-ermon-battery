function [master_dQdV, master_Q,test_scores, scores_resized,b,error] = PCA_Prediction( data_list )
%This Function opens multiple csv battery result files
%
close all 
Perm1 = randperm(length(data_list));
data_list=data_list(Perm1);

cycles=[25,50,75,100,125,150,175,200,225,250,275,300,325,...
    350,375,400,425,450,475,500,525,550];
%cycles=[145];
for t=1:length(cycles)
    t
    master_dQdV=[];
    master_Q=[];
    master_dQdV2=[];
    master_Q2=[];
    for i=1:length(data_list)-5
        %Location of the folder containing csv Arbin result files
        filepath= '/Documents/MATLAB/ChenLi_Data/';
        %Convert to String
        str = strcat(filepath,string(data_list(i)));
        %Reads CSV file into full matrix
        ResultData = csvread(str,1,3);

        %Label major CSV columns
        %If using chueh Data Step time=1
        %StepIndex=3, Cycle Index = 4, Current = 6
        % Voltage=7, Charge Capacity 8, Discharge Capacity 9.
        Step_Time=ResultData(:,1);
        Step_Index=round(ResultData(:,2));
        Cycle_Index=ResultData(:,3);
        VoltageV=ResultData(:,5);
        Charge_CapacityAh=ResultData(:,6);
        Discharge_CapacityAh=ResultData(:,7);

        %Initialize dQdV array.
        Capacitance= zeros(length(VoltageV),1);
        %Pre-Count non rate test cycles.
        NormalCycle=0;
        TotalCycle=max(Cycle_Index);
        %Calculate Approximate dQdV
    for j=2:length(VoltageV)
        Capacitance(j)=(Charge_CapacityAh(j)-Charge_CapacityAh(j-1))/(VoltageV(j)-VoltageV(j-1));
    end

    %Tidy dQdV data for all battery cycles. 
    for j=1:length(Capacitance)
        if isnan(Capacitance(j)) 
            Capacitance(j)=0;
         elseif Capacitance(j)<0
             Capacitance(j)=0;
        elseif abs(Capacitance(j)) >= 1000
            Capacitance(j)=0;
            %Ignore CV location, or shorted battery 
        elseif VoltageV(j) >= 4.34
            Capacitance(j)=0;
        elseif VoltageV(j) <= 3
            Capacitance(j)=0;
        else 
            Capacitance(j)=Capacitance(j);
        end
    end 
    %%  Create Cycle Matrixes 
    %Create matrices for each value and step
    %Dimensions are (Max # of steps x Total Cycles)
    %Matrix of dQdV
    cyclematrix1= [];
    %Matrix of Voltage values
    cyclematrix2= [];
    %Matrix of Charge Capacity, during charging cycles only
    cyclematrix3= [];
    %Matrix of Time values for each Charging Step.
    cyclematrix4= [];
    %Matrix of Discharge Capacity, during discharges
    cyclematrix5= [];
    %Matrix of dQ/dV discharge
    cyclematrix6= [];
    % ICreate Initial Charging Voltage Array
    VoltageV1=[];


    % Fill the matrixes
    for j=1:TotalCycle
        %First Step for each cycle 
        n=0;
        o=0;
        %Marks First Voltage Step
        x=0;
        for p=1:length(Cycle_Index)
            if Cycle_Index(p) == j
                % 4 and 10 are 1C charges partnered with steps 6 and 10, 17 is
                % a C/10 charge, 21 is a 1C to 4.35 CV 26 is the same 
                if  Step_Index(p) == 10  
                        % || Step_Index(p) == 26 || Step_Index(p) == 17 || ...
                        %Step_Index(p) == 21 || Step_Index(p) == 31, Step_Index(p) == 4 ||
                    if x== 0
                        NormalCycle= NormalCycle+1;
                        VoltageV1(NormalCycle,1) = VoltageV(p);
                    end
                    cyclematrix3(n+1,NormalCycle)= Charge_CapacityAh(p);
                    cyclematrix4(n+1,NormalCycle)= Step_Time(p);
                    cyclematrix1(n+1,NormalCycle)= Capacitance(p);
                    cyclematrix2(n+1,NormalCycle)= VoltageV(p);
                    n= n+1;
                    x=1;
                end
                % 6 is a 1C discharge 13 is 10C discharge, 19 is a C/10
                % discharge 23 is a 15 C discharge. 28 is a 1C discharge. 
                if  Step_Index(p) == 13 
                        %|| Step_Index(p) == 16 || Step_Index(p) == 19 ||...
                        %Step_Index(p) == 23 || Step_Index(p) == 28 
                        %Step_Index(p) == 6 ||
                    cyclematrix5(o+1,NormalCycle)= Discharge_CapacityAh(p);
                    cyclematrix6(o+1,NormalCycle)= Capacitance(p);
                    o=o+1;
                end
            end
        end
    end
    %% Interpolate Voltage Values.
    %Define Voltage Range.
    xVoltage=linspace(3.3,4.34,1050);

    % Create Array for Initial Voltage Values and empty dQdV
    interp_Voltages= 3.3.*ones(1,length(VoltageV1));
    interp_ICA1=zeros(1,length(VoltageV1));
    interp_ICA2=.0001.*ones(1,length(VoltageV1));
    first_Voltage=transpose(VoltageV1-.0001);

    %Add to the Cycle Matrix
    continuosVoltage=vertcat(interp_Voltages,first_Voltage,cyclematrix2);
    continuosICA=vertcat(interp_ICA1,interp_ICA2,cyclematrix1);

    for j=1:NormalCycle
        VoltageCurve=continuosVoltage(:,j);
        ICA_Curve=continuosICA(:,j);
        [VoltageCurve, index] = unique(VoltageCurve);  
        dQdV(:,j)= interp1(VoltageCurve,ICA_Curve(index),xVoltage);
        %cyclematrix1(:,j)=smooth(cyclematrix1(:,j),5);
        %cyclematrix2(:,j)=smooth(cyclematrix2(:,j),5);
    end
    %master_dQdV =horzcat(master_dQdV, dQdV(:,1:100));

    %% Calculate Time, Average Voltage, and Charge Capacity for each cyle.
    for j=1:NormalCycle 
        LSTM_Parameters(j,4*(i-1)+1)=max(cyclematrix4(:,j))/1000;
        LSTM_Parameters(j,4*(i-1)+3)=max(cyclematrix3(:,j));
        LSTM_Parameters(j,4*(i-1)+4)=max(cyclematrix5(:,j));
        Voltage_sum=0;
        step_num=0;
        for n=1:length(cyclematrix2(:,j))
            if cyclematrix2(n,j) ~= 0
                Voltage_sum= Voltage_sum+ cyclematrix2(n,j);
                step_num= step_num +1;
            end
        end
        LSTM_Parameters(j,4*(i-1)+2)=Voltage_sum/step_num;     
    end

    %Normalize Capacity 
    CQ = LSTM_Parameters(:,4*(i-1)+3)./max(LSTM_Parameters(:,4*(i-1)+3));
    Q = LSTM_Parameters(:,4*(i-1)+4)./max(LSTM_Parameters(:,4*(i-1)+4));
    %master_Q=[master_Q; Q];
    %master_dQdV =horzcat(master_dQdV, dQdV);
    %%  Calculate Cycle Life to 95,90 and 80% capacity.
    Cyc_to_95=0;
    Cyc_to_90=0;
    Cyc_to_80=0;
    for j=1:NormalCycle
        if Q(j)>=0.8
            Cyc_to_80= Cyc_to_80+1;
        end
        if Q(j)>=0.9
            Cyc_to_90= Cyc_to_90+1;
        end
        if Q(j)>=0.95
            Cyc_to_95= Cyc_to_95+1;
        end
    end
        Y(i)=Q(575);
        master_Q=[master_Q; Q(1:cycles(t))];
        master_dQdV =horzcat(master_dQdV, dQdV(:,1:cycles(t)));
    end
%% Run PLSR and Store Initial Charging Voltage.
% fix this.
    [components, scores, mean_X]=PCA_All_Battery(master_dQdV,master_Q, xVoltage);
    close all
    %Resize Score list. 
    scores_first_components=scores(:,1:3);
    scores_resized=zeros(i,3.*cycles(t));
    for q=1:i
        r=1;
        for w=1:cycles(t)
            for e=1:3
                scores_resized(q,r)=scores_first_components(w+(cycles(t)*(q-1)),e);
                r=r+1;
            end
        end
    end
    
    b=regress(transpose(Y),scores_resized);
    Y_guess=scores_resized*b;
    Train_error(:,t)=transpose(Y)-Y_guess;
    RMSE_train(t)=sqrt(sum(Train_error(:,t).^2)./5);
    %Train a regression model to predict capacity at cycle 500.
    %Run RMSE on remaining Data_list
    for i=length(data_list)-4:length(data_list)
    %Location of the folder containing csv Arbin result files
        filepath= '/Documents/MATLAB/ChenLi_Data/';
        %Convert to String
        str = strcat(filepath,string(data_list(i)));
        %Reads CSV file into full matrix
        ResultData = csvread(str,1,3);

        %Label major CSV columns
        %If using chueh Data Step time=1
        %StepIndex=3, Cycle Index = 4, Current = 6
        % Voltage=7, Charge Capacity 8, Discharge Capacity 9.
        Step_Time=ResultData(:,1);
        Step_Index=round(ResultData(:,2));
        Cycle_Index=ResultData(:,3);
        VoltageV=ResultData(:,5);
        Charge_CapacityAh=ResultData(:,6);
        Discharge_CapacityAh=ResultData(:,7);

        %Initialize dQdV array.
        Capacitance= zeros(length(VoltageV),1);
        %Pre-Count non rate test cycles.
        NormalCycle=0;

        %Calculate Approximate dQdV
    for j=2:length(VoltageV)
        Capacitance(j)=(Charge_CapacityAh(j)-Charge_CapacityAh(j-1))/(VoltageV(j)-VoltageV(j-1));
    end

    %Tidy dQdV data for all battery cycles. 
    for j=1:length(Capacitance)
        if isnan(Capacitance(j)) 
            Capacitance(j)=0;
         elseif Capacitance(j)<0
             Capacitance(j)=0;
        elseif abs(Capacitance(j)) >= 1000
            Capacitance(j)=0;
            %Ignore CV location, or shorted battery 
        elseif VoltageV(j) >= 4.34
            Capacitance(j)=0;
        elseif VoltageV(j) <= 3
            Capacitance(j)=0;
        else 
            Capacitance(j)=Capacitance(j);
        end
    end 
    %%  Create Cycle Matrixes 
    %Create matrices for each value and step
    %Dimensions are (Max # of steps x Total Cycles)
    %Matrix of dQdV
    cyclematrix1= [];
    %Matrix of Voltage values
    cyclematrix2= [];
    %Matrix of Charge Capacity, during charging cycles only
    cyclematrix3= [];
    %Matrix of Time values for each Charging Step.
    cyclematrix4= [];
    %Matrix of Discharge Capacity, during discharges
    cyclematrix5= [];
    %Matrix of dQ/dV discharge
    cyclematrix6= [];
    % ICreate Initial Charging Voltage Array
    VoltageV1=[];


    % Fill the matrixes
    for j=1:TotalCycle
        %First Step for each cycle 
        n=0;
        o=0;
        %Marks First Voltage Step
        x=0;
        for p=1:length(Cycle_Index)
            if Cycle_Index(p) == j
                % 4 and 10 are 1C charges partnered with steps 6 and 10, 17 is
                % a C/10 charge, 21 is a 1C to 4.35 CV 26 is the same 
                if  Step_Index(p) == 10  
                        % || Step_Index(p) == 26 || Step_Index(p) == 17 || ...
                        %Step_Index(p) == 21 || Step_Index(p) == 31, Step_Index(p) == 4 ||
                    if x== 0
                        NormalCycle= NormalCycle+1;
                        VoltageV1(NormalCycle,1) = VoltageV(p);
                    end
                    cyclematrix3(n+1,NormalCycle)= Charge_CapacityAh(p);
                    cyclematrix4(n+1,NormalCycle)= Step_Time(p);
                    cyclematrix1(n+1,NormalCycle)= Capacitance(p);
                    cyclematrix2(n+1,NormalCycle)= VoltageV(p);
                    n= n+1;
                    x=1;
                end
                % 6 is a 1C discharge 13 is 10C discharge, 19 is a C/10
                % discharge 23 is a 15 C discharge. 28 is a 1C discharge. 
                if  Step_Index(p) == 13 
                        %|| Step_Index(p) == 16 || Step_Index(p) == 19 ||...
                        %Step_Index(p) == 23 || Step_Index(p) == 28 
                        %Step_Index(p) == 6 ||
                    cyclematrix5(o+1,NormalCycle)= Discharge_CapacityAh(p);
                    cyclematrix6(o+1,NormalCycle)= Capacitance(p);
                    o=o+1;
                end
            end
        end
    end
    %% Interpolate Voltage Values.
    %Define Voltage Range.
    xVoltage=linspace(3.3,4.34,1050);

    % Create Array for Initial Voltage Values and empty dQdV
    interp_Voltages= 3.3.*ones(1,length(VoltageV1));
    interp_ICA1=zeros(1,length(VoltageV1));
    interp_ICA2=.0001.*ones(1,length(VoltageV1));
    first_Voltage=transpose(VoltageV1-.0001);

    %Add to the Cycle Matrix
    continuosVoltage=vertcat(interp_Voltages,first_Voltage,cyclematrix2);
    continuosICA=vertcat(interp_ICA1,interp_ICA2,cyclematrix1);

    for j=1:NormalCycle
        VoltageCurve=continuosVoltage(:,j);
        ICA_Curve=continuosICA(:,j);
        [VoltageCurve, index] = unique(VoltageCurve);  
        dQdV(:,j)= interp1(VoltageCurve,ICA_Curve(index),xVoltage);
        %cyclematrix1(:,j)=smooth(cyclematrix1(:,j),5);
        %cyclematrix2(:,j)=smooth(cyclematrix2(:,j),5);
    end
    %master_dQdV =horzcat(master_dQdV, dQdV(:,1:100));

    %% Calculate Time, Average Voltage, and Charge Capacity for each cyle.
    for j=1:NormalCycle 
        LSTM_Parameters(j,4*(i-1)+1)=max(cyclematrix4(:,j))/1000;
        LSTM_Parameters(j,4*(i-1)+3)=max(cyclematrix3(:,j));
        LSTM_Parameters(j,4*(i-1)+4)=max(cyclematrix5(:,j));
        Voltage_sum=0;
        step_num=0;
        for n=1:length(cyclematrix2(:,j))
            if cyclematrix2(n,j) ~= 0
                Voltage_sum= Voltage_sum+ cyclematrix2(n,j);
                step_num= step_num +1;
            end
        end
        LSTM_Parameters(j,4*(i-1)+2)=Voltage_sum/step_num;     
    end

    %Normalize Capacity 
    CQ = LSTM_Parameters(:,4*(i-1)+3)./max(LSTM_Parameters(:,4*(i-1)+3));
    Q = LSTM_Parameters(:,4*(i-1)+4)./max(LSTM_Parameters(:,4*(i-1)+4));
    %master_Q=[master_Q; Q];
    %master_dQdV =horzcat(master_dQdV, dQdV);
    %%  Calculate Cycle Life to 95,90 and 80% capacity.
    Cyc_to_95=0;
    Cyc_to_90=0;
    Cyc_to_80=0;
    for j=1:NormalCycle
        if Q(j)>=0.8
            Cyc_to_80= Cyc_to_80+1;
        end
        if Q(j)>=0.9
            Cyc_to_90= Cyc_to_90+1;
        end
        if Q(j)>=0.95
            Cyc_to_95= Cyc_to_95+1;
        end
    end
        Z(i-18)=Q(575);
        master_Q2=[master_Q2; Q(1:cycles(t))];
        master_dQdV2 =horzcat(master_dQdV2, dQdV(:,1:cycles(t)));
    end
    size(mean_X);
    size(transpose(master_dQdV2));
    size(pinv(components(:,1:4)));
    test_scores= pinv(components(:,1:3))*(master_dQdV2-transpose(mean_X));
    for q=1:5
         r=1;
         for w=1:cycles(t)
             for e=1:3
                 test_scores_resized(q,r)=test_scores(e,w+(cycles(t)*(q-1)));
                 r=r+1;
             end
         end
    end
    Z_guess=test_scores_resized*b;
    error(:,t)=transpose(Z)-Z_guess;
    RMSE(t)=sqrt(sum(error(:,t).^2)./5);
    RMSE
    r_squared(t)=1-(5*(RMSE(t)).^2)./sum((transpose(Z)-mean(Z)).^2);
end
% Use Regression for 4*k Components
% Build in y of result cycles to 90%
% Then build the regression
error=RMSE;
plot(cycles,RMSE)
hold on
plot(cycles,RMSE_train)
figure(2)
plot(cycles,r_squared)
ylim([0 1])

end
