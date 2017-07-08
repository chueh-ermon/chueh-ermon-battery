%% MakePPT.m...
%   - Runs Batch_Analysis
%   - Saves data to .mat
%   - Makes PPT & converts to PDF
%   - Emails results
% Peter Attia and Nick Perkins

% For this file to successfully run, please do the following:
%   - type 'open perl.m'
%   - Save file as 'python.m'
%   - Find and replace 'perl' with 'python'
%   - Also, download & install pip1.0: https://pypi.python.org/pypi/pip/1.0

%%%%%%% CHANGE THESE SETTINGS %%%
batchdate = '2017-05-12';
charging_family='C'; % C = all data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Run Batch Analysis for all cells
[filenames, cap_array, CA_array, charge_time, master_capacity,barcodes, ...
    master_cycle, deg_rates]...
    =Batch_Analysis(batchdate,charging_family);

%% Save raw data to .mat file
cd 'Raw_Matlab_Data'
save([date '_' charging_family '_data.mat'],'filenames', 'cap_array', ...
    'CA_array', 'charge_time', 'master_capacity','barcodes', ...
    'master_cycle','deg_rates');
cd 'C://Data'

%% Run the report generator (in Python)
% This will create the PPT and convert to PDF. It saves in the Box Sync
% folder
python('reportgenerator.py');

%% Send email
cd 'C://Users//Arbin//Box Sync//Auto-generated presentations'
pdf_name = '';
messageBody = 'Hot off the press: Check out the latest results!';
sendemail('mchen18','BMS project: Updated results', ...
    messageBody,char(pdf_name));