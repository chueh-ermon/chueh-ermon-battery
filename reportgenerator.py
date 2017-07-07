#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul  7 12:10:30 2017

@author: peter
"""

# Imports
from pptx import Presentation
from pptx.util import Inches

import comtypes.client

#import time
from datetime import date

# Get today's date
today = date.today()

# make filename
slidesFile = today.isoformat() + '_slides.pptx'

# Initialize presentation
prs = Presentation()
title_slide_layout = prs.slide_layouts[0]
slide = prs.slides.add_slide(title_slide_layout)
title = slide.shapes.title
subtitle = slide.placeholders[1]

title.text = "Current Cycling Progress"
subtitle.text = today.isoformat()

img_path = 'test.png'

blank_slide_layout = prs.slide_layouts[6]
slide = prs.slides.add_slide(blank_slide_layout)

left = top = Inches(0)
Width = Inches(13.33)
Height = Inches(7.41)
pic = slide.shapes.add_picture(img_path, left, top, height=Height, width=Width)
#
#left = Inches(5)
#height = Inches(5.5)
#pic = slide.shapes.add_picture(img_path, left, top, height=height)

prs.save(slidesFile)

PPTtoPDF(slidesFile,'newpdf.pdf')


def PPTtoPDF(inputFileName, outputFileName, formatType = 32):
    powerpoint = comtypes.client.CreateObject("Powerpoint.Application")
    powerpoint.Visible = 1

    if outputFileName[-3:] != 'pdf':
        outputFileName = outputFileName + ".pdf"
    deck = powerpoint.Presentations.Open(inputFileName)
    deck.SaveAs(outputFileName, formatType) # formatType = 32 for ppt to pdf
    deck.Close()
    powerpoint.Quit()

#slidesFile = [date '_' charging_family '_slides.pptx']
#slides = Presentation(slidesFile)
#
# 
#slide1 = add(slides,'Title Slide')
#replace(slide1,'Title','Current Cycling Progress')
#replace(slide1,'Subtitle',{'Arbin LBT',date})
#
## Add Summary Figures 
#summary_slide = add(slides,'Blank');
## TODO: could this find a picture in a different directory and add it?
#cd 'Summary_Graphs'
#pic = Picture(which(strcat(batchdate,'_',charging_family, ...
#    '_current_spread.png')));
#cd 'C://Data'
#pic.X = '0in';
#pic.Y = '0in';
#pic.Width = '13.33in';
#pic.Height = '7.41in';
#add(summary_slide,pic);
#
#summary_slide2 = add(slides,'Blank');
#cd 'Summary_Graphs'
#pic = Picture(which(strcat(batchdate,'_',charging_family, ...
#    '_time_vs_capacity.png')));
#cd 'C://Data'
#pic.X = '0in';
#pic.Y = '0in';
#pic.Width = '13.33in';
#pic.Height = '7.41in';
#add(summary_slide2,pic);
#
#summary_slide3 = add(slides,'Blank');
#cd 'Summary_Graphs'
#pic = Picture(which(strcat(batchdate,'_',charging_family, ...
#    '_degradation_rate.png')));
#cd 'C://Data'
#pic.X = '0in';
#pic.Y = '0in';
#pic.Width = '13.33in';
#pic.Height = '7.41in';
#add(summary_slide3,pic);
#
## Add Individual Cells in by Charging Algorithm
#for j=1:numel(CA_array)
#    cd(CA_array{j})
#    % Get a list of all image files in directory
#    dinfo = dir('*.png');
#    filenames = {dinfo.name};
#
#    seriesindex = '1';
#    for i = 1:length(filenames)
#        % Add section header slide for separation
#        if ~strcmp(filenames{i}(1),seriesindex)
#            % Create title s
#            t = CA_array{j};
#            t2 = strrep(t, '_' , '.' );
#            t2 = strrep(t2, '-' , '(' );
#            t2 = strrep(t2, 'per.' , '%)-' );
#            sectionSlide = add(slides,'Section Header');
#            replace(sectionSlide,'Title',t2);
#            seriesindex = filenames{i}(1);
#        end
#
#        pictureSlide = add(slides,'Blank');
#        pic = Picture(which(filenames{i}));
#        pic.X = '0in';
#        pic.Y = '0in';
#        pic.Width = '13.33in';
#        pic.Height = '7.41in';
#        add(pictureSlide,pic);
#    end
#    cd 'C://Data'
#end 