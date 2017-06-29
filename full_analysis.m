% full_analysis.m
% Zi Yang (zya@umich.edu)
%
% In-depth analysis of dQdV, temperature, relative capacity, and voltage
% for each cycle in every cell in the batch

%% Allow user to select csv files for analysis
cd 'C://Data'

[filename, pathname] = uigetfile({'*.CSV'}, ...
    'Select the CSV files','MultiSelect', 'on');

%% Initialize master data structures
% struct called cells - what would it hold?
% policy, barcode, dQdV curves/cycle, relative capacity/cycle, voltage
% range (is this the same for all policies?), temperature
%            ----
%           | policy (string)
%           | barcode (string)
% cells(1) -  dQdV curves/cycle (cell array of cell arrays)
%           | relative capacity/cycle (cell array)
%           | voltage range (?)
%           | temperature
%            ----

% alg - policy/file name

%% For each file, collect data needed
% If just one file
if isa(filename,'char')
    
% If multiple files
elseif isa(filename,'cell') % If multiple files
    num_csvs = length(filename); % Number of CSVs selected
    for j=1:num_csvs  
        raw_data = csvread(strcat(pathname,filename{j}),1,1);
        [cell] = full_cell_analysis(raw_data, alg);
        cells(j) = cell;
        % Run file through full_cell_analysis
        % find cell barcode in metadata file - add to cell
        % concatanate pulled data to a cell in cells
    end
end

%% Export all pulled data as .mat file
