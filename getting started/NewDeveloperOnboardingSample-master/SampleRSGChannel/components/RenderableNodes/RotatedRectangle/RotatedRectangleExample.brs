' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'        
' this example creates a rectangle and centers it
sub init()
    examplerect = m.top.boundingRect()
    examplelrect = m.top.localBoundingRect()
    centerx = -examplerect.x + (1280 - examplelrect.width) / 2
    centery = -examplerect.y + (720 - examplelrect.height) / 2
    m.top.translation = [ centerx, centery ]
end sub
