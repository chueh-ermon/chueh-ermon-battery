% Batch processing of galvanostatic LFP files (specific to Jongwoo)
% Peter Attia, May 13 2017
%
% Requirements:
%   - File type must be .csv
%   - Put all .xlsx files in the same folder as 'fitsandplots.m' and
%   -   'capacitance.m'

clear, close all

cd 'C://Data'
master_dDQdV=[];
master_Lifetime=[];
master_cycle=[];
% Import file(s). The setting 'MultiSelect'='on' allows for the user to
% select multiple files at once using the control key
%Need to add in V vs Q or time for this set. 
[filename, pathname] = uigetfile({'*.CSV'}, ...
    'Select the MultiPak-generated CSV files','MultiSelect', 'on');
thisdir = cd;

% Get a list of all Excel files in directory
dinfo = dir('*.xlsx');
filenames = {dinfo.name};
% remove deleted filenames from list
deletedcount = 0;
for i = 1:numel(filenames)
    if filenames{i}(1)=='~'
        deletedcount = deletedcount + 1;
    end
end
filenames = filenames(1:numel(filenames)-deletedcount);

foldername = cell(1,numel(filenames));

% Load each file sequentially
for i = 1:numel(filenames)
    
    % Update on progress
    disp(['Starting processing of file ' num2str(i) ' of ' ...
        num2str(numel(filenames))])
    
    % Current file
    curfile = filenames{i};
        
    % Preinitialize arrays
    Q = cell(1,numel(sheets));
    V = cell(1,numel(sheets));
    legendheaders = cell(1,numel(sheets));
    I = zeros(1,numel(sheets));
    
    % Load sheets
    for s = 1:numel(sheets)
        [data,titles]=xlsread(curfile,sheets{s});
        Q{s} = data(:,1);
        V{s} = data(:,2);
        
        % Find the current for each sheet
        Cindex = strfind(upper(sheets{s}),'C');
        legendheaders{s} = upper(sheets{s}(1:Cindex));
        I(s) = str2double(sheets{s}(1:Cindex-1));
    end
    
    % Remove existing folder (if it exists) and then make a new directory
    foldername{i} = curfile(1:end-5);
    if exist(foldername{i},'dir')
        rmdir(foldername{i},'s')
    end
    mkdir(foldername{i})
    disp(foldername{i})
    
    % Save cell arrays
    save([foldername{i},'/',foldername{i},'.mat'],'Q','V')
    %save([foldername,'.mat'],'Q','V')
    
    
    
    %%% Analysis %%%
    
    % Determine LFPcap and Cdis using lowest-current data
    [~, minindex] = min(I); % Find index of minimum current value
    [LFPcap, Cdis, Ccharge] = capacitance(Q{minindex},V{minindex});
    
    % Only use unique currents. This assumes all tests are sequential
    % (i.e. no repeats before a complete rate test)
    I = unique(I);
    legendheaders = legendheaders(1:length(I));
    Q = Q(1:length(I));
    V = V(1:length(I));
    
    % Find eta-j relationships at different SOCs
    for k = 1:length(SOCs)
        Q_SOCdc = LFPcap*SOCs(k) + Cdis;
        Q_SOCc  = LFPcap*SOCs(k) + Ccharge;
        fitsandplots(V, Q, I, legendheaders, Q_SOCdc, Q_SOCc, SOCs(k), foldername{i});
        cd(thisdir)
    end
        
    
    % Return to original directory
    cd(thisdir)
end

finalplots