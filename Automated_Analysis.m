close all
clear all

cd 'C://Data'
master_dDQdV=[];
master_Lifetime=[];
master_cycle=[];
% Import file(s). The setting 'MultiSelect'='on' allows for the user to
% select multiple files at once using the control key
%Need to add in V vs Q or time for this set. 
[filename, pathname] = uigetfile({'*.CSV'}, ...
    'Select the MultiPak-generated CSV files','MultiSelect', 'on');
% Filename = actual file, pathname = directory

% If just one file
if isa(filename,'char')
    % Read in the data file. strcat(pathname, filename) provides the full
    % directory of the file
    numcsvs=1;
    ResultData = csvread(strcat(pathname,filename),1,1);
    [Cell_Statistics,dDQdV,End_of_life,cycle]=AutomatedDA(ResultData);
    master_dDQdV=vertcat(master_dDQdV,dDQdV);
    master_cycle=vertcat(master_cycle,cycle);
    master_Lifetime=vertcat(master_Lifetime,End_of_life);
    Time_To_80Percent=median(Cell_Statistics);
    
elseif isa(filename,'cell') % If multiple files
    numcsvs = length(filename); % Number of CSVs selected
    %Cdischarge = cell(numcsvs,1); % delete this line
    for j=1:numcsvs  
        ResultData = csvread(strcat(pathname,filename{j}),1,1);
        [Cell_Statistics,dDQdV,End_of_life, cycle]=AutomatedDA(ResultData);
        master_dDQdV=vertcat(master_dDQdV,dDQdV);
        master_cycle=vertcat(master_cycle,cycle);
        master_Lifetime=vertcat(master_Lifetime,End_of_life);
        Time_To_80Percent(j)=median(Cell_Statistics);
        %Cdischarge{j} = Cdis; % delete this line
    end
    [W,H]=Spectra_Decomposition(master_dDQdV,4);
end
%% Batch Statistics 
%figure(7)
%hist(master_Lifetime,5)
%legend(filename{1},'',filename{2},'',filename{3},'',filename{4},'',filename{5},'',...
    %filename{6},'',filename{7},'',filename{8},'',filename{9},'')
%plotfixer;
    
    
   