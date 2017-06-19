import mlreportgen.ppt.*;
slidesFile = 'mySlides.pptx';
slides = Presentation(slidesFile);
 
slide1 = add(slides,'Title Slide');
replace(slide1,'Title','My Presentation');
replace(slide1,'Subtitle','Create a Presentation Program');
 
slide2 = add(slides,'Title and Content');
para = Paragraph('First Content Slide');
para.FontColor = 'blue';
replace(slide2,'Title',para);
 
replace(slide2,'Content',{'First item','Second item','Third item'});
 
close(slides);