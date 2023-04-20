' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'        
' this example creates a label and centers it using the bounding rectangle
sub init()
    examplerect = m.top.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    m.top.translation = [ centerx, centery ]
end sub
