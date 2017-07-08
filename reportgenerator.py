#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul  7 12:10:30 2017

@author: peter
"""

# Imports
import os
from pptx import Presentation
from pptx.util import Inches

import comtypes.client

#import time
from datetime import date

def PPTtoPDF(inputFileName, outputFileName, formatType = 32):
    powerpoint = comtypes.client.CreateObject("Powerpoint.Application")
    powerpoint.Visible = 1

    if outputFileName[-3:] != 'pdf':
        outputFileName = outputFileName + ".pdf"
    deck = powerpoint.Presentations.Open(inputFileName)
    deck.SaveAs(outputFileName, formatType) # formatType = 32 for ppt to pdf
    deck.Close()
    powerpoint.Quit()

def addImageSlide(imageFileName):
	blank_slide_layout = prs.slide_layouts[6]
	slide = prs.slides.add_slide(blank_slide_layout)
	pic = slide.shapes.add_picture(img_path, 0, 0, height=prs.slide_height, width=prs.slide_width)

# Get today's date
today = date.today()

# make filename
slidesFile = today.isoformat() + '_slides.pptx'

# Initialize presentation
prs = Presentation()
prs.slide_height = 5143500 # Widescreen aspect ratio
title_slide_layout = prs.slide_layouts[0]
slide = prs.slides.add_slide(title_slide_layout)
title = slide.shapes.title
subtitle = slide.placeholders[1]

# Create title slide
title.text = "Current Cycling Progress"
subtitle.text = today.isoformat()

# CD to C:\Data. Update files here
os.chdir('C:\Data')

# ADD ALL IMAGES HERE

# Add summary slide
img_path = 'contour.png'
addImageSlide(img_path)

# Add each cell, sorted by charging algorithm
# for j=1:numel(CA_array)
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

# Autosave directory
saveDir = 'C:\\Users\\Arbin\\Box Sync\\Reports'
os.chdir(saveDir)

# Create file names
slidesFileFull = saveDir + '\\' + slidesFile
slidesFileFullPDF = saveDir + '\\' + slidesFile.replace('pptx','pdf')

# Save powerpoint
prs.save(slidesFileFull)
# Convert to PDF
PPTtoPDF(slidesFileFull,slidesFileFullPDF)