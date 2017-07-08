%% MakePPT.m...
%   - Runs Batch_Analysis
%   - Saves data to .mat
%   - Makes images
%   - Makes PPT & converts to PDF
%   - Emails results
% Nick Perkins, Zi Yang, Michael Chen, Peter Attia

% For this file to successfully run, please do the following:
%   - Ensure 'python.m' is in the same folder
%   - Also, ensure the required Python libraries are installed (see
%   reportgenerator.py)

%%%%%%% CHANGE THESE SETTINGS %%%
batchdate = '2017-06-30';
charging_family='C'; % C = all data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%
%% Run Batch Analysis for all cells
[filenames, cap_array, CA_array, charge_time, master_capacity,barcodes, ...
    master_cycle, deg_rates]...
    =Batch_Analysis(batchdate,charging_family);

%% Save raw data to .mat file
cd 'C://Users//Arbin//Box Sync//Reports'
save([date '_' charging_family '_data.mat'],'filenames', 'cap_array', ...
    'CA_array', 'charge_time', 'master_capacity','barcodes', ...
    'master_cycle','deg_rates');
cd 'C://Data//chueh-ermon-battery'
%%%%%%%

%%%%%%%
% CHANGE TO:
%% Run Batch Analysis for all cells
% batch = Batch_Analysis(batchdate,charging_family)
% cd 'C://Users//Arbin//Box Sync//Batch data'
% save([date '_' charging_family '_batchdata.mat'],batch)
% cd 'C://Data//chueh-ermon-battery'

%% Generate images & results for all cells
% cd ['C://Users//Arbin//Box Sync//Batch images//' date]
% batch.makeImages()
% batch.makeResultTable()
% batch.makeSummaryImages()
% cd 'C://Data//chueh-ermon-battery'
%%%%%%%

%% Run the report generator (in Python)
% This will create the PPT and convert to PDF. It saves in the Box Sync
% folder
python('reportgenerator.py');

%% Send email
cd 'C://Users//Arbin//Box Sync//Reports'
dateFormat = char(datetime('now','Format','yyyy-MM-dd')); % e.g. 2017-07-30
pdf_name = [dateFormat '_slides'];
messageBody = 'Hot off the press: Check out the latest results!';
sendemail('mchen18','BMS project: Updated results', ...
    messageBody,char(pdf_name));
cd 'C://Data//chueh-ermon-battery'