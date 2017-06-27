% full_cell_analysis.m
% Zi Yang (zya@umich.edu)
%
% In-depth analysis of dQdV, temperature, relative capacity, and voltage
% for each cycle in cell
%            ----
%           | policy (string)
%           | barcode (string)
% cells(1) -  dQdV curves/cycle (cell array of cell arrays)
%           | relative capacity/cycle (cell array)
%           | voltage range (?)
%           | temperature
%            ----

function [cell] = full_cell_analysis(raw_data)

%% Initialize struct/object/cellarray
% may not be able to retrieve this here? cell.policy = 'string';
% may not be able to retrieve this here? cell.barcode = 'string';
cell.dQdV_curves = {{},{}};
cell.capacity = {};
cell.voltage = {};
cell.temperature = {};

% total_time = raw_data(:,1);
% step_time = raw_data(:,3);
% step_index = round(raw_data(:,4));
 cycle_index = raw_data(:,5);
% voltageV = raw_data(:,7);
% current = raw_data(:,6);
% charge_capacityAh = raw_data(:,8);
% discharge_capacityAh = raw_data(:,9);

%% For each cycle, collect information
for j = max(cycle_index) % - 1 (do we include last cycle?)
    i1 = find(cycle_index == j);
    i1a = i1(1); i1b = i1(end);
end




%% Save Matlab Workspace as a .mat file

%% Save as csv?