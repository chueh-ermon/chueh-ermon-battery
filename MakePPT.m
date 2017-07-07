% MakePPT.m...
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
python('reportgenerator.py')

%% Convert to PDF and email to the list
close(slides);
pptview(slidesFile,'converttopdf');
pdf_name=string(slidesFile);
pdf_name=erase(pdf_name,'.pptx');
pdf_name=strcat(pdf_name,'.pdf');
messageBody = 'Hot off the press: Check out the latest results!';
sendemail('mchen18','BMS project: Updated results', ...
    messageBody,char(pdf_name));

disp(slidesFile)

%% move siles to PPT folder - for now this doesn't work
% cd 'PowerPoint_Presentations'
% movefile fullfile('C:\Data\', slidesFile)
% movefile fullfile('C:\Data\', pdf_name)
% movefile which(slidesFile) 'C:\Data\PowerPoint_Presentations'
% movefile which(pdf_name) 'C:\Data\PowerPoint_Presentations'
