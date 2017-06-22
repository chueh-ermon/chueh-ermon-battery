function [filenames, cap_array, CA_array, charge_time, master_capacity, ...
    barcodes, master_cycle, deg_rates] = Batch_Analysis(Date, fast_charge)
%Batch Analysis: Produces summary figures and summary data points for given
%tests. -- Nicholas Perkins 06/2017
  
%This loops through algorithm by algorithm to plot summary figures.

% Requirements:
%   - File type must be .csv
%   - Make sure you don't include failed channels that never ran
%   - Example Batch_Analysis('Date started (YYYY-MM-DD)', 'Charge
%     condition' ex. 'C' for all of them or '5_4C' for 5.4 C step.
close all

% chose which data folder according to OS used - temporary: test purposes
if ispc
    cd 'C://Data'
else
    cd '/Users/ziyang/Desktop/2017_Chueh_Ermon_Research/test_data'
end
% TODO: delete between above comment and this comment

% TODO: uncomment next line
% cd 'C://Data'


%% Initialize Summary Arrays and values
% Holds all Discharge dQdV curves
master_dDQdV=[];
% Tracks total cycles run for each cell. 
master_cycle=[];
% Tracks last unix recorded time for each test
master_test_time=[];

cap_array={};
cyc_array={};
% An Array of Charging Algorithm names
CA_array={};
%List of all file names including Metadata
test_files={};
% Array containing Vector of median charge times for a charging algorithm
charge_time={};
% An Array of all charging times per cycle
time_evol={};
% An array of barcodes for each cell pulled from metadata 
barcodes={};
% An array of remaining Capacity
master_capacity={};
%% Starts from the C:// Data directory and reads in functional imports
% makes direcotry variable for C://Data
thisdir = cd;
% Inputs Batch Date to a string
date=string(Date);
% Inputs charging algorithm family to a string 
charge=string(fast_charge);
% Concates to one string
batch=strcat('*',date,'*',charge,'*.csv');
% Get a list of all CSV files in directory
dinfo = dir(char(batch));
% Lists filenames for all matching CSVs
filenames = {dinfo.name};

% remove deleted filenames from list 
deletedcount = 0;
for i = 1:numel(filenames)
    if filenames{i}(1)=='~'
        deletedcount = deletedcount + 1;
    end
end
filenames = filenames(1:numel(filenames)-deletedcount);
foldername = cell(1,numel(filenames)); % TODO: can we delete this
% In case there were no files found.
if numel(filenames) == 0
    disp('No files match query')
end
%% Extract Metadata and then remove from filename array
for i=1:numel(filenames)
    % Finds if .csv is a metadata
    meta=strfind(filenames{i},'Meta');
    if isempty(meta) == 0 % TODO: can we make this more clear?
        % If so then read the cell barcode from the metadata
        % TODO: remove this section until next TODO comment
        if ispc
            [~, text_data] = xlsread(filenames{i});
        else
            disp('ERROR: MacOS and Linux cannot run xlsread on a csv');
            %file_id = fopen(filenames{i})
            %text_data = textscan(file_id, 
            %fclose(file_id)
        end
        % TODO: uncomment this next line
        % [~, text_data] = xlsread(filenames{i});
        cell_ID=string(text_data{2,10});
        % Here would be where to remove other Metadata info 
        barcodes=[barcodes,cell_ID];
        continue
    else 
        % File is a result Data 
        test_files=[test_files,filenames{i}];
        test_name=filenames{i};
        underscore_i=strfind(test_name,'_');
        %Find underscore before and after charging algorithm.
        charging_algorithm=test_name(underscore_i(1)+1:underscore_i(end)-1);
        % Store Charging Algorithm name
        CA_array=[CA_array,charging_algorithm];
    end
end
% Remove any duplicates. 
CA_array=unique(CA_array);

%% Load each file sequentially Run analysis 
for j= 1:numel(CA_array)
    % For each charging algorithm create multiple vectors
    % One for remaining capacity
    rem_cap=[];
    % One for average Charge times 
    chargetime=[];
    % One for Cycles
    cyc_count=[];
    % Track how many batteries per charging algorithm
    num_batt=1;
    % Variable for test name 
    charging_algorithm=CA_array{j};
    if exist(charging_algorithm,'dir')
       % Remove existing folder (if it exists) and make a new directory
       rmdir(charging_algorithm,'s')
    end
    % Create new folder
    mkdir(charging_algorithm)
    % Change to C://Data
    cd(thisdir)
  
    for i = 1:numel(test_files)
        %Find tests that are within that charging algorithm.
        filename=test_files{i};
        if isempty(strfind(filename,charging_algorithm)) == 0 % Perhaps use func contains?
            % Update on progress 
            tic
            disp(['Starting processing of file ' num2str(i) ' of ' ...
                num2str(numel(test_files)) ':  ' filename])
            %% Run CSV Analysis 
            ResultData = csvread(strcat(thisdir,'\',test_files{i}),1,1);
            % cd 'chueh-ermon-battery'
            [Charge_time,dDQdV,End_of_life, cycle, ~, DQ, cell_ID1, ...
                test_time]=Cell_Analysis(ResultData, j, CA_array{j}, ...
                barcodes{i}, charging_algorithm);
            num_batt=num_batt+1;
            
            cap_array=[cap_array,DQ];
            master_dDQdV=vertcat(master_dDQdV,dDQdV);
            master_cycle=vertcat(master_cycle,cycle);
            master_test_time=vertcat(master_test_time,test_time);
            %% Run Analysis for individual batches 
            rem_cap=horzcat(rem_cap,End_of_life);
            Time_To_80Percent=median(Charge_time);
            time_evol=[time_evol, Charge_time];
            chargetime=horzcat(chargetime,Time_To_80Percent);
            cyc_count=horzcat(cyc_count,cycle);
            % Save Summary Figures 
            cd(charging_algorithm)
            savefig(strcat(charging_algorithm,'_',barcodes{i}))
            print(strcat(charging_algorithm,'_',barcodes{i}),'-dpng')
            % Return to original directory
            cd(thisdir)
            % Close figures if more than 2 are open 
            if num_batt == 3
                close all
            end
        else 
            continue
        end
        toc
    end
    %% For each algorithm, append to the Master Arrays.
    charge_time=[charge_time,chargetime];
    master_capacity=[master_capacity,rem_cap];
    cyc_array=[cyc_array, cyc_count];
end
%% Plot Summary figure
close all
% Plot the summary figures 
[deg_rates]=plot_spread(master_cycle,cap_array,charge_time,time_evol, ...
    master_capacity, CA_array, cyc_array, master_test_time);
cd 'Summary_Graphs'
figure(51)
savefig(strcat(Date,'_',fast_charge,'_current_spread'))
print(strcat(Date,'_',fast_charge,'_current_spread'),'-dpng')
figure(49)
savefig(strcat(Date,'_',fast_charge,'_time_vs_capacity'))
print(strcat(Date,'_',fast_charge,'_time_vs_capacity'),'-dpng')
figure(50)
savefig(strcat(Date,'_',fast_charge,'_degradation_rate'))
print(strcat(Date,'_',fast_charge,'_degradation_rate'),'-dpng')
cd thisdir
end