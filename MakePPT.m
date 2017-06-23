% Make ppt for Cycler and current running cells, and then email the
% results.
% Peter Attia and Nick Perkins 
%% Import Power point generator app
import mlreportgen.ppt.*
%Set Date of cycling start
batchdate='2017-05-12';
%Choose the charging family contains all points. 
charging_family='C';
%% Run Batch Analysis for all cells, and create Presentation and slides.
[filenames, cap_array, CA_array, charge_time, master_capacity,barcodes, ...
    master_cycle, deg_rates]...
    =Batch_Analysis(batchdate,charging_family);

%% Save raw data to .mat file
save([date '_' charging_family '_data.mat'],'filenames', 'cap_array', ...
    'CA_array', 'charge_time', 'master_capacity','barcodes', ...
    'master_cycle','deg_rates');
%% Initialize PowerPoint Presentation
slidesFile = [date '_' charging_family '_slides.pptx'];
slides = Presentation(slidesFile);

slide1 = add(slides,'Title Slide');
replace(slide1,'Title','Current Cycling Progress');
replace(slide1,'Subtitle',{'Arbin LBT',date});
%% Add Summary Figures 
summary_slide = add(slides,'Blank');
pic = Picture(which(strcat(batchdate,'_',charging_family, ...
    '_current_spread.png')));
pic.X = '0in';
pic.Y = '0in';
pic.Width = '13.33in';
pic.Height = '7.41in';
add(summary_slide,pic);

summary_slide2 = add(slides,'Blank');
pic = Picture(which(strcat(batchdate,'_',charging_family, ...
    '_time_vs_capacity.png')));
pic.X = '0in';
pic.Y = '0in';
pic.Width = '13.33in';
pic.Height = '7.41in';
add(summary_slide2,pic);

summary_slide3 = add(slides,'Blank');
pic = Picture(which(strcat(batchdate,'_',charging_family, ...
    '_degradation_rate.png')));
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
%% Convert to PDF and email to the list
close(slides);
pptview(slidesFile,'converttopdf');
pdf_name=string(slidesFile);
pdf_name=erase(pdf_name,'.pptx');
pdf_name=strcat(pdf_name,'.pdf');
messageBody = 'Hot off the press: Check out the latest results!';
%sendemail('mchen18','BMS project: Updated results', ...
%    messageBody,char(pdf_name));