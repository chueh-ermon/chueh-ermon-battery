% Make ppt for Cycler and current running cells, and then email the
% results.
% Peter Attia and Nick Perkins 
%% Import Power point generator app
import mlreportgen.ppt.*
%Set Date of cycling start
batchdate='2017-05-12';
%Choose the charging family contains all points. 
charging_family='7C';
%% Run Batch Analysis for all cells, and create Presentation and slides.
[filenames, cap_array, CA_array, charge_time, master_capacity,barcodes, ...
    master_cycle, deg_rates]...
    =Batch_Analysis(batchdate,charging_family);

%% Save raw data to .mat file
cd 'Raw_Matlab_Data'
save([date '_' charging_family '_data.mat'],'filenames', 'cap_array', ...
    'CA_array', 'charge_time', 'master_capacity','barcodes', ...
    'master_cycle','deg_rates');
cd 'C://Data'

%% Initialize PowerPoint Presentation
slidesFile = [date '_' charging_family '_slides.pptx'];
slides = Presentation(slidesFile);

slide1 = add(slides,'Title Slide');
replace(slide1,'Title','Current Cycling Progress');
replace(slide1,'Subtitle',{'Arbin LBT',date});
%% Add Summary Figures 
summary_slide = add(slides,'Blank');
% TODO: could this find a picture in a different directory and add it?
cd 'Summary_Graphs'
pic = Picture(which(strcat(batchdate,'_',charging_family, ...
    '_current_spread.png')));
cd 'C://Data'
pic.X = '0in';
pic.Y = '0in';
pic.Width = '13.33in';
pic.Height = '7.41in';
add(summary_slide,pic);

summary_slide2 = add(slides,'Blank');
cd 'Summary_Graphs'
pic = Picture(which(strcat(batchdate,'_',charging_family, ...
    '_time_vs_capacity.png')));
cd 'C://Data'
pic.X = '0in';
pic.Y = '0in';
pic.Width = '13.33in';
pic.Height = '7.41in';
add(summary_slide2,pic);

summary_slide3 = add(slides,'Blank');
cd 'Summary_Graphs'
pic = Picture(which(strcat(batchdate,'_',charging_family, ...
    '_degradation_rate.png')));
cd 'C://Data'
pic.X = '0in';
pic.Y = '0in';
pic.Width = '13.33in';
pic.Height = '7.41in';
add(summary_slide3,pic);
%% Add Individual Cells in by Charging Algorithm
for j=1:numel(CA_array)
    cd(CA_array{j})
    % Get a list of all image files in directory
    dinfo = dir('*.png');
    filenames = {dinfo.name};

    seriesindex = '1';
    for i = 1:length(filenames)
        % Add section header slide for separation
        if ~strcmp(filenames{i}(1),seriesindex)
            % Create title s
            t = CA_array{j};
            t2 = strrep(t, '_' , '.' );
            t2 = strrep(t2, '-' , '(' );
            t2 = strrep(t2, 'per.' , '%)-' );
            sectionSlide = add(slides,'Section Header');
            replace(sectionSlide,'Title',t2);
            seriesindex = filenames{i}(1);
        end

        pictureSlide = add(slides,'Blank');
        pic = Picture(which(filenames{i}));
        pic.X = '0in';
        pic.Y = '0in';
        pic.Width = '13.33in';
        pic.Height = '7.41in';
        add(pictureSlide,pic);
    end
    cd 'C://Data'
end 
%% Convert to PDF and Email to Big Mike.
close(slides);
pptview(slidesFile,'converttopdf');
pdf_name=string(slidesFile);
pdf_name=erase(pdf_name,'.pptx');
pdf_name=strcat(pdf_name,'.pdf');
messageBody = 'Hot off the press: Check out the latest results!';
%sendemail('mchen18','BMS project: Updated results', ...
%    messageBody,char(pdf_name));

disp(slidesFile)
%% move siles to PPT folder - for now this doesn't work
% cd 'PowerPoint_Presentations'
% movefile fullfile('C:\Data\', slidesFile)
% movefile fullfile('C:\Data\', pdf_name)
% movefile which(slidesFile) 'C:\Data\PowerPoint_Presentations'
% movefile which(pdf_name) 'C:\Data\PowerPoint_Presentations'